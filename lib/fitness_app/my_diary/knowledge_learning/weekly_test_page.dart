import 'package:flutter/material.dart';
import 'dart:async';
import 'package:best_flutter_ui_templates/fitness_app/utils/Spsave_module.dart';
import 'package:best_flutter_ui_templates/fitness_app/utils/common_tools.dart';

class WeeklyTestPage extends StatefulWidget {
  const WeeklyTestPage({Key? key}) : super(key: key);

  @override
  State<WeeklyTestPage> createState() => _WeeklyTestPageState();
}

class _WeeklyTestPageState extends State<WeeklyTestPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  bool submitstate = false;
  DateTime RefreshTime = DateTime(0, 1, 1, 13, 15);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => CheckTime());
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
        title: Text('每周小测试'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 6),
            SelectQuestion(
                question: "1. 肺病是常见的恶性肿瘤之一，其发生主要与以下哪个因素有关？",
                choose1: "A. 病毒感染",
                choose2: "B. 遗传因素",
                choose3: "C. 不良饮食习惯",
                choose4: "D. 吸烟和环境"),
            const SizedBox(height: 6),
            SelectQuestion(
                question: "2. 肺痛的临床表现主要包括下列哪项?",
                choose1: "A. 咳嗽、咳痰、胸痛",
                choose2: "B. 发热、乏力、食欲减退",
                choose3: "C. 骨痛、压痛、体重减轻",
                choose4: "D. 头晕、恶心、呕吐"),
            const SizedBox(height: 6),
            SelectQuestion(
                question: "3. 肺癌的治疗方法主要包括下列哪些?",
                choose1: "A. 手术切除",
                choose2: "B. 化疗",
                choose3: "C. 放疗",
                choose4: "D. 全部都包括"),
            const SizedBox(height: 6),
            SelectQuestion(
                question: "4. 下列哪种检查方法可以帮助确诊肺癌?",
                choose1: "A. X线胸片",
                choose2: "B. 超声检查",
                choose3: "C. 噬共振成像",
                choose4: "D. 病理活检"),
            const SizedBox(height: 6),
            SelectQuestion(
                question: "5. 对丁肺癌患者的护理注意事项，以下哪一项是正确的?",
                choose1: "A. 鼓励患者主动咳嗽",
                choose2: "B. 给予高蛋白饮食",
                choose3: "C. 经常性史换护理用品",
                choose4: "D. 避免与患者密切接触"),
            const SizedBox(height: 60),
            buildSubmitButton(context),
            if (submitstate) buildSubmitText(),
            const SizedBox(height: 60)
          ],
        ),
      ),
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
                    SpStorage.instance.saveWeeklyTestConfig(
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
      SpStorage.instance.saveWeeklyTestConfig(submitstate: submitstate);
    }
  }
}
