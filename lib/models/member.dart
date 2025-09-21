import 'package:objectbox/objectbox.dart';

@Entity()
class Member {
  int id; // ObjectBox用の内部ID

  String dataTime;   // データ期
  String number;     // 登録番号
  String name;       // 氏名
  String kana3;      // かな3文字
  String blanch;     // 支部
  String rank;       // 階級
  String sex;        // 性別
  String age;        // 年齢
  String height;     // 身長
  String weight;     // 体重
  String blood;      // 血液型
  String winPointRate; // 勝率
  String winRate12;    // 2連対率
  String rankPast1;    // 前期ランク
  String rankPast2;    // 2期前ランク
  String rankPast3;    // 3期前ランク
  String birthplace;   // 出身地
  String photo;        // 写真URL

  Member({
    this.id = 0,
    required this.dataTime,
    required this.number,
    required this.name,
    required this.kana3,
    required this.blanch,
    required this.rank,
    required this.sex,
    required this.age,
    required this.height,
    required this.weight,
    required this.blood,
    required this.winPointRate,
    required this.winRate12,
    required this.rankPast1,
    required this.rankPast2,
    required this.rankPast3,
    required this.birthplace,
    required this.photo,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      dataTime: json['DataTime']?.toString() ?? '',
      number: json['Number']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      kana3: json['Kana3']?.toString() ?? '',
      blanch: json['Blanch']?.toString() ?? '',
      rank: json['Rank']?.toString() ?? '',
      sex: json['Sex']?.toString() ?? '',
      age: json['Age']?.toString() ?? '',
      height: json['Height']?.toString() ?? '',
      weight: json['Weight']?.toString() ?? '',
      blood: json['Blood']?.toString() ?? '',
      winPointRate: json['WinPointRate']?.toString() ?? '',
      winRate12: json['WinRate12']?.toString() ?? '',
      rankPast1: json['RankPast1']?.toString() ?? '',
      rankPast2: json['RankPast2']?.toString() ?? '',
      rankPast3: json['RankPast3']?.toString() ?? '',
      birthplace: json['Birthplace']?.toString() ?? '',
      photo: json['Photo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DataTime': dataTime,
      'Number': number,
      'Name': name,
      'Kana3': kana3,
      'Blanch': blanch,
      'Rank': rank,
      'Sex': sex,
      'Age': age,
      'Height': height,
      'Weight': weight,
      'Blood': blood,
      'WinPointRate': winPointRate,
      'WinRate12': winRate12,
      'RankPast1': rankPast1,
      'RankPast2': rankPast2,
      'RankPast3': rankPast3,
      'Birthplace': birthplace,
      'Photo': photo,
    };
  }
}
