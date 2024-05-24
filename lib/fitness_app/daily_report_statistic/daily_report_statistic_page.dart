import 'package:flutter/material.dart';

class ReportStatisticPage extends StatefulWidget {
  const ReportStatisticPage({Key? key}) : super(key: key);
  @override
  _ReportStatisticPageState createState() => _ReportStatisticPageState();
}

class _ReportStatisticPageState extends State<ReportStatisticPage> {
  
  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  void _initConfig() async {
    //await GetDailyInfo(context);
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          children: [
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}