import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class AddChecklistItemScreen extends StatefulWidget {
  const AddChecklistItemScreen({super.key});

  @override
  State<AddChecklistItemScreen> createState() => _AddChecklistItemScreenState();
}

class _AddChecklistItemScreenState extends State<AddChecklistItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement save functionality
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'Save Item', onPressed: _saveItem),
            ],
          ),
        ),
      ),
    );
  }
}
