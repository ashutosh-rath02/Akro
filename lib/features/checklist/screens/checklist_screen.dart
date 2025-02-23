import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checklist_provider.dart';
import '../models/checklist_item.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(checklistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Security Checklist'),
        actions: [
          // Test action to add dummy data
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {
              ref
                  .read(checklistProvider.notifier)
                  .addItem(
                    ChecklistItem(
                      title: 'Test Item ${DateTime.now().second}',
                      description: 'Test Description',
                    ),
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                items.isEmpty
                    ? const Center(
                      child: Text('No items yet. Add some items to test!'),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              item.title,
                              style: TextStyle(
                                decoration:
                                    item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            subtitle: Text(item.description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Toggle completion
                                IconButton(
                                  icon: Icon(
                                    item.isCompleted
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    color:
                                        item.isCompleted
                                            ? Theme.of(context).primaryColor
                                            : null,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(checklistProvider.notifier)
                                        .toggleItemCompletion(item.id);
                                  },
                                ),
                                // Delete item
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    ref
                                        .read(checklistProvider.notifier)
                                        .deleteItem(item.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Test Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    ref
                        .read(checklistProvider.notifier)
                        .addItem(
                          ChecklistItem(
                            title: titleController.text,
                            description: descController.text,
                          ),
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
