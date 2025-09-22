// lib/objectbox.dart
import 'objectbox.g.dart';
import 'models/member.dart';

class ObjectBox {
  late final Store store;
  late final Box<Member> memberBox;

  ObjectBox._(this.store) {
    memberBox = Box<Member>(store);
  }

  // /// 明示したディレクトリにストアを作成/オープンする
  // static Future<ObjectBox> create({required String directory}) async {
  //   final store = openStore(directory: directory);
  //   return ObjectBox._(store);
  // }

  /// 明示したディレクトリにストアを作成/オープンする
  static Future<ObjectBox> create({required String directory}) async {
    // ★ ここを await するのがポイント！
    final store = await openStore(directory: directory);
    return ObjectBox._(store);
  }

}
