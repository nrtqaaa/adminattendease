import 'package:flutter/material.dart';

class LeaveCalendarPage extends StatefulWidget {
  const LeaveCalendarPage({super.key});

  @override
  State<LeaveCalendarPage> createState() => _LeaveCalendarPageState();
}

class _LeaveCalendarPageState extends State<LeaveCalendarPage> {
  // 1. STATE: Tracks which month we are viewing (Start at Dec 2025)
  DateTime _currentDate = DateTime(2025, 12, 1);

  // 2. DATA: Simulated Leave Requests (Synchronized with your list)
  final List<Map<String, dynamic>> _leaveRequests = [
    {"name": "Husna Aqilah", "start": DateTime(2025, 12, 10), "end": DateTime(2025, 12, 10)},
    {"name": "Alice Wong", "start": DateTime(2025, 12, 15), "end": DateTime(2025, 12, 17)},
    {"name": "Amir Hazim", "start": DateTime(2025, 12, 20), "end": DateTime(2025, 12, 21)},
  ];

  // Logic to change months
  void _changeMonth(int increment) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + increment, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format Month Title (e.g., "Dec 2025")
    String monthName = _monthName(_currentDate.month);
    String title = "$monthName ${_currentDate.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      body: Column(
        children: [
          // HEADER (Matches your design)
          Container(
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
                  children: const [
                    Text("Leave Calendar View", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
          ),

          // CALENDAR CONTENT
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
                    // NAVIGATOR ROW
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 28),
                            onPressed: () => _changeMonth(-1), // Go Back
                          ),
                          const SizedBox(width: 10),
                          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1D4D))),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 28),
                            onPressed: () => _changeMonth(1), // Go Forward
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // DAYS HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        children: const [
                          _Header("SUN"), _Header("MON"), _Header("TUE"), _Header("WED"),
                          _Header("THU"), _Header("FRI"), _Header("SAT"),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // DYNAMIC GRID
                    Expanded(
                      child: _buildDynamicGrid(),
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

  // 3. LOGIC: Build the grid for the current month
  Widget _buildDynamicGrid() {
    int year = _currentDate.year;
    int month = _currentDate.month;
    
    // Determine the first day of the month (1st = Monday/Tuesday/etc)
    int firstWeekday = DateTime(year, month, 1).weekday; 
    // Adjust because DateTime.monday=1, but we want Sunday=0 for the grid logic usually, 
    // or we can just map 7 (Sunday) to 0 if your week starts on Sunday.
    // Let's assume standard Sunday start: Sunday=0, Monday=1...
    // DateTime.weekday returns 1(Mon) to 7(Sun).
    // If our grid starts Sunday, we need 7(Sun) -> 0, 1(Mon) -> 1.
    int offset = (firstWeekday == 7) ? 0 : firstWeekday;

    int daysInMonth = DateUtils.getDaysInMonth(year, month);
    int totalCells = 35; // 5 rows * 7 cols (standard view), might need 42 for some months

    if (offset + daysInMonth > 35) {
      totalCells = 42; // Need 6 rows
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, 
        childAspectRatio: totalCells == 35 ? 1.5 : 1.3, // Adjust ratio based on rows
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        // Calculate the actual day number
        int dayNum = index - offset + 1;

        // If it's empty space before the 1st or after the last day
        if (dayNum < 1 || dayNum > daysInMonth) {
          return Container(decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12), right: BorderSide(color: Colors.black12))));
        }

        // Check for Leave on this specific date
        DateTime cellDate = DateTime(year, month, dayNum);
        String? leaveName;
        bool isStart = false;
        bool isEnd = false;
        bool isMiddle = false;

        for (var leave in _leaveRequests) {
          DateTime start = leave['start'];
          DateTime end = leave['end'];
          
          // Check if this cellDate falls within the leave range
          if (cellDate.isAfter(start.subtract(const Duration(days: 1))) && 
              cellDate.isBefore(end.add(const Duration(days: 1)))) {
            
            leaveName = leave['name'];
            if (DateUtils.isSameDay(cellDate, start)) isStart = true;
            if (DateUtils.isSameDay(cellDate, end)) isEnd = true;
            if (!isStart && !isEnd) isMiddle = true;
            break; // Found a leave, stop checking
          }
        }

        return Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12), right: BorderSide(color: Colors.black12)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8, left: 8,
                child: Text("$dayNum", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              if (leaveName != null)
                 Positioned(
                  bottom: 15, left: 0, right: 0,
                  child: Container(
                    height: 24,
                    margin: EdgeInsets.only(
                      left: isStart || (!isMiddle && !isEnd) ? 4 : 0,
                      right: isEnd || (!isMiddle && !isStart) ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0),
                      borderRadius: BorderRadius.horizontal(
                        left: isStart ? const Radius.circular(4) : Radius.zero,
                        right: isEnd ? const Radius.circular(4) : Radius.zero,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 4),
                    child: (isStart || (!isMiddle && !isEnd)) 
                        ? Text(leaveName, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}

// Simple Header Widget
class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}