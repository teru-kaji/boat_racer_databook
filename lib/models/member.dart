// lib/models/member.dart
import 'package:objectbox/objectbox.dart';

/// ObjectBox エンティティ
/// - UI/検索側で使用している nameKana / scoreRate を「実フィールド」として定義
/// - members.json の主要フィールドは可能な範囲で保持
@Entity()
class Member {
  @Id(assignable: true)
  int id;

  // ===== 検索/UIで使う主要フィールド =====
  String? number;       // Number
  String? name;         // Name
  String? nameKana;     // ← UI/検索が参照（Kana2 相当・全角カナを想定）
  String? kana3;        // ひらがな相当（必要に応じて検索対象にしてもOK）
  String? dataSeason;   // DataSeason（期）
  double? scoreRate;    // ← UIが参照（WinPointRate を流し込み）

  // ===== その他: JSON由来の主な属性 =====
  String? dataTime;     // DataTime
  String? kana;         // Kana（半角カナ）
  String? kana2;        // Kana2（全角カナ）
  String? blanch;       // 支部 (Blanch)
  String? rank;         // Rank
  String? wBirthday;    // 和暦生年月日 (WBirthday)
  String? gBirthday;    // 西暦生年月日 (GBirthday)
  String? sex;          // Sex (1=男, 2=女)
  String? age;     // 既存ストア互換：String
  String? height;  // 既存ストア互換：String
  String? weight;  // 既存ストア互換：String
  String? blood;        // Blood
  String? birthplace;   // Birthplace
  String? photo;        // Photo URL

  // 成績/統計
  String? winRate12;      // ← 既存DBに合わせる
  int? firstPlaceCount;     // 1着回数
  int? secondPlaceCount;    // 2着回数
  int? numberOfRace;        // 出走数
  int? numberOfFinals;      // 優出回数
  int? numberOfWins;        // 優勝回数
  double? startTiming;      // ST平均 (StartTiming)

  // ランク履歴/能力
  String? rankPast1;
  String? rankPast2;
  String? rankPast3;
  int? pastAbilityScore;
  int? lastAbilityScore;

  // データ期間など
  String? dataYear;
  String? startDate;
  String? endDate;
  String? generation; // Genetation（原文の綴りに合わせて保持）

  // ===== インデックス（検索高速化） =====
  @Index()
  String? get idx_number => number;

  @Index()
  String? get idx_name => name;

  @Index()
  String? get idx_nameKana => nameKana;

  @Index()
  String? get idx_kana3 => kana3;

  @Index()
  String? get idx_dataSeason => dataSeason;

  Member({
    this.id = 0,
    this.number,
    this.name,
    this.nameKana,
    this.kana3,
    this.dataSeason,
    this.scoreRate,
    this.dataTime,
    this.kana,
    this.kana2,
    this.blanch,
    this.rank,
    this.wBirthday,
    this.gBirthday,
    this.sex,
    this.age,
    this.height,
    this.weight,
    this.blood,
    this.birthplace,
    this.photo,
    this.winRate12,
    this.firstPlaceCount,
    this.secondPlaceCount,
    this.numberOfRace,
    this.numberOfFinals,
    this.numberOfWins,
    this.startTiming,
    this.rankPast1,
    this.rankPast2,
    this.rankPast3,
    this.pastAbilityScore,
    this.lastAbilityScore,
    this.dataYear,
    this.startDate,
    this.endDate,
    this.generation,
  });

  // ===== JSON 取込み =====
  factory Member.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final sv = v.trim().replaceAll('%', '');
        return double.tryParse(sv);
      }
      return null;
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    // WinPointRate -> scoreRate（UIで参照するためエイリアスとして保持）
    final winPointRate = parseDouble(json['WinPointRate']);

    return Member(
      id: parseInt(json['Id']) ?? 0,
      dataTime: json['DataTime']?.toString(),
      number: json['Number']?.toString(),
      name: json['Name']?.toString(),
      // 可能なら NameKana を最優先 → 無ければ Kana2（全角） → 無ければ Kana（半角）
      nameKana: (json['NameKana'] ?? json['Kana2'] ?? json['Kana'])?.toString(),
      // そのまま別名も保持（必要なら UI からも使える）
      kana: json['Kana']?.toString(),
      kana2: json['Kana2']?.toString(),
      kana3: json['Kana3']?.toString(),
      blanch: json['Blanch']?.toString(),
      rank: json['Rank']?.toString(),
      wBirthday: json['WBirthday']?.toString(),
      gBirthday: json['GBirthday']?.toString(),
      sex: json['Sex']?.toString(),
      age: json['Age']?.toString(),
      height: json['Height']?.toString(),
      weight: json['Weight']?.toString(),
      blood: json['Blood']?.toString(),
      birthplace: json['Birthplace']?.toString(),
      photo: json['Photo']?.toString(),
      scoreRate: winPointRate,                       // ← ここでエイリアス設定
      winRate12: json['WinRate12']?.toString(),
      firstPlaceCount: parseInt(json['1stPlaceCount']),
      secondPlaceCount: parseInt(json['2ndPlaceCount']),
      numberOfRace: parseInt(json['NumberOfRace']),
      numberOfFinals: parseInt(json['NumberOfFinals']),
      numberOfWins: parseInt(json['NumberOfWins']),
      startTiming: parseDouble(json['StartTiming']),
      rankPast1: json['RankPast1']?.toString(),
      rankPast2: json['RankPast2']?.toString(),
      rankPast3: json['RankPast3']?.toString(),
      pastAbilityScore: parseInt(json['PastAbilityScore']),
      lastAbilityScore: parseInt(json['LastAbilityScore']),
      dataYear: json['DataYear']?.toString(),
      dataSeason: json['DataSeason']?.toString(),
      startDate: json['StartDate']?.toString(),
      endDate: json['EndDate']?.toString(),
      generation: json['Genetation']?.toString(),
    );
  }

  // ===== 逆変換（デバッグ/エクスポート用） =====
  Map<String, dynamic> toJson() => {
    'Id': id,
    'Number': number,
    'Name': name,
    'NameKana': nameKana,
    'Kana': kana,
    'Kana2': kana2,
    'Kana3': kana3,
    'Blanch': blanch,
    'Rank': rank,
    'WBirthday': wBirthday,
    'GBirthday': gBirthday,
    'Sex': sex,
    'Age': age,
    'Height': height,
    'Weight': weight,
    'Blood': blood,
    'Birthplace': birthplace,
    'Photo': photo,
    'WinPointRate': scoreRate, // エイリアスを戻す
    'WinRate12': winRate12,
    '1stPlaceCount': firstPlaceCount,
    '2ndPlaceCount': secondPlaceCount,
    'NumberOfRace': numberOfRace,
    'NumberOfFinals': numberOfFinals,
    'NumberOfWins': numberOfWins,
    'StartTiming': startTiming,
    'RankPast1': rankPast1,
    'RankPast2': rankPast2,
    'RankPast3': rankPast3,
    'PastAbilityScore': pastAbilityScore,
    'LastAbilityScore': lastAbilityScore,
    'DataYear': dataYear,
    'DataSeason': dataSeason,
    'StartDate': startDate,
    'EndDate': endDate,
    'Genetation': generation,
    'DataTime': dataTime,
  };
}
