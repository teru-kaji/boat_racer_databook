/// DataTime（例: 20261）を期（例: 2025/11）に変換
String formatDataTimePeriod(String dataTime) {
  if (dataTime.length != 5) return dataTime;

  final int year = int.tryParse(dataTime.substring(0, 4)) ?? 0;
  final int term = int.tryParse(dataTime.substring(4)) ?? 0;

  if (year == 0 || term == 0) return dataTime;

  if (term == 1) {
    // 審査期間は前年の後期
    return '${year - 1}年後期';
  } else if (term == 2) {
    // 審査期間は当年の前期
    return '${year}年前期';
  } else {
    return dataTime;
  }
}

/// dataTime 文字列（例: 20261）を期間の [開始日, 終了日] に変換する
List<String> dataTimeToTerm(String dataTime) {
  if (dataTime.length != 5) {
    return ['', ''];
  }
  final year = int.tryParse(dataTime.substring(0, 4));
  final term = int.tryParse(dataTime.substring(4, 5));

  if (year == null || term == null) {
    return ['', ''];
  }

  if (term == 1) {
    // 適用期がYYYY年前期の場合、審査期間は YYYY-1年後期 (YYYY-1/11/01 〜 YYYY/04/30)
    // ユーザーの指摘: 20261 -> 2025/5/1 〜 2025/10/31
    // これは「2026年前期」の級別審査期間が「2025年後期」であることを意味している？
    // ユーザーの例を正とする
    final prevYear = year - 1;
    return ['$prevYear/05/01', '$prevYear/10/31'];

  } else if (term == 2) {
    // 適用期がYYYY年後期の場合、審査期間は YYYY年前期 (YYYY/05/01 〜 YYYY/10/31)
    final prevYear = year - 1;
    return ['$prevYear/11/01', '$year/04/30'];

  } else {
    return ['', ''];
  }
}
