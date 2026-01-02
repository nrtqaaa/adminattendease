import 'package:flutter/material.dart';

class ManualAttendancePage extends StatelessWidget {
  const ManualAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BREADCRUMB STYLE HEADER
          Row(
            children: [
              const Text("Attendance / ", style: TextStyle(fontSize: 18)),
              const Text("Manual Attendance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
            ],
          ),
          const SizedBox(height: 24),

          // SEARCH BOX
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Manual Attendance Entry", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(height: 32),
                const Text("Employee's ID", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 400,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black26)),
                      child: DropdownButton<String>(
                        value: "EMP001",
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ["EMP001"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {},
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18)),
                      child: const Text("SEARCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // DETAILS BOX
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ATTENDANCE DETAILS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 20),
                _detailRow("Employee's Name:", "Hani Syakirah"),
                _detailRow("Date:", "__ / __ / ______"),
                _detailRow("Clock-In Time:", "__ : __"),
                _detailRow("Clock-Out Time:", "__ : __"),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton("ADD", const Color(0xFF0B1D4D)),
              const SizedBox(width: 20),
              _buildActionButton("UPDATE", const Color(0xFF0B1D4D)),
              const SizedBox(width: 20),
              _buildActionButton("CLEAR", const Color(0xFF0B1D4D)),
            ],
          )
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 15)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}