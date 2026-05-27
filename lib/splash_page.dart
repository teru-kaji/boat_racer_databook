// lib/splash_page.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
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

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('--- App Initialization Start ---');
      final docDir = await getApplicationDocumentsDirectory();

      // 1. ObjectBox を開く
      objectbox = await ObjectBox.create(directory: docDir.path);

      // 2. データベースが空の場合のみ JSON インポートを実行
      if (objectbox.memberBox.isEmpty()) {
        await _importJson();
      } else {
        debugPrint('Ready. Database has ${objectbox.memberBox.count()} records.');
      }

      debugPrint('--- App Initialization Complete ---');
    } catch (e, stack) {
      debugPrint('CRITICAL ERROR during initialization: $e');
      debugPrint('$stack');
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MemberListPage()),
      );
    }
  }

  Future<void> _importJson() async {
    try {
      debugPrint('Starting import from members.json...');
      final stopwatch = Stopwatch()..start();

      // 270MBのファイルをロード
      final jsonString = await rootBundle.loadString('assets/members.json');
      debugPrint('members.json loaded. Parsing...');

      // 重いパース処理をバックグラウンド（別スレッド）で実行
      final List<Member> members = await compute(_parseMembersRobust, jsonString);
      debugPrint('Parsed ${members.length} members.');

      if (members.isNotEmpty) {
        debugPrint('Saving to ObjectBox...');
        objectbox.memberBox.putMany(members);
      }
      
      stopwatch.stop();
      debugPrint('Import finished in ${stopwatch.elapsed.inSeconds} seconds.');
    } catch (e) {
      debugPrint('JSON import failed: $e');
    }
  }

  // 巨大なJSON文字列を安全に解析する（バックグラウンド実行）
  static List<Member> _parseMembersRobust(String text) {
    // 最初と最後のブラケット位置を特定してゴミ文字を除外
    final int start = text.indexOf('[');
    final int end = text.lastIndexOf(']');
    if (start == -1 || end == -1 || start >= end) return [];
    
    final String jsonPart = text.substring(start, end + 1);
    final List<dynamic> jsonData = jsonDecode(jsonPart);
    return jsonData.map((e) => Member.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animationController,
              child: Image.asset(
                'assets/icon_foreground.png',
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) => const CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'データを読み込んでいます...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            const Text(
              '※初回のみ時間がかかる場合があります',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
