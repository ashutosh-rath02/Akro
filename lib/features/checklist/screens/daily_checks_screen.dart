import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist_template.dart';
import '../models/daily_check.dart';
import '../providers/checklist_provider.dart';
import 'check_detail_screen.dart';
import '../../../core/constants/app_colors.dart';

class DailyChecksScreen extends ConsumerWidget {
  final ChecklistTemplate template;

  const DailyChecksScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checks = ref.watch(dailyChecksProvider(template.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: RepaintBoundary(child: Text(template.name)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(dailyChecksProvider(template.id).notifier).clearChecks();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: template.items.length,
              itemBuilder: (context, index) {
                final itemTitle = template.items[index];
                final check = checks.firstWhere(
                  (check) => check.itemTitle == itemTitle,
                  orElse:
                      () => DailyCheck(
                        templateId: template.id,
                        itemTitle: itemTitle,
                      ),
                );

                return DailyCheckCard(check: check);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  RepaintBoundary(
                    child: Text(
                      '${checks.where((c) => c.isCompleted).length}/${template.items.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value:
                          template.items.isEmpty
                              ? 0
                              : checks.where((c) => c.isCompleted).length /
                                  template.items.length,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.success,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RepaintBoundary(
                child: Text(
                  '${checks.where((c) => c.isCompleted).length} of ${template.items.length} items completed',
                  style: const TextStyle(color: AppColors.success),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyCheckCard extends ConsumerWidget {
  final DailyCheck check;

  const DailyCheckCard({super.key, required this.check});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckDetailScreen(check: check),
                ),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Toggle completion status
                    ref
                        .read(dailyChecksProvider(check.templateId).notifier)
                        .toggleCheck(check.id);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          check.isCompleted
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1),
                    ),
                    child: Icon(
                      check.isCompleted
                          ? Icons.check_circle
                          : Icons.timer_outlined,
                      size: 16,
                      color:
                          check.isCompleted
                              ? AppColors.success
                              : AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RepaintBoundary(
                    child: Text(
                      check.itemTitle,
                      style: TextStyle(
                        fontSize: 16,
                        decoration:
                            check.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
