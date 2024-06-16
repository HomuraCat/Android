import 'package:flutter/material.dart';

class PatientDetailPage extends StatefulWidget {
  final List patientDetails;

  PatientDetailPage({required this.patientDetails});

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  List filteredPatientDetails = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPatientDetails = widget.patientDetails;
  }

  void filterPatients(String query) {
    List filteredList = widget.patientDetails.where((patient) {
      return patient['patient_name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPatientDetails = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('病人答题详情'),
      ),
      body: Padding(
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
                    title: Text('病人: ${patient['patient_name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        patient['answered']
                            ? Text('得分: ${patient['score']}')
                            : Text('未作答'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
