import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist_item.dart';
import '../repositories/checklist_repository.dart';

final checklistProvider =
    StateNotifierProvider<ChecklistNotifier, List<ChecklistItem>>((ref) {
      return ChecklistNotifier();
    });

class ChecklistNotifier extends StateNotifier<List<ChecklistItem>> {
  final _repository = ChecklistRepository();

  ChecklistNotifier() : super([]) {
    // Load initial data
    loadItems();
  }

  void loadItems() {
    state = _repository.getAll();
  }

  void addItem(ChecklistItem item) {
    _repository.add(item);
    loadItems(); // Reload to get the updated list
  }

  void updateItem(ChecklistItem item) {
    _repository.update(item);
    loadItems();
  }

  void deleteItem(int id) {
    _repository.delete(id);
    loadItems();
  }

  void toggleItemCompletion(int id) {
    final item = _repository.getById(id);
    if (item != null) {
      item.isCompleted = !item.isCompleted;
      item.completedAt = item.isCompleted ? DateTime.now() : null;
      _repository.update(item);
      loadItems();
    }
  }
}
