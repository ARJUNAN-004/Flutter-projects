import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/Provider/favorite_provider.dart';
import 'package:food_app/models/product_model.dart';
import 'package:food_app/utils/consts.dart';
import 'package:food_app/views/pages/food/food_detail_screen.dart';

class ProductsItemDisplay extends ConsumerWidget {
  final FoodModel foodModel;

  const ProductsItemDisplay({super.key, required this.foodModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(favoriteProvider);
    Size size = MediaQuery.of(context).size;

    // RESPONSIVE VALUES
    double cardHeight = size.height * 0.85;       // auto adjusts
    double imageSize = size.width * 0.28;         // product image
    double cardRadius = size.width * 0.09;        // corner radius
    double paddingTop = size.height * 0.16;       // space for image

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, __, ___) => FoodDetailPage(product: foodModel),
          ),
        );
      },
      child: Container(
        width: size.width * 0.5,
        //color: Colors.black,
        margin: const EdgeInsets.all(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // MAIN CARD (Responsive)
            Container(
              alignment: Alignment.topCenter,
              height: cardHeight,
              decoration: BoxDecoration(
                 color: Colors.amber[100],
                //color: Colors.blue,
                borderRadius: BorderRadius.circular(cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(15, paddingTop, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //const SizedBox(height: 10),

                  // PRODUCT NAME
                  Text(
                    foodModel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: size.width * 0.040,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // SUB TEXT
                  Text(
                    foodModel.specialItems,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: Colors.black54,
                    ),
                  ),

                  const Spacer(),

                  // PRICE
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "₹ ",
                          style: TextStyle(
                            fontSize: size.width * 0.055,
                            color: red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "${foodModel.price.toInt()}",
                          style: TextStyle(
                            fontSize: size.width * 0.060,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ❤️ FAVORITE BUTTON
            Positioned(
              top: 15,
              left: 15,
              child: GestureDetector(
                onTap: () {
                  ref.read(favoriteProvider).toggleFavorite(foodModel.name);
                },
                child: CircleAvatar(
                  radius: size.width * 0.04,
                  backgroundColor: favorite.isExist(foodModel.name)
                      ? Colors.white
                      : Colors.transparent,
                  child: favorite.isExist(foodModel.name)
                      ? Image.asset("assets/icon/fire.png")
                      : Icon(
                          Icons.local_fire_department,
                          color: red,
                          size: size.width * 0.06,
                        ),
                ),
              ),
            ),

            // PRODUCT IMAGE RESPONSIVE
            Positioned(
              top: size.height * 0.03,
              left: 5,
              right: 5,
              child: Center(
                child: Hero(
                  tag: foodModel.imageCard,
                  child: Image.network(
                    foodModel.imageCard,
                    height: imageSize,
                    width: imageSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
