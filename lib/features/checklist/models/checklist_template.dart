import 'package:objectbox/objectbox.dart';

@Entity()
class ChecklistTemplate {
  @Id()
  int id = 0;

  String name;
  String icon;
  List<String> items;

  ChecklistTemplate({
    required this.name,
    required this.icon,
    required this.items,
  });
}
