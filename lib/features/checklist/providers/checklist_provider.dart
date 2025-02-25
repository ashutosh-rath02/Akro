import 'package:Akro/objectbox.g.dart';
import 'package:flutter/material.dart';
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
    try {
      state = [...objectBox.templateBox.getAll()];
    } catch (e) {
      debugPrint('Error loading templates: $e');
      state = [];
    }
  }

  void addTemplate(ChecklistTemplate template) {
    try {
      objectBox.templateBox.put(template);
      loadTemplates();
    } catch (e) {
      debugPrint('Error adding template: $e');
    }
  }

  void deleteTemplate(int id) {
    try {
      objectBox.templateBox.remove(id);
      loadTemplates();
    } catch (e) {
      debugPrint('Error deleting template: $e');
    }
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
    try {
      final existingChecks =
          objectBox.checkBox
              .query(DailyCheck_.templateId.equals(templateId))
              .build()
              .find();

      state = [...existingChecks];
    } catch (e) {
      debugPrint('Error loading checks: $e');
      state = [];
    }
  }

  void addCheck(DailyCheck check) {
    try {
      final existingCheckIndex = state.indexWhere(
        (c) => c.itemTitle == check.itemTitle,
      );

      if (existingCheckIndex >= 0) {
        check.id = state[existingCheckIndex].id;
      }

      objectBox.checkBox.put(check);
      loadChecks();
    } catch (e) {
      debugPrint('Error adding check: $e');
    }
  }

  void toggleCheck(int checkId) {
    try {
      final check = objectBox.checkBox.get(checkId);
      if (check != null) {
        check.isCompleted = !check.isCompleted;

        if (check.isCompleted) {
          check.completedAt = DateTime.now();
        } else {
          check.completedAt = null;
        }

        objectBox.checkBox.put(check);
        loadChecks();
      }
    } catch (e) {
      debugPrint('Error toggling check: $e');
    }
  }

  void clearChecks() {
    try {
      final checks =
          objectBox.checkBox
              .query(DailyCheck_.templateId.equals(templateId))
              .build()
              .find();

      for (final check in checks) {
        objectBox.checkBox.remove(check.id);
      }
      loadChecks();
    } catch (e) {
      debugPrint('Error clearing checks: $e');
    }
  }
}
