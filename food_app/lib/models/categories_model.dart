class CategoryModel {
  final String image;
  final String name;

  CategoryModel({
    required this.image,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      image: json['image'] ?? "",
      name: json['name'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
    };
  }
}

