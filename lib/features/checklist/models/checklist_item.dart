import 'package:objectbox/objectbox.dart';

@Entity()
class ChecklistItem {
  @Id()
  int id = 0;

  String title;
  String description;
  bool isCompleted;
  String? photoPath;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? completedAt;

  ChecklistItem({
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.photoPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
