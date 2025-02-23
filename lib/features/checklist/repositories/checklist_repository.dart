import 'package:objectbox/objectbox.dart';

import '../models/checklist_item.dart';
import '../../../core/services/objectbox_store.dart';

class ChecklistRepository {
  final Box<ChecklistItem> _box = objectBox.checklistBox;

  // Add a new item
  int add(ChecklistItem item) {
    return _box.put(item);
  }

  // Get all items
  List<ChecklistItem> getAll() {
    return _box.getAll();
  }

  // Update an item
  bool update(ChecklistItem item) {
    return _box.put(item) > 0;
  }

  // Delete an item
  bool delete(int id) {
    return _box.remove(id);
  }

  // Get item by id
  ChecklistItem? getById(int id) {
    return _box.get(id);
  }

  // Mark item as completed
  bool markAsCompleted(int id) {
    final item = _box.get(id);
    if (item != null) {
      item.isCompleted = true;
      item.completedAt = DateTime.now();
      return _box.put(item) > 0;
    }
    return false;
  }
}
