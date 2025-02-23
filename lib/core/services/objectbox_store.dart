import 'package:Akro/features/checklist/models/checklist_item.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store store;

  /// A Box of checklist items.
  late final Box<ChecklistItem> checklistBox;

  ObjectBox._create(this.store) {
    checklistBox = store.box<ChecklistItem>();
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
      final store = await openStore(
        directory: p.join(docsDir.path, "obx-checklist"),
      );
      return ObjectBox._create(store);
    } catch (e) {
      print('Failed to create ObjectBox store: $e');
      rethrow;
    }
  }
}

late ObjectBox objectBox;
