import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist_template.dart';
import '../models/daily_check.dart';
import '../providers/checklist_provider.dart';
import 'check_detail_screen.dart';
import '../../../core/constants/app_colors.dart';

class TemplateChecksScreen extends ConsumerWidget {
  final ChecklistTemplate template;

  const TemplateChecksScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checksProvider = dailyChecksProvider(template.id);
    final checks = ref.watch(checksProvider);

    final completedChecks = checks.where((check) => check.isCompleted).toList();
    final completedCount = completedChecks.length;
    final totalCount = template.items.length;

    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      key: ValueKey(
        'template_checks_${template.id}_${completedCount}_$totalCount',
      ),
      appBar: AppBar(
        title: RepaintBoundary(child: Text(template.name)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTemplateInfo(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: template.items.length,
        itemBuilder: (context, index) {
          final itemTitle = template.items[index];
          final check = checks.firstWhere(
            (check) => check.itemTitle == itemTitle,
            orElse:
                () => DailyCheck(templateId: template.id, itemTitle: itemTitle),
          );

          return CheckItemCard(
            key: ValueKey('check_${check.id}_${check.isCompleted}'),
            check: check,
          );
        },
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
                      '$completedCount/$totalCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
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
                  '$completedCount of $totalCount items completed',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplateInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  child: Text(
                    'About ${template.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RepaintBoundary(
                  child: Text('${template.items.length} items to check'),
                ),
                const SizedBox(height: 8),
                const RepaintBoundary(
                  child: Text('Items will be reset after 24 hours'),
                ),
              ],
            ),
          ),
    );
  }
}

class CheckItemCard extends ConsumerWidget {
  final DailyCheck check;

  const CheckItemCard({super.key, required this.check});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckDetailScreen(check: check),
              ),
            ).then((_) {
              ref.refresh(dailyChecksProvider(check.templateId));
            }),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Toggle the completion state
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RepaintBoundary(
                      child: Text(
                        check.itemTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration:
                              check.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                    ),
                    if (check.photoPath != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: RepaintBoundary(
                          child: Text(
                            'Photo verified',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (check.isCompleted)
                RepaintBoundary(
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
