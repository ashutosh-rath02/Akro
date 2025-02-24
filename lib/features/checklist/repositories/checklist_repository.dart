// lib/features/checklist/repositories/checklist_repository.dart
import 'package:Akro/objectbox.g.dart';
import '../models/checklist_template.dart';
import '../models/daily_check.dart';
import '../../../core/services/objectbox_store.dart';

class ChecklistRepository {
  final Box<ChecklistTemplate> _templateBox = objectBox.templateBox;
  final Box<DailyCheck> _checkBox = objectBox.checkBox;

  // Template operations
  List<ChecklistTemplate> getAllTemplates() => _templateBox.getAll();

  int addTemplate(ChecklistTemplate template) => _templateBox.put(template);

  bool deleteTemplate(int id) => _templateBox.remove(id);

  ChecklistTemplate? getTemplateById(int id) => _templateBox.get(id);

  // Daily check operations
  List<DailyCheck> getChecksByTemplate(int templateId) {
    return _checkBox
        .query(DailyCheck_.templateId.equals(templateId))
        .build()
        .find();
  }

  int addCheck(DailyCheck check) => _checkBox.put(check);

  bool deleteCheck(int id) => _checkBox.remove(id);

  bool updateCheck(DailyCheck check) => _checkBox.put(check) > 0;

  // Clear old checks (older than 24 hours)
  void clearOldChecks() {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    final oldChecks =
        _checkBox
            .query(
              DailyCheck_.createdAt.lessThan(yesterday.millisecondsSinceEpoch),
            )
            .build()
            .find();

    for (final check in oldChecks) {
      _checkBox.remove(check.id);
    }
  }
}
