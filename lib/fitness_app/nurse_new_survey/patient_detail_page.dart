import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../config.dart'; // Ensure Config.baseUrl is correctly set
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:typed_data';

class PatientDetailPage extends StatefulWidget {
  final List patientDetails;
  final int surveyId;

  PatientDetailPage({required this.patientDetails, required this.surveyId});

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  List originalPatientDetails = [];
  List allPatients = [];
  List filteredPatientDetails = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      isLoading = true;
    });

    // Fetch all patients first
    await _fetchAllPatients();

    // If patient details are provided, mark them as answered
    if (widget.patientDetails.isNotEmpty) {
      originalPatientDetails = widget.patientDetails;

      // Create a map for quick lookup
      Map<dynamic, Map<String, dynamic>> patientMap = {
        for (var patient in allPatients) patient['patient_id']: patient
      };

      for (var patientAnswer in originalPatientDetails) {
        var pid = patientAnswer['patient_id'];
        if (patientMap.containsKey(pid)) {
          patientMap[pid]!['answered'] = true;
        }
      }

      setState(() {
        filteredPatientDetails = List.from(allPatients);
        isLoading = false;
      });
    } else {
      // If no patient details provided, fetch them from the API
      await _fetchAllPatientsAndAnswers();
    }
  }

  Future<void> _fetchAllPatientsAndAnswers() async {
    final String apiUrl =
        Config.baseUrl + '/surveys/${widget.surveyId}/patient_answers';
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var pdata = jsonDecode(response.body);
      originalPatientDetails = pdata['patient_details'];

      // Create a map for quick lookup
      Map<dynamic, Map<String, dynamic>> patientMap = {
        for (var patient in allPatients) patient['patient_id']: patient
      };

      for (var patientAnswer in originalPatientDetails) {
        var pid = patientAnswer['patient_id'];
        if (patientMap.containsKey(pid)) {
          patientMap[pid]!['answered'] = true;
        }
      }

      setState(() {
        filteredPatientDetails = List.from(allPatients);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取病人回答详情失败')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAllPatients() async {
    final String apiUrl = Config.baseUrl + '/patient/get_list'; // Adjust API if necessary
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // Assuming the backend returns data in the format 'id1+-*/name1+-*/class1/*-+id2+-*/name2+-*/class2/*-+...'
      var allPatientsData = response.body.split('/*-+');
      allPatients = allPatientsData
          .where((patient) => patient.isNotEmpty)
          .map((patient) {
            var patientData = patient.split('+-*/');
            return {
              'patient_id': patientData[0],
              'patient_name': patientData[1],
              'patient_class': patientData[2],
              'answered': false, // Assume no answer initially
            };
          })
          .toList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取所有病人列表失败')),
      );
    }
  }

  void filterPatients(String query) {
    List filteredList = allPatients.where((patient) {
      return patient['patient_name']
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPatientDetails = filteredList;
    });
  }

Future<void> _exportAllAnswers() async {
  if (kIsWeb) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('导出功能不支持Web平台')),
    );
    return;
  }

  final String exportUrl =
      Config.baseUrl + '/surveys/${widget.surveyId}/export_answers';
  var url = Uri.parse(exportUrl);
  var response = await http.get(url);

  if (response.statusCode == 200) {
    String csvData = response.body;

    // 从之前的逻辑中获取你实际需要导出的回答数据，如果需要过滤请自行过滤
    // 假设此处csvData就是最终需要导出的CSV字符串
    Uint8List csvBytes = Uint8List.fromList(utf8.encode(csvData));
    
    // 使用 flutter_file_dialog 展示保存对话框
    // 用户可以选择保存位置（在Android上会打开SAF对话框，在iOS上会使用系统分享菜单）
    final params = SaveFileDialogParams(
      fileName: 'survey_${widget.surveyId}_answers_${DateTime.now().millisecondsSinceEpoch}.csv',
      data: csvBytes, 
      // 你也可以使用sourceFilePath的方式，如果你已经把数据存到了本地文件中 
      // 这里使用data字段来保存内存中的数据
    );

    try {
      final filePath = await FlutterFileDialog.saveFile(params: params);
      if (filePath != null) {
        // 用户选择了位置并成功保存
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV已成功导出至: $filePath')),
        );
      } else {
        // 用户可能取消了保存操作
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出操作已取消')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败：$e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('导出失败：服务器返回非200状态码')),
    );
  }
}


  Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    var sdkInt = await _getAndroidSDKInt();
    return sdkInt >= 33;
  }

  Future<int> _getAndroidSDKInt() async {
    try {
      var response = await http.get(Uri.parse('https://google.com')); // Dummy request
      // Since Dart doesn't have a direct way to get Android SDK, you might need platform channels or use device_info_plus
      // Here, we'll assume a fixed value for demonstration purposes
      return 33; // Replace with actual SDK retrieval logic
    } catch (e) {
      return 30; // Default to Android 11 for example
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('病人答题详情'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: '搜索病人名字',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterPatients,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredPatientDetails.length,
                      itemBuilder: (context, index) {
                        var patient = filteredPatientDetails[index];
                        return ListTile(
                          title: Text('${patient['patient_name']}'),
                          subtitle: Text(patient['answered'] == true
                              ? '已作答'
                              : '未作答'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportAllAnswers,
        child: Icon(Icons.download),
        tooltip: '导出CSV',
      ),
    );
  }
}
