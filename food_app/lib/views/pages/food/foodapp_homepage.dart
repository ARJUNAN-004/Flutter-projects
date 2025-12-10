import 'package:flutter/material.dart';
import 'package:food_app/models/categories_model.dart';
import 'package:food_app/models/product_model.dart';
import 'package:food_app/utils/consts.dart';
import 'package:food_app/views/pages/food/view_all_page.dart';
import 'package:food_app/views/pages/users/profile_page.dart';
import 'package:food_app/widgets/products_items_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodAppHomeScreen extends StatefulWidget {
  const FoodAppHomeScreen({super.key});

  @override
  State<FoodAppHomeScreen> createState() => _FoodAppHomeScreenState();
}

class _FoodAppHomeScreenState extends State<FoodAppHomeScreen> {
  final client = Supabase.instance.client;

  late Future<List<CategoryModel>> futureCategories;
  late Future<List<FoodModel>> futureFoodProducts;

  List<CategoryModel> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
    futureFoodProducts = Future.value([]);

    _loadInitialData();
  }

  // LOAD CATEGORIES FIRST, THEN LOAD FIRST CATEGORY PRODUCTS
  void _loadInitialData() async {
    try {
      final data = await futureCategories;

      if (data.isNotEmpty) {
        setState(() {
          categories = data;
          selectedCategory = categories.first.name;
          futureFoodProducts = fetchFoodProduct(selectedCategory!);
        });
      }
    } catch (e) {
      print("Initialization Error: $e");
    }
  }

  // FETCH PRODUCTS
  Future<List<FoodModel>> fetchFoodProduct(String category) async {
    try {
      final response = await client
          .from("food_product")
          .select()
          .eq("category", category);

      return (response as List)
          .map((json) => FoodModel.fromJson(json))
          .toList();
    } catch (error) {
      print("Error fetching product: $error");
      return [];
    }
  }

  // FETCH CATEGORIES
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await client.from("category_items").select();

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (error) {
      print("Error fetching categories: $error");
      return [];
    }
  }

  // ------------------------- UI ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: imageBackground1,
      appBar: _appBar(),

      // 🔥 FULL PAGE IS NOW SCROLLABLE + BOTTOM SAFE SPACE
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 150), // VERY IMPORTANT!!
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerSection(),
            const SizedBox(height: 25),
            _buildCategoryList(),
            const SizedBox(height: 25),
            _viewAllButton(),
            const SizedBox(height: 25),
            _buildProductSection(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BANNER + TITLE
  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _appBanners(),
          const SizedBox(height: 25),
          const Text(
            "Categories",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRODUCTS HORIZONTAL LIST
  Widget _buildProductSection() {
    return FutureBuilder<List<FoodModel>>(
      future: futureFoodProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 25,
                  right: index == products.length - 1 ? 25 : 0,
                ),
                child: ProductsItemDisplay(foodModel: products[index]),
              );
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // VIEW ALL BUTTON
  Widget _viewAllButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Popular Now",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewAllProductPage()),
              );
            },
            child: Row(
              children: [
                Text("View All", style: TextStyle(color: orange)),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY LIST ROW
  Widget _buildCategoryList() {
    return FutureBuilder<List<CategoryModel>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;

        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final category = data[index];

              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 15 : 0, right: 15),
                child: GestureDetector(
                  onTap: () => _selectCategory(category.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedCategory == category.name ? red : grey1,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedCategory == category.name
                                ? Colors.white
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Image.network(
                            category.image,
                            width: 20,
                            height: 20,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.fastfood),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: selectedCategory == category.name
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY CHANGE HANDLER
  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      futureFoodProducts = fetchFoodProduct(category);
    });
  }

  // ---------------------------------------------------------------------------
  // HEADER BANNER
  Widget _appBanners() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: imageBackground2,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.only(top: 25, right: 25, left: 25),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                    children: [
                      const TextSpan(
                        text: "The Fastest In Delivery ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "Food",
                        style: TextStyle(color: red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                  child: const Text(
                    "Order Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Image.asset("assets/cartoons/courier.png"),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR
  AppBar _appBar() {
    return AppBar(
      backgroundColor: imageBackground1,
      centerTitle: true,
      elevation: 0,
      actions: [
        const SizedBox(width: 25),

        // Menu Icon
        Container(
          height: 45,
          width: 45,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: grey1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset("assets/icon/dash.png"),
        ),

        const Spacer(),

        Row(
          children: const [
            Icon(Icons.location_on_outlined, size: 20, color: red),
            SizedBox(width: 5),
            Text(
              "Erode, Tamilnadu",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 25,
              color: Colors.orange,
            ),
          ],
        ),

        const Spacer(),

        // Profile icon
        GestureDetector(
          onTap: (){
            Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProfilePage(),
        transitionsBuilder: (_, animation, __, child) {
          final slide =
              Tween(begin: const Offset(1, 0), end: Offset.zero).animate(animation);
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
          },
          child: Container(
            height: 45,
            width: 45,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: grey1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset("assets/cartoons/profile.png"),
          ),
        ),

        const SizedBox(width: 25),
      ],
    );
  }
}
