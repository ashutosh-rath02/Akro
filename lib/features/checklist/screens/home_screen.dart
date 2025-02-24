import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../checklist/providers/checklist_provider.dart';
import '../../checklist/models/checklist_template.dart';
import '../../checklist/screens/add_template_screen.dart';
import '../../checklist/screens/template_checks_screen.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);

    return Scaffold(
      key: ValueKey('home_screen_${templates.length}'),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: RepaintBoundary(child: Text('Daily Checks')),
            centerTitle: true,
            floating: true,
            snap: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver:
                templates.isEmpty
                    ? const SliverFillRemaining(
                      child: Center(
                        child: RepaintBoundary(
                          child: Text('Add your first checklist template'),
                        ),
                      ),
                    )
                    : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final template = templates[index];
                        return TemplateCard(
                          key: ValueKey('template_${template.id}'),
                          template: template,
                        );
                      }, childCount: templates.length),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTemplateScreen(),
              ),
            ).then((_) {
              // Force refresh of templates when returning from add screen
              ref.refresh(templatesProvider);
            }),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TemplateCard extends StatelessWidget {
  final ChecklistTemplate template;

  const TemplateCard({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TemplateChecksScreen(template: template),
                ),
              ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconData(
                      int.parse(template.icon),
                      fontFamily: 'MaterialIcons',
                    ),
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RepaintBoundary(
                        child: Text(
                          template.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      RepaintBoundary(
                        child: Text(
                          '${template.items.length} items',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
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
