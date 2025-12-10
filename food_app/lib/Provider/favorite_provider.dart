// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final favoriteProvider = ChangeNotifierProvider(
  (ref) => FavoriteProvider(),
);

class FavoriteProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Stores favorite PRODUCT NAMES
  List<String> _favoriteNames = [];
  List<String> get favorite => _favoriteNames;

  String? get userId => _supabase.auth.currentUser?.id;

  FavoriteProvider() {
    loadFavorites();
  }

  // ----------------------------------------------------------------------
  // LOAD FAVORITES FROM SUPABASE
  // ----------------------------------------------------------------------
  Future<void> loadFavorites() async {
    if (userId == null) return;

    try {
      final data = await _supabase
          .from("favorites")
          .select("product_id")
          .eq("user_id", userId!);

      _favoriteNames = data
          .map<String>((row) => row["product_id"].toString())
          .toList();

      notifyListeners();
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  // ----------------------------------------------------------------------
  // CHECK IF ITEM IS FAVORITE
  // productId = PRODUCT NAME
  // ----------------------------------------------------------------------
  bool isExist(String productName) {
    return _favoriteNames.contains(productName);
  }

  // ----------------------------------------------------------------------
  // TOGGLE FAVORITE
  // ----------------------------------------------------------------------
  Future<void> toggleFavorite(String productName) async {
    if (userId == null) {
      print("User not logged in");
      return;
    }

    if (_favoriteNames.contains(productName)) {
      await _removeFavorite(productName);
      _favoriteNames.remove(productName);
    } else {
      await _addFavorite(productName);
      _favoriteNames.add(productName);
    }

    notifyListeners();
  }

  // ----------------------------------------------------------------------
  // ADD FAVORITE TO SUPABASE
  // ----------------------------------------------------------------------
  Future<void> _addFavorite(String productName) async {
    try {
      await _supabase.from("favorites").insert({
        "user_id": userId,
        "product_id": productName, // STORED AS NAME
      });
    } catch (e) {
      print("Error adding favorite: $e");
    }
  }

  // ----------------------------------------------------------------------
  // REMOVE FAVORITE FROM SUPABASE
  // ----------------------------------------------------------------------
  Future<void> _removeFavorite(String productName) async {
    try {
      await _supabase.from("favorites").delete().match({
        "user_id": userId!,
        "product_id": productName,
      });
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  // ----------------------------------------------------------------------
  // RESET WHEN LOGOUT
  // ----------------------------------------------------------------------
  void reset() {
    _favoriteNames = [];
    notifyListeners();
  }
}
