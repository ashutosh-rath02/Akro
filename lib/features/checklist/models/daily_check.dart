import 'package:objectbox/objectbox.dart';

@Entity()
class DailyCheck {
  @Id()
  int id = 0;

  int templateId;
  String itemTitle;
  String? description;
  String? photoPath;
  bool isCompleted;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? completedAt;

  DailyCheck({
    required this.templateId,
    required this.itemTitle,
    this.description,
    this.photoPath,
    this.isCompleted = false,
    DateTime? completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
