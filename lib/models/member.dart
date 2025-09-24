import 'package:objectbox/objectbox.dart';

@Entity()
class Member {
  @Id(assignable: true)
  int id;

  // 基本情報
  String? dataTime;
  String? number;
  String? name;
  String? nameKana;
  String? kana;
  String? kana2;
  String? kana3;
  String? blanch;
  String? rank;
  String? wBirthday;
  String? gBirthday;
  String? sex;
  String? age;
  String? height;
  String? weight;
  String? blood;
  String? birthplace;
  String? photo;

  // 成績関連
  String? winPointRate;
  String? winRate12;
  String? firstPlaceCount;
  String? secondPlaceCount;
  String? numberOfRace;
  String? numberOfFinals;
  String? numberOfWins;
  String? startTiming;

  // 過去ランク・能力値
  String? rankPast1;
  String? rankPast2;
  String? rankPast3;
  String? pastAbilityScore;
  String? lastAbilityScore;

  // データ年度・期
  String? dataYear;
  String? dataSeason;
  String? startDate;
  String? endDate;
  String? generation;

  // ===== コース別 =====
  // 出走数
  String? numberOfEntries1;
  String? numberOfEntries2;
  String? numberOfEntries3;
  String? numberOfEntries4;
  String? numberOfEntries5;
  String? numberOfEntries6;

  // 複勝率
  String? winRate121;
  String? winRate122;
  String? winRate123;
  String? winRate124;
  String? winRate125;
  String? winRate126;

  // ST平均
  String? startTime1;
  String? startTime2;
  String? startTime3;
  String? startTime4;
  String? startTime5;
  String? startTime6;

  // 1着回数
  String? firstPlace1;
  String? firstPlace2;
  String? firstPlace3;
  String? firstPlace4;
  String? firstPlace5;
  String? firstPlace6;

  // 2着回数
  String? secondPlace1;
  String? secondPlace2;
  String? secondPlace3;
  String? secondPlace4;
  String? secondPlace5;
  String? secondPlace6;

  // 3着回数
  String? thirdPlace1;
  String? thirdPlace2;
  String? thirdPlace3;
  String? thirdPlace4;
  String? thirdPlace5;
  String? thirdPlace6;

  Member({
    this.id = 0,
    this.dataTime,
    this.number,
    this.name,
    this.nameKana,
    this.kana,
    this.kana2,
    this.kana3,
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
    this.winPointRate,
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
    this.dataSeason,
    this.startDate,
    this.endDate,
    this.generation,
    this.numberOfEntries1,
    this.numberOfEntries2,
    this.numberOfEntries3,
    this.numberOfEntries4,
    this.numberOfEntries5,
    this.numberOfEntries6,
    this.winRate121,
    this.winRate122,
    this.winRate123,
    this.winRate124,
    this.winRate125,
    this.winRate126,
    this.startTime1,
    this.startTime2,
    this.startTime3,
    this.startTime4,
    this.startTime5,
    this.startTime6,
    this.firstPlace1,
    this.firstPlace2,
    this.firstPlace3,
    this.firstPlace4,
    this.firstPlace5,
    this.firstPlace6,
    this.secondPlace1,
    this.secondPlace2,
    this.secondPlace3,
    this.secondPlace4,
    this.secondPlace5,
    this.secondPlace6,
    this.thirdPlace1,
    this.thirdPlace2,
    this.thirdPlace3,
    this.thirdPlace4,
    this.thirdPlace5,
    this.thirdPlace6,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: int.tryParse(json['Id']?.toString() ?? '') ?? 0,
      dataTime: json['DataTime']?.toString(),
      number: json['Number']?.toString(),
      name: json['Name']?.toString(),
      nameKana: json['NameKana']?.toString(),
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
      winPointRate: json['WinPointRate']?.toString(),
      winRate12: json['WinRate12']?.toString(),
      firstPlaceCount: json['1stPlaceCount']?.toString(),
      secondPlaceCount: json['2ndPlaceCount']?.toString(),
      numberOfRace: json['NumberOfRace']?.toString(),
      numberOfFinals: json['NumberOfFinals']?.toString(),
      numberOfWins: json['NumberOfWins']?.toString(),
      startTiming: json['StartTiming']?.toString(),
      rankPast1: json['RankPast1']?.toString(),
      rankPast2: json['RankPast2']?.toString(),
      rankPast3: json['RankPast3']?.toString(),
      pastAbilityScore: json['PastAbilityScore']?.toString(),
      lastAbilityScore: json['LastAbilityScore']?.toString(),
      dataYear: json['DataYear']?.toString(),
      dataSeason: json['DataSeason']?.toString(),
      startDate: json['StartDate']?.toString(),
      endDate: json['EndDate']?.toString(),
      generation: json['Genetation']?.toString(),
      numberOfEntries1: json['NumberOfEntries#1']?.toString(),
      numberOfEntries2: json['NumberOfEntries#2']?.toString(),
      numberOfEntries3: json['NumberOfEntries#3']?.toString(),
      numberOfEntries4: json['NumberOfEntries#4']?.toString(),
      numberOfEntries5: json['NumberOfEntries#5']?.toString(),
      numberOfEntries6: json['NumberOfEntries#6']?.toString(),
      winRate121: json['WinRate12#1']?.toString(),
      winRate122: json['WinRate12#2']?.toString(),
      winRate123: json['WinRate12#3']?.toString(),
      winRate124: json['WinRate12#4']?.toString(),
      winRate125: json['WinRate12#5']?.toString(),
      winRate126: json['WinRate12#6']?.toString(),
      startTime1: json['StartTime#1']?.toString(),
      startTime2: json['StartTime#2']?.toString(),
      startTime3: json['StartTime#3']?.toString(),
      startTime4: json['StartTime#4']?.toString(),
      startTime5: json['StartTime#5']?.toString(),
      startTime6: json['StartTime#6']?.toString(),
      firstPlace1: json['1stPlace#1']?.toString(),
      firstPlace2: json['1stPlace#2']?.toString(),
      firstPlace3: json['1stPlace#3']?.toString(),
      firstPlace4: json['1stPlace#4']?.toString(),
      firstPlace5: json['1stPlace#5']?.toString(),
      firstPlace6: json['1stPlace#6']?.toString(),
      secondPlace1: json['2ndPlace#1']?.toString(),
      secondPlace2: json['2ndPlace#2']?.toString(),
      secondPlace3: json['2ndPlace#3']?.toString(),
      secondPlace4: json['2ndPlace#4']?.toString(),
      secondPlace5: json['2ndPlace#5']?.toString(),
      secondPlace6: json['2ndPlace#6']?.toString(),
      thirdPlace1: json['3rdPlace#1']?.toString(),
      thirdPlace2: json['3rdPlace#2']?.toString(),
      thirdPlace3: json['3rdPlace#3']?.toString(),
      thirdPlace4: json['3rdPlace#4']?.toString(),
      thirdPlace5: json['3rdPlace#5']?.toString(),
      thirdPlace6: json['3rdPlace#6']?.toString(),
    );
  }
}
