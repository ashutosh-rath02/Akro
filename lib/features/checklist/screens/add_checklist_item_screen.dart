import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/services/photo_service.dart';
import '../providers/checklist_provider.dart';
import '../models/daily_check.dart';
import '../../../core/constants/app_colors.dart';

class AddChecklistItemScreen extends ConsumerStatefulWidget {
  final int templateId;

  const AddChecklistItemScreen({super.key, required this.templateId});

  @override
  ConsumerState<AddChecklistItemScreen> createState() =>
      _AddChecklistItemScreenState();
}

class _AddChecklistItemScreenState
    extends ConsumerState<AddChecklistItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoService = PhotoService();
  String? _photoPath;
  bool _isCapturing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _isCapturing = true);
    try {
      final photoPath = await _photoService.capturePhoto(context: context);

      if (mounted) {
        setState(() {
          _photoPath = photoPath;
        });
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing photo: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _saveItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      final check = DailyCheck(
        templateId: widget.templateId,
        itemTitle: _titleController.text,
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
        photoPath: _photoPath,
        isCompleted: _photoPath != null,
      );

      ref.read(dailyChecksProvider(widget.templateId).notifier).addCheck(check);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('add_item_screen_${_photoPath ?? 'no_photo'}'),
      appBar: AppBar(title: const Text('Add New Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Item Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_photoPath != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_photoPath!),
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
                          _photoPath == null ? 'Take Photo' : 'Retake Photo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Save Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
