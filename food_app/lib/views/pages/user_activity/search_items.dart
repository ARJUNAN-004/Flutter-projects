import 'package:flutter/material.dart';
import 'package:food_app/models/product_model.dart';
import 'package:food_app/utils/consts.dart';
import 'package:food_app/widgets/products_items_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final supabase = Supabase.instance.client;
  List<FoodModel> allProducts = [];
  List<FoodModel> filteredProducts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFoodProduct();
  }

  // -------- Fetch all products from Supabase --------
  Future<void> fetchFoodProduct() async {
    try {
      final response = await supabase.from("food_product").select();
      final data = response as List;

      allProducts = data.map((json) => FoodModel.fromJson(json)).toList();
      filteredProducts = allProducts;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // -------- Search Logic --------
  void searchProduct(String query) {
    final results = allProducts.where((product) {
      final name = product.name.toLowerCase();
      final special = product.specialItems.toLowerCase();
      final search = query.toLowerCase();

      return name.contains(search) || special.contains(search);
    }).toList();

    setState(() {
      filteredProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: imageBackground1,

      appBar: AppBar(
  backgroundColor: imageBackground1,
  centerTitle: true,
  title: const Text("All Products"),

  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    onPressed: () => Navigator.pop(context),
  ),
)
,

      body: Column(
        children: [
          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: searchProduct,
              decoration: InputDecoration(
                hintText: "Search for foods...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ---------------- CONTENT AREA ----------------
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          "No matching products found!",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.59,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductsItemDisplay(
                            foodModel: filteredProducts[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
