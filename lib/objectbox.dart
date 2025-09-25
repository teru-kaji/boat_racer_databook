import 'objectbox.g.dart';
import 'models/member.dart';

/// どこからでも使えるグローバル
late ObjectBox objectbox;

class ObjectBox {
  late final Store store;
  late final Box<Member> memberBox;

  ObjectBox._create(this.store) {
    memberBox = Box<Member>(store);
  }

  /// ObjectBox の初期化（保存ディレクトリを指定）
  static Future<ObjectBox> create({required String directory}) async {
    final store = await openStore(directory: directory);
    return ObjectBox._create(store);
  }

  void close() => store.close();
}
