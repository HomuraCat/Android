import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../config.dart'; // 确保 Config.baseUrl 正确设置
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
  bool _isExporting = false; // State for export loading indicator

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      isLoading = true;
    });

    // 首先获取所有病人
    await _fetchAllPatients();

    // 如果提供了病人详情，则将其标记为已回答
    if (widget.patientDetails.isNotEmpty) {
      originalPatientDetails = widget.patientDetails;

      // 创建一个用于快速查找的 map
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
      // 如果没有提供病人详情，则从API获取
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

      // 创建一个用于快速查找的 map
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
    final String apiUrl = Config.baseUrl + '/patient/get_list'; // 必要时调整API
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // 假设后端返回的数据格式为 'id1+-*/name1+-*/class1/*-+id2+-*/name2+-*/class2/*-+...'
      var allPatientsData = response.body.split('/*-+');
      allPatients = allPatientsData
          .where((patient) => patient.isNotEmpty)
          .map((patient) {
            var patientData = patient.split('+-*/');
            return {
              'patient_id': patientData[0],
              'patient_name': patientData[1],
              'patient_class': patientData[2],
              'answered': false, // 初始假设未回答
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

  // --- Updated Export Function ---
  Future<void> _exportAllAnswers() async {
    if (_isExporting) return; // 防止重复点击

    setState(() {
      _isExporting = true;
    });

    // Web平台不支持此库的直接文件保存
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出功能不支持Web平台')),
      );
      setState(() {
        _isExporting = false;
      });
      return;
    }

    try {
      final String exportUrl =
          '${Config.baseUrl}/surveys/${widget.surveyId}/export_answers';
      final Uri url = Uri.parse(exportUrl);
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        // XLSX文件的响应体是二进制数据
        // 使用 response.bodyBytes，它是一个 Uint8List
        final Uint8List fileBytes = response.bodyBytes;

        // 如果可用，从 Content-Disposition 头中提取文件名
        String fileName = 'survey_${widget.surveyId}_answers_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final String? contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null) {
            final match = RegExp('filename\*=UTF-8\'\'(.+?)(_answers.xlsx)').firstMatch(contentDisposition);
            if (match != null && match.groupCount >= 1) {
                final encodedName = match.group(1)!;
                // 文件名是 URL 编码的，所以我们需要解码它
                fileName = Uri.decodeComponent(encodedName) + '_answers.xlsx';
            }
        }
        
        final params = SaveFileDialogParams(
          // data 是文件的原始二进制数据
          data: fileBytes,
          // 将文件名更新为 .xlsx 扩展名
          fileName: fileName,
        );

        // 使用 flutter_file_dialog 显示保存文件对话框
        final String? filePath = await FlutterFileDialog.saveFile(params: params);
        
        if (mounted) {
            if (filePath != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('XLSX 已成功导出至: $filePath')),
                );
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('导出操作已取消')),
                );
            }
        }
      } else {
        // 如果服务器发送了JSON格式的错误消息，尝试解码
        String errorMessage = '服务器返回错误，状态码: ${response.statusCode}';
        try {
            final errorJson = jsonDecode(response.body);
            if (errorJson['error'] != null) {
                errorMessage = '导出失败: ${errorJson['error']}';
            }
        } catch (_) {
            // 如果响应体不是JSON或格式不符，则使用备用消息
        }
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
            );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
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
        onPressed: _isExporting ? null : _exportAllAnswers,
        child: _isExporting 
          ? SizedBox(
              height: 24, 
              width: 24, 
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)
            )
          : Icon(Icons.download),
        tooltip: '导出XLSX',
      ),
    );
  }
}
