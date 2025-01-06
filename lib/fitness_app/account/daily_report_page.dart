import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../utils/Spsave_module.dart';
import '../../config.dart';

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({Key? key}) : super(key: key);

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String _temperature,
      high_pressure,
      low_pressure,
      last_time,
      patientID = "",
      name = "";
  String weight = "?", medication_type = "已删除", medication_dosage = "已删除";
  String _selectedUnit = '粒';
  final List<String> _units = ['毫克', '克', '微克', '升', '毫升', '单位', '包', '片', '粒', '瓶', '管', '喷', '滴', '贴'];
  double _pain = 1.0, _tiredness = 1.0, _sleep = 1.0;
  bool submitstate = false;
  int _selectedValue = 1;
  DateTime RefreshTime = DateTime(0, 1, 1, 0, 0);
  DateTime MessageTime = DateTime(0, 1, 1, 20, 0);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => CheckTime());
    _initConfig();
  }

  void _initConfig() async {
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      patientID = account['patientID'];
      name = account['name'];
    }
    setState(() {});
    int last_submitday, last_submitmonth, last_submityear;
    await GetSubmitTime(context);
    if (last_time != "ERROR"){
      submitstate = true;
      List<String> temp_last_time = last_time.split(' ');
      last_submityear = int.parse(temp_last_time[0]);
      last_submitmonth = int.parse(temp_last_time[1]);
      last_submitday = int.parse(temp_last_time[2]);
      if (last_submityear < DateTime.now().year) {
        submitstate = false;
      }
      if (last_submityear == DateTime.now().year &&
          last_submitmonth < DateTime.now().month) {
        submitstate = false;
      }
      if (last_submityear == DateTime.now().year &&
          last_submitmonth == DateTime.now().month &&
          last_submitday < DateTime.now().day) {
        submitstate = false;
      }
      if (last_submityear == DateTime.now().year &&
          last_submitmonth == DateTime.now().month &&
          last_submitday == DateTime.now().day &&
          CompareTime(RefreshTime, DateTime.now())) {
        submitstate = false;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('每日上报'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            buildSymptomEvaluationTitle(),
            buildPainTitle(),
            buildPainSlider(),
            buildTirednessTitle(),
            buildTirednessSlider(),
            buildSleepTitle(),
            buildSleepSlider(),
            const SizedBox(height: 10),
            buildVitalSignsTitle(),
            buildTemperatureField(),
            const SizedBox(height: 10),
            buildSystolicBloodPressureField(),
            const SizedBox(height: 10),
            buildDiastolicBloodPressureField(),
            const SizedBox(height: 10),
            buildWeightField(),
            const SizedBox(height: 10),
            buildMedicationSituationTitle(),
            buildMedicationUseField(),
            //const SizedBox(height: 10),
            //buildMedicationTypeField(),
            //const SizedBox(height: 10),
            //buildMedicationDosageField(),
            const SizedBox(height: 60),
            buildSubmitButton(context),
            if (submitstate) buildSubmitText(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget buildSymptomEvaluationTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '症状评估（以疼痛为例，1分为没有疼痛，10分为剧烈疼痛，请您根据实际情况填写）',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildPainTitle() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          '疼痛: $_pain',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildPainSlider() {
    return Slider(
        value: _pain,
        min: 1.0,
        max: 10.0,
        divisions: 9,
        label: _pain.toStringAsFixed(1),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        onChanged: submitstate
            ? null
            : (value) {
                setState(() {
                  _pain = value;
                });
              });
  }

  Widget buildTirednessTitle() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          '疲乏: $_tiredness',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildTirednessSlider() {
    return Slider(
        value: _tiredness,
        min: 1.0,
        max: 10.0,
        divisions: 9,
        label: _pain.toStringAsFixed(1),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        onChanged: submitstate
            ? null
            : (value) {
                setState(() {
                  _tiredness = value;
                });
              });
  }

  Widget buildSleepTitle() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          '睡眠: $_sleep',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildSleepSlider() {
    return Slider(
        value: _sleep,
        min: 1.0,
        max: 10.0,
        divisions: 9,
        label: _pain.toStringAsFixed(1),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        onChanged: submitstate
            ? null
            : (value) {
                setState(() {
                  _sleep = value;
                });
              });
  }

  Widget buildVitalSignsTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '生命体征',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildTemperatureField() {
    return TextFormField(
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '体温 ℃'),
      validator: (v) {
        var temperatureReg = RegExp(r"^[0-9]+(.[0-9]{1,2})+");
        if (!temperatureReg.hasMatch(v!)) {
          return '请正确输入体温';
        }
      },
      onSaved: (v) => _temperature = v!,
    );
  }

  Widget buildSystolicBloodPressureField() {
    return TextFormField(
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '收缩压（高压） mmHg'),
      validator: (v) {
        var temperatureReg = RegExp(r"^[0-9]+");
        if (!temperatureReg.hasMatch(v!)) {
          return '请正确输入血压';
        }
      },
      onSaved: (v) => high_pressure = v!,
    );
  }

  Widget buildDiastolicBloodPressureField() {
    return TextFormField(
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '舒张压（低压） mmHg'),
      validator: (v) {
        var temperatureReg = RegExp(r"^[0-9]+");
        if (!temperatureReg.hasMatch(v!)) {
          return '请正确输入血压';
        }
      },
      onSaved: (v) => low_pressure = v!,
    );
  }

  Widget buildWeightField() {
    return TextFormField(
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '体重 kg（选填）'),
      onSaved: (v) => weight = v!,
    );
  }

  Widget buildMedicationSituationTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '用药情况',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildMedicationUseField() {
    return Row(children: [
      const SizedBox(width: 8),
      Text(
        '按时用药',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(width: 50),
      Text(
        '是',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 1,
          groupValue: _selectedValue,
          onChanged: submitstate ? null : (value) {
            setState(() {
              _selectedValue = value as int;
            });
          }),
      Text(
        '否',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 2,
          groupValue: _selectedValue,
          onChanged: submitstate ? null : (value) {
            setState(() {
              _selectedValue = value as int;
            });
          })
    ]);
  }

  Widget buildMedicationTypeField() {
    return TextFormField(
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '药品种类'),
      validator: (v) {
        if (v!.isEmpty) {
          return '请输入药品种类';
        }
      },
      onSaved: (v) => medication_type = v!,
    );
  }

  Widget buildMedicationDosageField() {
    return Row(
      children:[
        Expanded(
          child: TextFormField(
            enabled: !submitstate,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                border: OutlineInputBorder(),
                labelText: '用药剂量'),
            validator: (v) {
              if (v!.isEmpty) {
                return '请输入用药剂量';
              }
            },
            onSaved: (v) => medication_dosage = v!,
          ),
        ),
        SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedUnit,
          onChanged: (String? newValue) {
            setState(() {
              _selectedUnit = newValue!;
            });
          },
          items: _units.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList()
      )]
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 35,
        width: 150,
        child: FloatingActionButton(
          backgroundColor: submitstate ? Colors.grey : Colors.black,
          child: Text('提交',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: submitstate
              ? null
              : () {
                  if ((_formKey.currentState as FormState).validate()) {
                    (_formKey.currentState as FormState).save();
                    SendQuestionnaire(context);
                  }
                },
        ),
      ),
    );
  }

  Widget buildSubmitText() {
    return const Padding(
        padding: EdgeInsets.only(left: 150),
        child: Text(
          '已提交',
          style: TextStyle(fontSize: 17, color: Colors.red),
        ));
  }

  bool CompareTime(time1, time2) {
    return time1.hour * 3600 + time1.minute * 60 + time1.second <=
        time2.hour * 3600 + time2.minute * 60 + time2.second;
  }

  void CheckTime() {
    DateTime current_time = DateTime.now();
    bool flag = ((current_time.hour == RefreshTime.hour) &&
        (current_time.minute == RefreshTime.minute) &&
        (current_time.second == RefreshTime.second));
    if (flag) {
      setState(() => submitstate = false);
    }
  }

  Future<void> GetSubmitTime(BuildContext context) async {
    DateTime this_submit_time = DateTime.now();
    if (CompareTime(RefreshTime, this_submit_time)) {
      this_submit_time = this_submit_time.add(const Duration(days: 1));
    }
    final String apiUrl = Config.baseUrl + '/questionnaire/get_time';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'patientID': patientID}),
    );
    
    if (response.statusCode == 200) {
      if (response.body != '0') setState(() => last_time = response.body);
        else setState(() => last_time = "ERROR");
    }
      else setState(() => last_time = "ERROR");
  }

  Future<void> SendQuestionnaire(BuildContext context) async {
    DateTime this_submit_time = DateTime.now();
    if (CompareTime(RefreshTime, this_submit_time)) {
      this_submit_time = this_submit_time.add(const Duration(days: 1));
    }

    final String apiUrl = Config.baseUrl + '/questionnaire/send';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'patientID': patientID,
        'name': name,
        'temperature': _temperature,
        'high_pressure': high_pressure,
        'low_pressure': low_pressure,
        'weight': weight,
        'medication_type': medication_type,
        'medication_dosage': medication_dosage,
        'pain': _pain.toString(), 
        'tiredness': _tiredness.toString(), 
        'sleep': _sleep.toString(),
        'medication_intime': _selectedValue.toString(),
        'submityear': this_submit_time.year.toString(),
        'submitmonth': this_submit_time.month.toString(),
        'submitday': this_submit_time.day.toString(),
        'type': 'daily_report'
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData == 1) {
        setState(() => submitstate = true);
        _showDialog(context, '提交成功！', onDialogClose: () {
          Navigator.pop(context);
        });
      }
    } else print('Request failed with status: ${response.statusCode}.');
  }

  void _showDialog(BuildContext context, String message,
      {VoidCallback? onDialogClose}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Message"),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onDialogClose != null) {
                  onDialogClose(); // Call the callback if it's provided
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class ShowDailyReportPage extends StatefulWidget {
  const ShowDailyReportPage({Key? key}) : super(key: key);

  @override
  State<ShowDailyReportPage> createState() => _ShowDailyReportPageState();
}

class _ShowDailyReportPageState extends State<ShowDailyReportPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String last_time, daily_info;
  String _temperature = "",
      high_pressure = "",
      low_pressure = "",
      medication_type = "",
      medication_dosage = "",
      patientID = "",
      name = "";
  double _pain = -1.0, _tiredness = -1.0, _sleep = -1.0;
  bool submitstate = false;
  int _selectedValue = -1;
  DateTime RefreshTime = DateTime(0, 1, 1, 0, 0);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => CheckTime());
    _initConfig();
  }

  void _initConfig() async {
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      patientID = account['patientID'];
      name = account['name'];
    }
    setState(() {});
    int last_submitday, last_submitmonth, last_submityear;
    await GetSubmitTime(context);
    if (last_time != "ERROR"){
      submitstate = true;
      List<String> temp_last_time = last_time.split(' ');
      last_submityear = int.parse(temp_last_time[0]);
      last_submitmonth = int.parse(temp_last_time[1]);
      last_submitday = int.parse(temp_last_time[2]);
      if (last_submityear < DateTime.now().year) {
        submitstate = false;
      }
      if (last_submityear == DateTime.now().year &&
          last_submitmonth < DateTime.now().month) {
        submitstate = false;
      }
      if (last_submityear == DateTime.now().year &&
          last_submitmonth == DateTime.now().month &&
          last_submitday < DateTime.now().day) {
        submitstate = false;
      }
      if (last_submityear == DateTime.now().year &&
          last_submitmonth == DateTime.now().month &&
          last_submitday == DateTime.now().day &&
          CompareTime(RefreshTime, DateTime.now())) {
        submitstate = false;
      }
    }

    if (submitstate) await GetDailyInfo(context);
      else _showDialog(context, '今日问卷未填写！', onDialogClose: () {Navigator.pop(context);});
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('每日上报'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            buildSymptomEvaluationTitle(),
            buildPainTitle(),
            buildTirednessTitle(),
            buildSleepTitle(),
            const SizedBox(height: 10),
            buildVitalSignsTitle(),
            buildTemperatureField(),
            const SizedBox(height: 10),
            buildSystolicBloodPressureField(),
            const SizedBox(height: 10),
            buildDiastolicBloodPressureField(),
            const SizedBox(height: 10),
            buildMedicationSituationTitle(),
            buildMedicationUseField(),
            //const SizedBox(height: 10),
            //buildMedicationTypeField(),
            //const SizedBox(height: 10),
            //buildMedicationDosageField(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget buildSymptomEvaluationTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '症状评估',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildPainTitle() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_pain == -1)?'疼痛: 加载中...':'疼痛: $_pain',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildTirednessTitle() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_tiredness == -1)?'疲乏: 加载中...':'疲乏: $_tiredness',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildSleepTitle() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_sleep == -1)?'睡眠: 加载中...':'睡眠: $_sleep',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildVitalSignsTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '生命体征',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildTemperatureField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_temperature.isEmpty)?'体温: 加载中...':'体温: $_temperature ℃',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildSystolicBloodPressureField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (high_pressure.isEmpty)?'收缩压: 加载中...':'收缩压: $high_pressure mmHg',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildDiastolicBloodPressureField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (low_pressure.isEmpty)?'舒张压: 加载中...':'舒张压: $low_pressure mmHg',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildMedicationSituationTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '用药情况',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildMedicationUseField() {
    return Row(children: [
      const SizedBox(width: 8),
      Text(
        (_selectedValue == -1)?'按时用药: 加载中...':(_selectedValue == 1)?'按时用药: 是':'按时用药: 否',
        style: TextStyle(fontSize: 18),
      )
    ]);
  }

  Widget buildMedicationTypeField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (medication_type.isEmpty)?'药品种类: 加载中...':'药品种类: $medication_type',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildMedicationDosageField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (medication_dosage.isEmpty)?'用药剂量: 加载中...':'用药剂量: $medication_dosage',
          style: TextStyle(fontSize: 20),
        ));
  }

  bool CompareTime(time1, time2) {
    return time1.hour * 3600 + time1.minute * 60 + time1.second <=
        time2.hour * 3600 + time2.minute * 60 + time2.second;
  }

  void CheckTime() {
    DateTime current_time = DateTime.now();
    bool flag = ((current_time.hour == RefreshTime.hour) &&
        (current_time.minute == RefreshTime.minute) &&
        (current_time.second == RefreshTime.second));
    if (flag) {
      setState(() => submitstate = false);
    }
  }

  void _showDialog(BuildContext context, String message,
      {VoidCallback? onDialogClose}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Message"),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onDialogClose != null) {
                  onDialogClose(); // Call the callback if it's provided
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> GetSubmitTime(BuildContext context) async {
    DateTime this_submit_time = DateTime.now();
    if (CompareTime(RefreshTime, this_submit_time)) {
      this_submit_time = this_submit_time.add(const Duration(days: 1));
    }
    final String apiUrl = Config.baseUrl + '/questionnaire/get_time';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'patientID': patientID}),
    );
    
    if (response.statusCode == 200) {
      if (response.body != '0') setState(() => last_time = response.body);
        else setState(() => last_time = "ERROR");
    }
      else setState(() => last_time = "ERROR");
  }

  Future<void> GetDailyInfo(BuildContext context) async {
    DateTime this_submit_time = DateTime.now();
    if (CompareTime(RefreshTime, this_submit_time)) {
      this_submit_time = this_submit_time.add(const Duration(days: 1));
    }
    final String apiUrl = Config.baseUrl + '/questionnaire/get_daily_info';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'patientID': patientID}),
    );
    
    if (response.statusCode == 200) {
      if (response.body != '0')
      {
        daily_info = response.body;
        List<String> temp_daily_info = daily_info.split('+-*/');
        _temperature = temp_daily_info[0];
        high_pressure = temp_daily_info[1];
        low_pressure = temp_daily_info[2];
        medication_type = temp_daily_info[3];
        medication_dosage = temp_daily_info[4];
        _pain = double.parse(temp_daily_info[5]);
        _tiredness = double.parse(temp_daily_info[6]);
        _sleep = double.parse(temp_daily_info[7]);
        _selectedValue = int.parse(temp_daily_info[8]);
        setState((() => {}));
      }
        else setState(() => daily_info = "ERROR");
    }
      else print('Request failed with status: ${response.statusCode}.');;
  }
}