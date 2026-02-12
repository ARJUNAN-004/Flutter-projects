import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logify/models/user.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:logify/services/database_service.dart';

class CalenderScreen extends StatefulWidget {
  final String employeeDocId;
  const CalenderScreen({super.key, required this.employeeDocId});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  double screenWidth = 0;
  String _month = DateFormat('MMM').format(DateTime.now());
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(alignment: Alignment.centerLeft, margin: const EdgeInsets.only(top: 15), child: Text('My Attendance', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: screenWidth / 20))),
          const SizedBox(height: 12),
          Stack(children: [
            Container(alignment: Alignment.centerLeft, margin: const EdgeInsets.only(top: 15), child: Text(_month, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: screenWidth / 20))),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(top: 15),
              child: GestureDetector(
                onTap: () async {
                  final month = await showMonthYearPicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2099));
                  if (month != null) setState(() => _month = DateFormat('MMM').format(month));
                },
                child: Text('Pick a Month', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: screenWidth / 20)),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.45,
            child: StreamBuilder<List<AttendanceRecord>>(
              stream: _db.streamRecords(widget.employeeDocId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final records = snapshot.data!;
                if (records.isEmpty) return const Center(child: Text("No attendance records"));
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final rec = records[index];
                    final date = (rec.date).toDate();
                    if (DateFormat('MMM').format(date) != _month) return const SizedBox();
                    return Container(
                      margin: const EdgeInsets.only(top: 20, left: 6, right: 6),
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2))],
                      ),
                      child: Row(children: [
                        Expanded(child: Container(decoration: const BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(20))), child: Center(child: Text(DateFormat('EE\ndd').format(date), textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth / 14, color: Colors.white, fontWeight: FontWeight.bold))))),
                        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Check In', style: TextStyle(fontSize: screenWidth / 20, color: Colors.black54)), AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Text(rec.checkIn, key: ValueKey(rec.checkIn), style: TextStyle(fontSize: screenWidth / 18)))])),
                        Container(width: 1, height: 80, color: Colors.black12),
                        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Check Out', style: TextStyle(fontSize: screenWidth / 20, color: Colors.black54)), AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Text(rec.checkOut, key: ValueKey(rec.checkOut), style: TextStyle(fontSize: screenWidth / 18)))])),
                      ]),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
