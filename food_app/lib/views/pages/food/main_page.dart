import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/Provider/cart_provider.dart';
import 'package:food_app/utils/consts.dart';
import 'package:food_app/views/pages/food/foodapp_homepage.dart';
import 'package:food_app/views/pages/user_activity/cart_page.dart';
import 'package:food_app/views/pages/user_activity/search_items.dart';
import 'package:food_app/views/pages/users/profile_page.dart';
import 'package:food_app/views/pages/user_activity/favorite_page.dart';
import 'package:iconsax/iconsax.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int currentIndex = 0;

  final List<Widget> _screens = [
    const FoodAppHomeScreen(),
    const FavoriteScreen(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider); // ✅ Correctly watching cart state

    return Scaffold(
      backgroundColor: imageBackground1,
      extendBody: true,

      body: _screens[currentIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SearchPage(),

      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(position: slide, child: child);
      },
    ),
  );
},

        child: Container(
          margin: EdgeInsets.only(top: 80),
          //padding: EdgeInsets.only(top: 30),
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: red,
            boxShadow: [
              BoxShadow(
                color: red.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.search,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavBar(cart.items.length),
    );
  }

  Widget _buildBottomNavBar(int cartCount) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Iconsax.home_15, 0),
          _navItem(Iconsax.heart, 1),

          const SizedBox(width: 70),

          // ---- CART ICON WITH BADGE ----
          Stack(
            clipBehavior: Clip.none,
            children: [
              _navItem(Iconsax.shopping_cart, 2),

              if (cartCount > 0)
                Positioned(
                  right: -6,
                  top: -3,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: red,
                    child: Text(
                      cartCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),

          _navItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    return InkWell(
      onTap: () => setState(() => currentIndex = index),
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: 60,
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: currentIndex == index ? red : Colors.grey,
            ),
            const SizedBox(height: 3),
            CircleAvatar(
              radius: 3,
              backgroundColor: currentIndex == index ? red : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
