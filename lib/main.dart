import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'objectbox.dart';
import 'models/member.dart';
import 'objectbox.g.dart';
import 'package:fl_chart/fl_chart.dart';


late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();

  // 初回のみ members.json を読み込んで DB に投入
  if (objectbox.memberBox.isEmpty()) {
    final raw = await rootBundle.loadString('assets/members.json');
    final List<dynamic> jsonList = json.decode(raw);
    final members = jsonList.map((e) => Member.fromJson(e)).toList();
    objectbox.memberBox.putMany(members);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

Future<Map<String, ThemeData>> loadThemes() async {
  final string = await rootBundle.loadString('assets/themes.json');
  final map = json.decode(string) as Map<String, dynamic>;
  return map.map((key, val) {
    final v = val as Map<String, dynamic>;
    return MapEntry(
      key,
      ThemeData(
        colorScheme: ColorScheme(
          brightness:
          v['brightness'] == "dark" ? Brightness.dark : Brightness.light,
          primary: Color(int.parse(v['primary'].replaceFirst('#', '0xff'))),
          onPrimary: Colors.white,
          surface: Color(int.parse(v['surface'].replaceFirst('#', '0xff'))),
          onSurface:
          v['brightness'] == "dark" ? Colors.white70 : Colors.black87,
          secondary: Color(int.parse(v['primary'].replaceFirst('#', '0xff'))),
          onSecondary: v['brightness'] == "dark" ? Colors.white : Colors.black,
          error: Colors.red,
          onError: Colors.white,
          background: Color(
            int.parse(v['background'].replaceFirst('#', '0xff')),
          ),
          onBackground:
          v['brightness'] == "dark" ? Colors.white60 : Colors.black,
        ),
        scaffoldBackgroundColor: Color(
          int.parse(v['background'].replaceFirst('#', '0xff')),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(int.parse(v['inputFill'].replaceFirst('#', '0xff'))),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(
            int.parse(v['appBar'].replaceFirst('#', '0xff')),
          ),
        ),
        useMaterial3: true,
      ),
    );
  });
}

class _MyAppState extends State<MyApp> {
  Map<String, ThemeData> _themes = {};
  String _selectedThemeKey = "blue";

  @override
  void initState() {
    super.initState();
    loadThemes().then((themes) {
      setState(() {
        _themes = themes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_themes.isEmpty)
      return MaterialApp(home: Scaffold(body: CircularProgressIndicator()));
    return MaterialApp(
      theme: _themes[_selectedThemeKey]!,
      home: MemberSearchPage(
        selectedTheme: _selectedThemeKey,
        onThemeChanged: (key) {
          if (key != null) {
            setState(() {
              _selectedThemeKey = key;
            });
          }
        },
        themes: _themes,
      ),
    );
  }
}

class MemberSearchPage extends StatefulWidget {
  final String selectedTheme;
  final ValueChanged<String?> onThemeChanged;
  final Map<String, ThemeData> themes;
  final VoidCallback? onToggleTheme;
  final ThemeMode themeMode;

  MemberSearchPage({
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.themes,
    this.onToggleTheme,
    this.themeMode = ThemeMode.system,
  });

  @override
  _MemberSearchPageState createState() => _MemberSearchPageState();
}

class _MemberSearchPageState extends State<MemberSearchPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender = '';
  String? _selectedDataTime = '20252';
  String? _selectedRank = '';
  bool _searched = false;

  final List<Map<String, String>> _genderList = [
    {'label': '', 'value': ''},
    {'label': '男性', 'value': '1'},
    {'label': '女性', 'value': '2'},
  ];
  final List<String> _dataTimeList = [
    '',
    '20252',
    '20251',
    '20242',
    '20241',
    '20232',
    '20231',
    '20222',
    '20221',
    '20212',
    '20211',
    '20202',
    '20021',
  ];
  final List<String> _rankList = ['', 'A1', 'A2', 'B1', 'B2'];

  List<Member> _members = [];

  void _searchMembers() {
    final qb = objectbox.memberBox.query();

    if (_nameController.text.isNotEmpty) {
      qb.stringProperty(Member_.kana3)
          .contains(_nameController.text, caseSensitive: false);
    }
    if (_codeController.text.isNotEmpty) {
      qb.stringProperty(Member_.number)
          .startsWith(_codeController.text, caseSensitive: false);
    }
    if (_selectedGender != null && _selectedGender!.isNotEmpty) {
      qb.stringProperty(Member_.sex).equals(_selectedGender!);
    }
    if (_selectedDataTime != null && _selectedDataTime!.isNotEmpty) {
      qb.stringProperty(Member_.dataTime).equals(_selectedDataTime!);
    }
    if (_selectedRank != null && _selectedRank!.isNotEmpty) {
      qb.stringProperty(Member_.rank).equals(_selectedRank!);
    }

    final results = qb.build().find();

    setState(() {
      _members = results;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('選手検索（ObjectBox）'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: widget.selectedTheme,
              icon: Icon(Icons.color_lens),
              items: widget.themes.keys
                  .map(
                    (k) => DropdownMenuItem(
                  value: k,
                  child: Text(
                    k.toUpperCase(),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              )
                  .toList(),
              onChanged: widget.onThemeChanged,
              underline: SizedBox(),
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(labelText: '登録番号'),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: '氏名（ひらがな）'),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              width: 380,
              height: 40,
              child: ElevatedButton(
                onPressed: _searchMembers,
                child: Text('検索'),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return ListTile(
                  title: Text("${member.number} ${member.name}"),
                  subtitle: Text(
                      "Rank:${member.rank} 勝率:${member.winPointRate} 複勝率:${member.winRate12}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberDetailPage(member: member),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MemberDetailPage extends StatefulWidget {
  final Member member;

  MemberDetailPage({required this.member});

  @override
  _MemberDetailPageState createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  late Member _currentMember;
  late String _selectedDataTime;
  final List<String> _dataTimeList = [
    '',
    '20252',
    '20251',
    '20242',
    '20241',
    '20232',
    '20231',
    '20222',
    '20221',
    '20212',
    '20211',
    '20202',
    '20021',
  ];

  @override
  void initState() {
    super.initState();
    _currentMember = widget.member;
    _selectedDataTime = _currentMember.dataTime;
  }

  List<Member> getAllTermsForMember() {
    return objectbox.memberBox
        .query(Member_.number.equals(_currentMember.number))
        .build()
        .find()
      ..sort((a, b) => a.dataTime.compareTo(b.dataTime));
  }

  void _switchDataTime(String newDataTime) {
    final result = objectbox.memberBox
        .query(Member_.number.equals(_currentMember.number) &
    Member_.dataTime.equals(newDataTime))
        .build()
        .findFirst();

    if (result != null) {
      setState(() {
        _currentMember = result;
        _selectedDataTime = newDataTime;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("この期のデータはありません")));
    }
  }

  void _showAllTermsGraph() {
    final allData = getAllTermsForMember();
    if (allData.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MemberAllTermsGraphPage(allTermsData: allData, memberName: _currentMember.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${_currentMember.name}の詳細")),
      body: Column(
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedDataTime,
                items: _dataTimeList
                    .map((dt) => DropdownMenuItem(
                  value: dt,
                  child: Text(dt),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) _switchDataTime(val);
                },
              ),
              ElevatedButton.icon(
                onPressed: _showAllTermsGraph,
                icon: Icon(Icons.show_chart),
                label: Text("全期成績グラフ表示"),
              ),
            ],
          ),
          Image.network(_currentMember.photo, width: 120, height: 120),
          Text("登録番号: ${_currentMember.number}"),
          Text("期: ${_currentMember.dataTime}"),
          Text("ランク: ${_currentMember.rank}"),
          Text("勝率: ${_currentMember.winPointRate}"),
          Text("複勝率: ${_currentMember.winRate12}"),
        ],
      ),
    );
  }
}

class MemberAllTermsGraphPage extends StatelessWidget {
  final List<Member> allTermsData;
  final String memberName;

  MemberAllTermsGraphPage({required this.allTermsData, required this.memberName});

  @override
  Widget build(BuildContext context) {
    final winRateSpots = <FlSpot>[];
    final placeRateSpots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < allTermsData.length; i++) {
      final item = allTermsData[i];
      final winRate = double.tryParse(item.winPointRate) ?? 0;
      final placeRate = (double.tryParse(item.winRate12) ?? 0) * 100;
      winRateSpots.add(FlSpot(i.toDouble(), winRate));
      placeRateSpots.add(FlSpot(i.toDouble(), placeRate));
      labels.add(item.dataTime);
    }

    return Scaffold(
      appBar: AppBar(title: Text("$memberName 全期成績グラフ")),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: winRateSpots,
                    isCurved: false,
                    color: Colors.blue,
                  ),
                  LineChartBarData(
                    spots: placeRateSpots,
                    isCurved: false,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}