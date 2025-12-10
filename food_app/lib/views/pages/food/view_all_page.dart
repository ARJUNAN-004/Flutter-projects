import 'package:flutter/material.dart';
import 'package:food_app/models/product_model.dart';
import 'package:food_app/utils/consts.dart';
import 'package:food_app/widgets/products_items_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAllProductPage extends StatefulWidget {
  const ViewAllProductPage({super.key});

  @override
  State<ViewAllProductPage> createState() => _ViewAllProductPageState();
}

class _ViewAllProductPageState extends State<ViewAllProductPage> {
  final supabase = Supabase.instance.client;
  List<FoodModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFoodProduct();
  }

  // fetch products from server
  Future<void> fetchFoodProduct() async {
    try {
      final response = await Supabase.instance.client
          .from("food_product")
          .select();
      final data = response as List;
      setState(() {
        products = data.map((json) => FoodModel.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching Product: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: imageBackground1,
      appBar: AppBar(
        title: Text("All Products"),
        forceMaterialTransparency: true,
        backgroundColor: imageBackground1,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
            padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.59,
                crossAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (contex, index) {
                return ProductsItemDisplay(foodModel: products[index]);
              },
            ),
    );
  }
}
