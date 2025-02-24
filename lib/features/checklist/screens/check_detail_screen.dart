import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/daily_check.dart';
import '../providers/checklist_provider.dart';
import '../../../core/services/photo_service.dart';
import '../../../core/constants/app_colors.dart';

class CheckDetailScreen extends ConsumerStatefulWidget {
  final DailyCheck check;

  const CheckDetailScreen({super.key, required this.check});

  @override
  ConsumerState<CheckDetailScreen> createState() => _CheckDetailScreenState();
}

class _CheckDetailScreenState extends ConsumerState<CheckDetailScreen> {
  final _descriptionController = TextEditingController();
  final _photoService = PhotoService();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.check.description ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _isCapturing = true);
    try {
      final photoPath = await _photoService.capturePhoto();
      if (photoPath != null) {
        if (widget.check.photoPath != null) {
          await _photoService.deletePhoto(widget.check.photoPath!);
        }

        final updatedCheck = DailyCheck(
          templateId: widget.check.templateId,
          itemTitle: widget.check.itemTitle,
          description: _descriptionController.text,
          photoPath: photoPath,
          isCompleted: true,
          completedAt: DateTime.now(),
        )..id = widget.check.id;

        ref
            .read(dailyChecksProvider(widget.check.templateId).notifier)
            .addCheck(updatedCheck);
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _saveChanges() {
    final updatedCheck = DailyCheck(
      templateId: widget.check.templateId,
      itemTitle: widget.check.itemTitle,
      description: _descriptionController.text,
      photoPath: widget.check.photoPath,
      isCompleted: widget.check.isCompleted,
      completedAt: widget.check.completedAt,
    )..id = widget.check.id;

    ref
        .read(dailyChecksProvider(widget.check.templateId).notifier)
        .addCheck(updatedCheck);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.check.itemTitle),
        actions: [
          TextButton(onPressed: _saveChanges, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          widget.check.isCompleted
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.check.isCompleted
                          ? Icons.check_circle
                          : Icons.pending,
                      color:
                          widget.check.isCompleted
                              ? AppColors.success
                              : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.check.isCompleted ? 'Completed' : 'Pending',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Photo Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.check.photoPath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(widget.check.photoPath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: _isCapturing ? null : _takePhoto,
                    icon:
                        _isCapturing
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.camera_alt),
                    label: Text(
                      widget.check.photoPath == null
                          ? 'Take Photo'
                          : 'Retake Photo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
