import 'package:Akro/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist_template.dart';
import '../models/daily_check.dart';
import '../../../core/services/objectbox_store.dart';

final templatesProvider =
    StateNotifierProvider<TemplatesNotifier, List<ChecklistTemplate>>((ref) {
      return TemplatesNotifier();
    });

class TemplatesNotifier extends StateNotifier<List<ChecklistTemplate>> {
  TemplatesNotifier() : super([]) {
    loadTemplates();
  }

  void loadTemplates() {
    state = objectBox.templateBox.getAll();
  }

  void addTemplate(ChecklistTemplate template) {
    objectBox.templateBox.put(template);
    loadTemplates();
  }

  void deleteTemplate(int id) {
    objectBox.templateBox.remove(id);
    loadTemplates();
  }
}

final dailyChecksProvider =
    StateNotifierProvider.family<DailyChecksNotifier, List<DailyCheck>, int>((
      ref,
      templateId,
    ) {
      return DailyChecksNotifier(templateId);
    });

class DailyChecksNotifier extends StateNotifier<List<DailyCheck>> {
  final int templateId;

  DailyChecksNotifier(this.templateId) : super([]) {
    loadChecks();
  }

  void loadChecks() {
    state =
        objectBox.checkBox
            .query(DailyCheck_.templateId.equals(templateId))
            .build()
            .find();
  }

  void addCheck(DailyCheck check) {
    objectBox.checkBox.put(check);
    loadChecks();
  }

  void toggleCheck(int checkId) {
    final check = objectBox.checkBox.get(checkId);
    if (check != null) {
      check.isCompleted = !check.isCompleted;
      check.completedAt = check.isCompleted ? DateTime.now() : null;
      objectBox.checkBox.put(check);
      loadChecks();
    }
  }

  void clearChecks() {
    final checks =
        objectBox.checkBox
            .query(DailyCheck_.templateId.equals(templateId))
            .build()
            .find();

    for (final check in checks) {
      objectBox.checkBox.remove(check.id);
    }
    loadChecks();
  }
}
