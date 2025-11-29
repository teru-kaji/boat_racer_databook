// lib/splash_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'objectbox.dart';
import 'models/member.dart';
import 'member_list_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // データベースとJSONの読み込み
    final dir = await getApplicationDocumentsDirectory();
    objectbox = await ObjectBox.create(directory: dir.path);
    await _importJsonIfEmpty();

    // 読み込み完了後に画面遷移
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MemberListPage()),
      );
    }
  }

  Future<void> _importJsonIfEmpty() async {
    if (objectbox.memberBox.isEmpty()) {
      final jsonString = await rootBundle.loadString('assets/members.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      final members = jsonData.map((e) => Member.fromJson(e)).toList();
      objectbox.memberBox.putMany(members);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('データを読み込んでいます...'),
          ],
        ),
      ),
    );
  }
}
