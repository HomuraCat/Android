import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/Spsave_module.dart';

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
      medication_type,
      medication_dosage;
  double _pain = 1.0, _tiredness = 1.0, _sleep = 1.0;
  bool submitstate = false;
  int _selectedValue = 1;
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
    int last_submitday, last_submitmonth, last_submityear;
    Map<String, dynamic> config =
        await SpStorage.instance.readDailyReportConfig();
    print(config);
    submitstate = config['submitstate'] ?? false;
    last_submityear = config['submityear'] ?? 0;
    last_submitmonth = config['submitmonth'] ?? 0;
    last_submitday = config['submitday'] ?? 0;
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
            buildMedicationSituationTitle(),
            buildMedicationUseField(),
            const SizedBox(height: 10),
            buildMedicationTypeField(),
            const SizedBox(height: 10),
            buildMedicationDosageField(),
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
          '症状评估',
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
          labelText: '收缩压 mmHg'),
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
          labelText: '舒张压 mmHg'),
      validator: (v) {
        var temperatureReg = RegExp(r"^[0-9]+");
        if (!temperatureReg.hasMatch(v!)) {
          return '请正确输入血压';
        }
      },
      onSaved: (v) => low_pressure = v!,
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
          onChanged: (value) {
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
          onChanged: (value) {
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
    return TextFormField(
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
                    setState(() => submitstate = true);
                    DateTime this_submit_time = DateTime.now();
                    if (CompareTime(RefreshTime, this_submit_time)) {
                      this_submit_time.add(Duration(days: 1));
                    }
                    SpStorage.instance.saveDailyReportConfig(
                        submitstate: submitstate,
                        submityear: this_submit_time.year,
                        submitmonth: this_submit_time.month,
                        submitday: this_submit_time.day);
                  }
                },
        ),
      ),
    );
  }

  Widget buildSubmitText() {
    return const Padding(
        padding: EdgeInsets.only(left: 140),
        child: Text(
          '提交成功！',
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
      SpStorage.instance.saveDailyReportConfig(submitstate: submitstate);
    }
  }
}