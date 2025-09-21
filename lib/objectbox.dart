import 'objectbox.g.dart';
import 'models/member.dart';

class ObjectBox {
  late final Store store;
  late final Box<Member> memberBox;

  ObjectBox._create(this.store) {
    memberBox = Box<Member>(store);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }
}
