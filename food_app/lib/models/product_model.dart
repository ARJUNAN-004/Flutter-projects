var desc = "This is a special types of tiems, often served with cheese, lettuce, tomato, onion, pickles, bacon, or chilis; condiments such as ketchup, mustard, mayonnaise, relish, or a 'specialItems sauce', often a variation of Thousand Island dressing; and are frequently placed on sesame seed buns.";
class FoodModel {
  final String id;
  final String imageCard;
  final String imageDetail;
  final String name;
  final double price;
  final double rate;
  final String specialItems;
  final String category;
  final int kcal;
  final String time;

  FoodModel({
    required this.id,
    required this.imageCard,
    required this.imageDetail,
    required this.name,
    required this.price,
    required this.rate,
    required this.specialItems,
    required this.category,
    required this.kcal,
    required this.time,
  });

  // Convert Supabase JSON → Model
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'].toString(), // Safe conversion
      imageCard: json['imageCard'] ?? "",
      imageDetail: json['imageDetail'] ?? "",
      name: json['name'] ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      specialItems: json['specialItems'] ?? '',
      category: json['category'] ?? '',
      kcal: json['kcal'] is int
          ? json['kcal']
          : int.tryParse(json['kcal'].toString()) ?? 0,
      time: json['time']?.toString() ?? "",
    );
  }

  // Convert Model → JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageCard': imageCard,
      'imageDetail': imageDetail,
      'name': name,
      'price': price,
      'rate': rate,
      'specialItems': specialItems,
      'category': category,
      'kcal': kcal,
      'time': time,
    };
  }
}
