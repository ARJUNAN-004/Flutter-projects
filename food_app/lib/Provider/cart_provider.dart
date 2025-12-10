// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/models/cart_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  /// -----------------------------
  /// CORRECT TOTAL PRICE CALCULATION
  /// -----------------------------
  double get totalprice => _items.fold(
        0,
        (sum, item) =>
            sum + ((item.productdata['price'] ?? 0) * item.quantity),
      );

  CartProvider() {
    loadCart();
  }

  /// -----------------------------
  /// LOAD CART FROM SUPABASE
  /// -----------------------------
  Future<void> loadCart() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from("cart")
          .select()
          .eq("user_id", userId);

      _items = (response as List)
          .map((item) => CartItem.fromMap(item))
          .toList();

      notifyListeners();
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  /// -----------------------------
  /// ADD OR UPDATE CART ITEM
  /// -----------------------------
  Future<void> addCart(
      String productId, Map<String, dynamic> productData, int qtyChange) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Check if product already exists
      final existing = await _supabase
          .from("cart")
          .select()
          .eq("user_id", userId)
          .eq("product_id", productId)
          .maybeSingle();

      if (existing != null) {
        // 🔥 update quantity
        final newQuantity = (existing['quantity'] ?? 0) + qtyChange;

        // ❗ remove if quantity <= 0
        if (newQuantity <= 0) {
          await removeItem(existing['id']);
          return;
        }

        await _supabase
            .from("cart")
            .update({'quantity': newQuantity})
            .eq("id", existing['id']);

        // local update
        int index = _items.indexWhere((item) => item.id == existing['id']);
        if (index != -1) _items[index].quantity = newQuantity;
      } else {
        // 🔥 Insert new item
        final response = await _supabase.from('cart').insert({
          'product_id': productId,
          'product_data': productData,
          'quantity': qtyChange,
          'user_id': userId,
        }).select();

        _items.add(CartItem.fromMap(response.first));
      }

      notifyListeners();
    } catch (e) {
      print("Error updating cart: $e");
      rethrow;
    }
  }

  /// -----------------------------
  /// REMOVE ITEM
  /// -----------------------------
  Future<void> removeItem(String itemId) async {
    try {
      await _supabase.from('cart').delete().eq('id', itemId);
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      print("Error removing item: $e");
    }
  }
}

/// RIVERPOD PROVIDER
final cartProvider = ChangeNotifierProvider<CartProvider>(
  (ref) => CartProvider(),
);
