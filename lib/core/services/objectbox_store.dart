import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import '../../features/checklist/models/checklist_template.dart';
import '../../features/checklist/models/daily_check.dart';

class ObjectBox {
  late final Store store;
  late final Box<ChecklistTemplate> templateBox;
  late final Box<DailyCheck> checkBox;

  ObjectBox._create(this.store) {
    templateBox = Box<ChecklistTemplate>(store);
    checkBox = Box<DailyCheck>(store);
  }

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docsDir.path, "obx-checklist"),
    );
    return ObjectBox._create(store);
  }
}

late ObjectBox objectBox;
