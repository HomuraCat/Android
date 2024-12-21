import 'package:flutter/material.dart';

class UserAgreementPage extends StatefulWidget {
  @override
  _UserAgreementPageState createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<UserAgreementPage> {
  String _content = "加载中...";

  @override
  void initState() {
    super.initState();
    _loadAgreement();
  }
  Future<void> _loadAgreement() async {
    try {
      String content = await DefaultAssetBundle.of(context)
          .loadString('assets/document/用户协议.txt');
      setState(() {
        _content = content;
      });
    } catch (e) {
      setState(() {
        _content = "加载用户协议失败，请稍后重试。";
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户协议'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            _content,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String _content = "加载中...";

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }
  Future<void> _loadPolicy() async {
    try {
      String content = await DefaultAssetBundle.of(context)
          .loadString('assets/document/隐私政策.txt');
      setState(() {
        _content = content;
      });
    } catch (e) {
      setState(() {
        _content = "加载隐私政策失败，请稍后重试。";
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('隐私政策'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            _content,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}