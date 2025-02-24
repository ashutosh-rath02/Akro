// lib/features/checklist/screens/add_template_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist_template.dart';
import '../providers/checklist_provider.dart';

class AddTemplateScreen extends ConsumerStatefulWidget {
  const AddTemplateScreen({super.key});

  @override
  ConsumerState<AddTemplateScreen> createState() => _AddTemplateScreenState();
}

class _AddTemplateScreenState extends ConsumerState<AddTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _itemsController = TextEditingController();
  String _selectedIcon = '0xe88a'; // Default icon code

  final List<String> _iconCodes = [
    '0xe88a', // home
    '0xe0c6', // business
    '0xe8f4', // kitchen
    '0xe8b4', // garage
    '0xe88e', // office
    '0xe1b1', // bedroom
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  void _saveTemplate() {
    if (_formKey.currentState?.validate() ?? false) {
      final items =
          _itemsController.text
              .split('\n')
              .where((item) => item.trim().isNotEmpty)
              .toList();

      final template = ChecklistTemplate(
        name: _nameController.text,
        icon: _selectedIcon,
        items: items,
      );

      ref.read(templatesProvider.notifier).addTemplate(template);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Template')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                hintText: 'e.g., Morning Routine, Office Closure',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            const Text('Choose Icon', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      _iconCodes.map((code) {
                        return InkWell(
                          onTap: () => setState(() => _selectedIcon = code),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  code == _selectedIcon
                                      ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              IconData(
                                int.parse(code),
                                fontFamily: 'MaterialIcons',
                              ),
                              color:
                                  code == _selectedIcon
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                              size: 28,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _itemsController,
              decoration: const InputDecoration(
                labelText: 'Checklist Items',
                hintText: 'Enter each item on a new line',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Please enter at least one item';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveTemplate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Template'),
            ),
          ],
        ),
      ),
    );
  }
}
