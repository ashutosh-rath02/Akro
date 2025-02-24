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
  String? _photoPath;
  bool _isCompleted = false;
  bool _isInitialized = false;

  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _formKey = GlobalKey();
  final GlobalKey _photoSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _descriptionController.text = widget.check.description ?? '';
          _photoPath = widget.check.photoPath;
          _isCompleted = widget.check.isCompleted;
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _isCapturing = true);

    try {
      final photoPath = await _photoService.capturePhoto(context: context);

      if (photoPath != null && mounted) {
        if (_photoPath != null) {
          await _photoService.deletePhoto(_photoPath!);
        }

        _updateCheckInDatabase(
          photoPath: photoPath,
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        setState(() {
          _photoPath = photoPath;
          _isCompleted = true;
          _isCapturing = false;
        });
      } else {
        if (mounted) {
          setState(() => _isCapturing = false);
        }
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing photo: ${e.toString()}')),
        );
        setState(() => _isCapturing = false);
      }
    }
  }

  void _toggleCompletion() {
    final newCompletionStatus = !_isCompleted;

    _updateCheckInDatabase(
      isCompleted: newCompletionStatus,
      completedAt: newCompletionStatus ? DateTime.now() : null,
    );

    setState(() {
      _isCompleted = newCompletionStatus;
    });
  }

  void _updateCheckInDatabase({
    String? photoPath,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    try {
      final updatedCheck = DailyCheck(
        templateId: widget.check.templateId,
        itemTitle: widget.check.itemTitle,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        photoPath: photoPath ?? _photoPath,
        isCompleted: isCompleted ?? _isCompleted,
        completedAt:
            completedAt ??
            (isCompleted == false ? null : widget.check.completedAt),
        createdAt: widget.check.createdAt,
      )..id = widget.check.id;

      ref
          .read(dailyChecksProvider(widget.check.templateId).notifier)
          .addCheck(updatedCheck);
    } catch (e) {
      debugPrint('Error updating check: $e');
    }
  }

  void _saveChanges() {
    _updateCheckInDatabase();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: ValueKey(
        'check_detail_${widget.check.id}_${_photoPath?.hashCode ?? 0}_${_isCompleted}_${DateTime.now().millisecondsSinceEpoch}',
      ),
      appBar: AppBar(
        title: RepaintBoundary(child: Text(widget.check.itemTitle)),
        actions: [
          RepaintBoundary(
            child: TextButton(
              onPressed: _saveChanges,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: RepaintBoundary(
        child: ListView(
          key: _formKey,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            RepaintBoundary(
              child: Card(
                key: _cardKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  _isCompleted
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.warning.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isCompleted ? Icons.check_circle : Icons.pending,
                              color:
                                  _isCompleted
                                      ? AppColors.success
                                      : AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 16),
                          RepaintBoundary(
                            child: Text(
                              _isCompleted ? 'Completed' : 'Pending',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isCompleted,
                            onChanged: (_) => _toggleCompletion(),
                            activeColor: AppColors.success,
                          ),
                        ],
                      ),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: RepaintBoundary(
                                child: Text(
                                  'You can mark this item as complete with or without a photo',
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
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            RepaintBoundary(
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 16),

            // Photo Section
            RepaintBoundary(
              child: Card(
                key: _photoSectionKey,
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
                        label: RepaintBoundary(
                          child: Text(
                            _photoPath == null ? 'Take Photo' : 'Retake Photo',
                          ),
                        ),
                      ),
                      if (_photoPath == null) ...[
                        const SizedBox(height: 8),
                        const Center(
                          child: RepaintBoundary(
                            child: Text(
                              '(Optional) Photo provides visual verification',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
