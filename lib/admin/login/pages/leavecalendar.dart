import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Import Firestore

class LeaveCalendarPage extends StatefulWidget {
  const LeaveCalendarPage({super.key});

  @override
  State<LeaveCalendarPage> createState() => _LeaveCalendarPageState();
}

class _LeaveCalendarPageState extends State<LeaveCalendarPage> {
  // Set default view to current month/year
  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  void _changeMonth(int increment) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + increment, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    String monthName = _monthName(_currentDate.month);
    String title = "$monthName ${_currentDate.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      body: Column(
        children: [
          // HEADER SECTION (Same as your design)
          _buildHeader(context),

          // CALENDAR SECTION
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildNavigator(title),
                    const Divider(height: 1),
                    _buildDaysHeader(),
                    const Divider(height: 1),

                    // LIVE DATABASE GRID
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        // 2. Querying approved leaves for the current month
                        stream: FirebaseFirestore.instance
                            .collection('leaveRequests')
                            .where('status', isEqualTo: 'Approved')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          // Process Firestore data into a list the calendar understands
                          final List<Map<String, dynamic>> leaves = snapshot.data!.docs.map((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            return {
                              "name": data['employeeName'] ?? "Unknown",
                              "start": (data['startDate'] as Timestamp).toDate(),
                              "end": (data['endDate'] as Timestamp).toDate(),
                            };
                          }).toList();

                          return _buildDynamicGrid(leaves);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        border: Border(bottom: BorderSide(color: Colors.blue, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Leave Calendar View", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Welcome back, Admin", style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic)),
            ],
          ),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildNavigator(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => _changeMonth(-1)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1D4D))),
          const SizedBox(width: 10),
          IconButton(icon: const Icon(Icons.chevron_right, size: 28), onPressed: () => _changeMonth(1)),
        ],
      ),
    );
  }

  Widget _buildDaysHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: const [
          _Header("SUN"), _Header("MON"), _Header("TUE"), _Header("WED"),
          _Header("THU"), _Header("FRI"), _Header("SAT"),
        ],
      ),
    );
  }

  Widget _buildDynamicGrid(List<Map<String, dynamic>> leaveRequests) {
    final int year = _currentDate.year;
    final int month = _currentDate.month;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int firstWeekday = DateTime(year, month, 1).weekday;
    final int offset = (firstWeekday == 7) ? 0 : firstWeekday;
    final int totalCells = (offset + daysInMonth > 35) ? 42 : 35;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final int dayNum = index - offset + 1;
        if (dayNum < 1 || dayNum > daysInMonth) {
          return Container(decoration: BoxDecoration(border: Border.all(color: Colors.black12.withOpacity(0.05))));
        }

        final DateTime cellDate = DateTime(year, month, dayNum);
        String? leaveName;
        bool isStart = false;
        bool isEnd = false;

        for (var leave in leaveRequests) {
          DateTime start = DateTime(leave['start'].year, leave['start'].month, leave['start'].day);
          DateTime end = DateTime(leave['end'].year, leave['end'].month, leave['end'].day);

          if ((cellDate.isAtSameMomentAs(start) || cellDate.isAfter(start)) &&
              (cellDate.isAtSameMomentAs(end) || cellDate.isBefore(end))) {
            leaveName = leave['name'];
            if (DateUtils.isSameDay(cellDate, start)) isStart = true;
            if (DateUtils.isSameDay(cellDate, end)) isEnd = true;
            break;
          }
        }

        return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black12.withOpacity(0.05))),
          child: Stack(
            children: [
              Positioned(top: 8, left: 8, child: Text("$dayNum", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              if (leaveName != null)
                Positioned(bottom: 8, left: 0, right: 0, child: _buildLeaveLabel(leaveName, isStart, isEnd, index)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaveLabel(String name, bool isStart, bool isEnd, int index) {
    return Container(
      height: 20,
      margin: EdgeInsets.only(left: isStart ? 4 : 0, right: isEnd ? 4 : 0),
      decoration: BoxDecoration(
        color: const Color(0xFF5C6BC0),
        borderRadius: BorderRadius.horizontal(
          left: isStart ? const Radius.circular(4) : Radius.zero,
          right: isEnd ? const Radius.circular(4) : Radius.zero,
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 4),
      child: (isStart || index % 7 == 0)
          ? Text(name, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis))
          : null,
    );
  }

  String _monthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(text, style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}