class CartItem {
  final String id;
  final String productId;
  final Map<String, dynamic> productdata;
  int quantity;
  final String userId;

  CartItem({
    required this.id,
    required this.productId,
    required this.productdata,
    required this.quantity,
    required this.userId,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      productId: map['product_id'] ?? '',
      productdata: Map<String, dynamic>.from(map['product_data'] ?? {}),
      quantity: map['quantity'] ?? 0,
      userId: map['user_id'] ?? '',
    );
  }
}
