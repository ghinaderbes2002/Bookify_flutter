class CategoriesModel {
  final int categoryId;
  final String name;
  final String? description;

  CategoriesModel({
    required this.categoryId,
    required this.name,
    this.description,
  });

  factory CategoriesModel.fromJson(Map<String, dynamic> json) {
    return CategoriesModel(
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'description': description,
    };
  }
}
