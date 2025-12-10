import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/Provider/cart_provider.dart';
import 'package:food_app/models/product_model.dart';
import 'package:food_app/utils/consts.dart';
import 'package:food_app/widgets/snack_bar.dart';
import 'package:readmore/readmore.dart';

class FoodDetailPage extends ConsumerStatefulWidget {
  final FoodModel product;
  const FoodDetailPage({super.key, required this.product});

  @override
  ConsumerState<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends ConsumerState<FoodDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),

      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _background(size),
          _whiteContainer(size),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),

                  _heroImage(),

                  const SizedBox(height: 35),

                  _quantitySelector(),

                  const SizedBox(height: 40),

                  _titlePriceSection(),

                  const SizedBox(height: 22),

                  _foodInfoRow(),

                  const SizedBox(height: 22),

                  _description(),

                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _addToCartButton(),
    );
  }

  // ---------------------------------------------------------------------------
  // Background
  Widget _background(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [imageBackground1, imageBackground1.withOpacity(0.85)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Image.asset(
        "assets/cartoons/food_pattern.png",
        repeat: ImageRepeat.repeatY,
        color: imageBackground2,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // White bottom container
  Widget _whiteContainer(Size size) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: size.width,
        height: size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, -3),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Product Image
  Widget _heroImage() {
    return Hero(
      tag: widget.product.imageCard,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black54.withOpacity(0.10),
              blurRadius: 30,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(widget.product.imageDetail, fit: BoxFit.contain),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Quantity selector
  Widget _quantitySelector() {
    return Container(
      height: 55,
      width: 170,
      decoration: BoxDecoration(
        color: red,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _qtyBtn(Icons.remove, () {
            setState(() {
              quantity = quantity > 1 ? quantity - 1 : 1;
            });
          }),

          const SizedBox(width: 20),

          Text(
            "$quantity",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 20),

          _qtyBtn(Icons.add, () {
            setState(() {
              quantity++;
            });
          }),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }

  // ---------------------------------------------------------------------------
  // Title + Price
  Widget _titlePriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              widget.product.specialItems,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "₹ ",
                style: TextStyle(
                  color: red,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: widget.product.price.toInt().toString(),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Food info row
  Widget _foodInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _foodInfo("assets/icon/star.png", widget.product.rate),
        _foodInfo("assets/icon/fire.png", "${widget.product.kcal} kcal"),
        _foodInfo("assets/icon/time.png", widget.product.time),
      ],
    );
  }

  Row _foodInfo(String image, dynamic value) {
    return Row(
      children: [
        Image.asset(image, width: 25),
        const SizedBox(width: 10),
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Description
  Widget _description() {
    return ReadMoreText(
      desc,
      style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5),
      trimLength: 120,
      trimCollapsedText: " read more",
      trimExpandedText: " read less",
      moreStyle: TextStyle(fontWeight: FontWeight.bold, color: red),
      lessStyle: TextStyle(fontWeight: FontWeight.bold, color: red),
    );
  }

  // ---------------------------------------------------------------------------
  // Add to Cart Button
  Widget _addToCartButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: MaterialButton(
        onPressed: () async {
          await ref
              .read(cartProvider)
              .addCart(widget.product.name, widget.product.toMap(), quantity);
          showSnackBar(context, "${widget.product.name} added to cart",);
        },
        height: 65,
        minWidth: 300,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
        color: red,
        child: const Text(
          "Add to Cart",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App bar
  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 75,
      actions: [
        const SizedBox(width: 20),

        _appIcon(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),

        const Spacer(),

        _appIcon(icon: Icons.more_horiz_rounded, onTap: () {}),

        const SizedBox(width: 25),
      ],
    );
  }

  Widget _appIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: imageBackground2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
    );
  }
}
