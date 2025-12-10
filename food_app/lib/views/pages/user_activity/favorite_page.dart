import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/Provider/favorite_provider.dart';
import 'package:food_app/models/product_model.dart';
import 'package:food_app/utils/consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// -----------------------------
// CONSUMER STATEFUL WIDGET
// -----------------------------
class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

// -----------------------------
// STATE CLASS
// -----------------------------
class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;
    final provider = ref.watch(favoriteProvider);
    return Scaffold(
      backgroundColor: imageBackground1,
      appBar: _appBar(),
      body: userId == null
          ? const Center(child: Text("Please login to view favorites"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from("favorites")
                  .stream(primaryKey: ['id'])
                  .eq("user_id", userId)
                  .map((data) => data.cast<Map<String, dynamic>>()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final favorites = snapshot.data!;

                if (favorites.isEmpty) {
                  return const Center(child: Text("No Favorites yet"));
                }

                return FutureBuilder<List<FoodModel>>(
                  future: _fetchFavoriteItems(favorites),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final favoriteItems = snapshot.data!;
                    if (favoriteItems.isEmpty) {
                      return const Center(child: Text("No Favorites yet"));
                    }

                    return ListView.builder(
                      itemCount: favoriteItems.length,
                      itemBuilder: (context, index) {
                        final FoodModel item = favoriteItems[index];

                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              child: Container(
                                height: 120,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: imageBackground2,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: NetworkImage(item.imageCard),
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17,
                                            ),
                                          ),
                                          Text(item.category),
                                          Text(
                                            "₹${item.price.toInt()}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.pink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // DELETE BUTTON
                            Positioned(
                              right: 30,
                              top: 50,
                              child: GestureDetector(
                                onTap: () async {
                                  provider.toggleFavorite(item.name);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  // FETCH FAVORITE ITEMS BY NAME
  Future<List<FoodModel>> _fetchFavoriteItems(
    List<Map<String, dynamic>> favorites,
  ) async {
    final List<String> productNames = favorites
        .map((fav) => fav["product_id"].toString())
        .toList();

    if (productNames.isEmpty) return [];

    try {
      final response = await supabase
          .from("food_product")
          .select()
          .inFilter("name", productNames);

      return response.map((data) => FoodModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint("Error fetching favorite items: $e");
      return [];
    }
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: imageBackground1,
      centerTitle: true,
      title: const Text(
        'Favorites',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
