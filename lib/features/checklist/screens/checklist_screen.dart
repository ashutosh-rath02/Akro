import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/daily_check.dart';
import '../providers/checklist_provider.dart';
import 'add_checklist_item_screen.dart';
import 'check_detail_screen.dart';
import '../../../core/constants/app_colors.dart';

class ChecklistScreen extends ConsumerWidget {
  final int templateId;

  const ChecklistScreen({super.key, required this.templateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checks = ref.watch(dailyChecksProvider(templateId));

    return Scaffold(
      key: ValueKey('checklist_screen_$templateId'),
      appBar: AppBar(
        title: const RepaintBoundary(child: Text('Daily Checks')),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body:
          checks.isEmpty
              ? const Center(
                child: RepaintBoundary(
                  child: Text(
                    'No checks for today. Add some items to get started!',
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: checks.length,
                itemBuilder: (context, index) {
                  final check = checks[index];
                  return CheckItemCard(
                    key: ValueKey('check_item_${check.id}'),
                    check: check,
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddChecklistItemScreen(templateId: templateId),
              ),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  child: Text(
                    'Daily Checks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                RepaintBoundary(
                  child: Text('• Items will reset every 24 hours'),
                ),
                RepaintBoundary(
                  child: Text('• Take photos to verify completion'),
                ),
                RepaintBoundary(
                  child: Text('• All photos are stored securely'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (check.photoPath != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.file(
                  File(check.photoPath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
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
                        if (check.completedAt != null)
                          RepaintBoundary(
                            child: Text(
                              'Completed at ${_formatTime(check.completedAt!)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
