class Item {
  final int? id;
  final String title;
  final String description;
  final String type;
  final String category;
  final String? imagePath;
  final String uploaderEmail; // Still needed for database operations
  final String uploaderName; // New field for display
  final String? phone;

  Item({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.imagePath,
    required this.uploaderEmail,
    required this.uploaderName,
    this.phone,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          type == other.type &&
          category == other.category &&
          imagePath == other.imagePath &&
          uploaderEmail == other.uploaderEmail &&
          uploaderName == other.uploaderName &&
          phone == other.phone;

  @override
  int get hashCode =>
      title.hashCode ^
      description.hashCode ^
      type.hashCode ^
      category.hashCode ^
      imagePath.hashCode ^
      uploaderEmail.hashCode ^
      uploaderName.hashCode ^
      phone.hashCode;
}
