// class Category {
//   final String id;
//   final String name;
//   final String iconPath;

//   Category({
//     required this.id,
//     required this.name,
//     required this.iconPath,
//   });

//   // JSON factory constructor
//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       iconPath: json['icon_path'] as String,
//     );
//   }
// }

class Category {
  final String id;
  final String name;
  final String iconPath;

  Category({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      iconPath: json['icon_path'],
    );
  }
}
