import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logify/services/location_service.dart';
import 'package:logify/views/task/task_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:logify/views/attendence/today_screen.dart';
import 'package:logify/views/attendence/calender_screen.dart';
import 'package:logify/views/user/profile.dart';
import 'package:logify/views/core/login_page.dart'; // ⭐ Add Task Screen

class HomePage extends StatefulWidget {
  final String employeeDocId;
  const HomePage({super.key, required this.employeeDocId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late final List<Widget> _pages;

  // ⭐ Updated Icon List (Added Task Icon)
  final List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.listCheck, // ⬅ Task
    FontAwesomeIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    _startLocationService();

    /// ⭐ Pass employeeDocId to all pages
    _pages = [
      CalenderScreen(employeeDocId: widget.employeeDocId),
      TodayScreen(employeeDocId: widget.employeeDocId),
      TaskScreen(employeeDocId: widget.employeeDocId), // ⬅ Added Task Page
      ProfilePage(employeeDocId: widget.employeeDocId),
    ];
  }

  void _startLocationService() async {
  final locationService = LocationService();

  await locationService.initialize();

  final lat = await locationService.getLatitude();
  final long = await locationService.getLongitude();

  if (lat != null && long != null) {
    print("LAT: $lat | LONG: $long");
  } else {
    print("⚠ Location unavailable");
  }
}


  /// ⭐ Logout Function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("employee_doc_id");
    await prefs.remove("employee_id");

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0eb657),
        title: const Text("Logify"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),

      /// ⭐ Page Switcher
      body: IndexedStack(index: currentIndex, children: _pages),

      /// ⭐ Custom Bottom Navigation Bar (Old UI Restored)
      bottomNavigationBar: Container(
        height: 55,
        margin: const EdgeInsets.only(left: 50, right: 50, bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF18D067),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Row(
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => currentIndex = i),
                    child: SizedBox(
                      height: screenHeight,
                      width: screenWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            navigationIcons[i],
                            size: i == currentIndex ? 32 : 24,
                            color: i == currentIndex
                                ? Colors.white
                                : Colors.black,
                          ),

                          /// ⭐ Indicator Bar
                          if (i == currentIndex)
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              height: 3,
                              width: 22,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
