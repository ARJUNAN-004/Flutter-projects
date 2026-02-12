import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:logify/services/location_service.dart';
class TodayScreen extends StatefulWidget {
  final String employeeDocId;

  const TodayScreen({super.key, required this.employeeDocId});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = "";

  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  Future<Map<String, dynamic>> _getLocation() async {
  final locationService = LocationService();

  await locationService.initialize();

  final lat = await locationService.getLatitude();
  final long = await locationService.getLongitude();

  if (lat == null || long == null) {
    return {
      "lat": null,
      "long": null,
      "address": "Location unavailable",
    };
  }

  // Reverse geocode safely
  List<Placemark> place = await placemarkFromCoordinates(lat, long);
  final p = place.first;

  // Build address components
  final List<String?> parts = [
    p.name,
    p.street,
    p.subLocality,
    p.locality,
    p.administrativeArea,
    p.postalCode,
    p.country,
  ];

  // Remove null, empty, duplicates
  final cleaned = parts
      .where((e) => e != null && e.trim().isNotEmpty)
      .map((e) => e!.trim())
      .toSet()
      .toList();

  final address = cleaned.join(", ");

  return {
    "lat": lat,
    "long": long,
    "address": address,
  };
}



  // ------------------------------------------------------
  // 🔥 GET HUMAN READABLE LOCATION (SAFE)
  // ------------------------------------------------------
  // ------------------------------------------------------
  // 🔥 LOAD TODAY'S RECORD
  // ------------------------------------------------------
  Future<void> _getRecord() async {
    try {
      final dateId = DateFormat('dd MMM yyyy').format(DateTime.now());

      final doc = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(widget.employeeDocId)
          .collection("Record")
          .doc(dateId)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          checkIn = data["checkIn"] ?? "--/--";
          checkOut = data["checkOut"] ?? "--/--";
        });
      } else {
        setState(() {
          checkIn = "--/--";
          checkOut = "--/--";
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }

  // ------------------------------------------------------
  // 🔥 CHECK-IN / CHECK-OUT
  // ------------------------------------------------------
  Future<void> _submitAttendance(BuildContext context) async {
  // 🔥 Fetch location + address
  final loc = await _getLocation();

  final double? lat = loc["lat"];
  final double? long = loc["long"];
  final String address = loc["address"];

  if (!mounted) return;

  setState(() {
    location = address;
  });

  final dateId = DateFormat('dd MMM yyyy').format(DateTime.now());
  final recordRef = FirebaseFirestore.instance
      .collection("Employee")
      .doc(widget.employeeDocId)
      .collection("Record")
      .doc(dateId);

  final recordDoc = await recordRef.get();
  String message = "";

  if (recordDoc.exists) {
    // ⭐ CHECK-OUT
    final inTime = recordDoc["checkIn"] ?? "--/--";
    final outTime = DateFormat('hh:mm').format(DateTime.now());

    await recordRef.update({
      'checkIn': inTime,
      'checkOut': outTime,
      'checkOutLocation': address,
      'checkOutLat': lat,
      'checkOutLong': long,
      'date': Timestamp.now(),
    });

    if (!mounted) return;
    setState(() => checkOut = outTime);

    message = "Checked out successfully!";
  } else {
    // ⭐ CHECK-IN
    final inTime = DateFormat('hh:mm').format(DateTime.now());

    await recordRef.set({
      'checkIn': inTime,
      'checkOut': "--/--",
      'checkInLocation': address,
      'checkInLat': lat,
      'checkInLong': long,
      'checkOutLocation': "",
      'checkOutLat': null,
      'checkOutLong': null,
      'date': Timestamp.now(),
    });

    if (!mounted) return;
    setState(() => checkIn = inTime);

    message = "Checked in successfully!";
  }

  // ⭐ Snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color(0xff0eb657),
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ),
  );

  _getRecord();
}


  // ------------------------------------------------------
  // 🔥 UI
  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final scaffoldContext = context;

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome',
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: screenWidth / 20,
              ),
            ),

            Text(
              "Employee",
              style: GoogleFonts.arOneSans(
                fontSize: screenWidth / 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Today's Status",
              style: GoogleFonts.arOneSans(
                color: Colors.black54,
                fontSize: screenWidth / 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 30),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check In',
                          style: TextStyle(
                            fontSize: screenWidth / 20,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          checkIn,
                          style: TextStyle(fontSize: screenWidth / 18),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 80, color: Colors.black12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check Out',
                          style: TextStyle(
                            fontSize: screenWidth / 20,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          checkOut,
                          style: TextStyle(fontSize: screenWidth / 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (_, __) {
                final now = DateFormat('hh:mm:ss a').format(DateTime.now());
                return Text(
                  now,
                  style: TextStyle(
                    fontSize: screenWidth / 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            if (checkOut == "--/--")
              SizedBox(
                height: 70,
                child: SlideAction(
                  text: checkIn == "--/--"
                      ? "Slide to Check In"
                      : "Slide to Check Out",
                  textStyle: TextStyle(
                    fontSize: screenWidth / 20,
                    color: Colors.white,
                  ),
                  outerColor: const Color.fromARGB(255, 8, 209, 95),
                  innerColor: Colors.white,
                  onSubmit: () async {
                    await _submitAttendance(scaffoldContext);
                  },
                ),
              )
            else
              Center(
                child: Text(
                  "You have completed this day!",
                  style: TextStyle(
                    fontSize: screenWidth / 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (location.trim().isNotEmpty)
              Text("Location: $location", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
