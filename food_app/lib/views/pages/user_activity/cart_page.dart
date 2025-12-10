import 'dart:ui';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/Provider/cart_provider.dart';
import 'package:food_app/utils/consts.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    double discountPrice = cart.totalprice * 0.10;
    double deliveryCharge = 30;
    double grandTotal = cart.totalprice - discountPrice + deliveryCharge;

    return SafeArea(
      child: Scaffold(
        backgroundColor: imageBackground1,

        appBar: AppBar(
          backgroundColor: imageBackground1,
          centerTitle: true,
          title: const Text(
            'Your Cart',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: cart.items.isEmpty
            ? _emptyCartView()
            : Column(
                children: [
                  /// ---------------- CART ITEMS ----------------
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];

                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => cart.removeItem(item.id),

                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:imageBackground2,
                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: Row(
                              children: [
                                /// ----- IMAGE -----
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.productdata['imageCard'],
                                    width: 65,
                                    height: 65,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// ----- NAME + PRICE -----
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productdata['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "₹${item.productdata['price']}",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// ----- QUANTITY CONTROL -----
                                Row(
                                  children: [
                                    // MINUS
                                    GestureDetector(
                                      onTap: item.quantity > 1
                                          ? () {
                                              cart.addCart(
                                                item.productId,
                                                item.productdata,
                                                -1,
                                              );
                                            }
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                left: Radius.circular(8),
                                              ),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),

                                    // NUMBER
                                    Container(
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                          horizontal: BorderSide(),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          "${item.quantity}",
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // PLUS
                                    GestureDetector(
                                      onTap: () {
                                        cart.addCart(
                                          item.productId,
                                          item.productdata,
                                          1,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                right: Radius.circular(8),
                                              ),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// ---------------- PRICE SUMMARY ----------------
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: imageBackground2,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),

                    child: Column(
                      children: [
                        _summaryRow(
                          "Subtotal",
                          "₹${cart.totalprice.toStringAsFixed(2)}",
                        ),
                        _summaryRow(
                          "Discount (10%)",
                          "-₹${discountPrice.toStringAsFixed(2)}",
                        ),
                        _summaryRow(
                          "Delivery Charge",
                          "₹${deliveryCharge.toStringAsFixed(2)}",
                        ),

                        const Divider(height: 30),

                        _summaryRow(
                          "Grand Total",
                          "₹${grandTotal.toStringAsFixed(2)}",
                          bold: true,
                        ),

                        const SizedBox(height: 14),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 90,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            CherryToast.success(
                              title: Text(
                                "Order Placed!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              description: Text(
                                "Your order has been successfully placed.",
                                style: TextStyle(color: Colors.white),
                              ),

                              // 🔥 Custom Icon (OLD versions only support iconWidget)
                              iconWidget: Icon(
                                Icons.check_circle,
                                size: 28,
                                color: Colors.white,
                              ),

                              // 🔥 Top-down animation
                              animationType: AnimationType.fromTop,
                              toastPosition: Position.top,
                              animationDuration: Duration(milliseconds: 600),

                              // 🔥 Green background
                              backgroundColor: Colors.green.withOpacity(0.9),

                              borderRadius: 18,
                              toastDuration: Duration(seconds: 3),
                            ).show(context);
                          },
                          child: const Text(
                            "Checkout",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// EMPTY CART UI
  Widget _emptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 20),
          Text(
            "Your cart is empty!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add something delicious!",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// SUMMARY ROW
  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
