import 'package:flutter/material.dart';

class AttendanceReportPage extends StatelessWidget {
  const AttendanceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BREADCRUMB
        const Padding(
          padding: EdgeInsets.only(left: 32, top: 20),
          child: Text("Report / Attendance Report", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
        ),

        // SEARCH FILTERS
        Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Attendance Report", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              Row(
                children: [
                  _buildFilterField("Employee's ID", "EMP001", width: 300),
                  const SizedBox(width: 32),
                  _buildFilterField("Month", "November", width: 200),
                  const Spacer(),
                  _buildBlueButton("SEARCH"),
                ],
              ),
            ],
          ),
        ),

        // REPORT TABLE
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [const Text("Show "), _buildSmallDropdown("10"), const Text(" entries")]),
                    _buildSearchBox(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTableHeader(["Date", "Clock-in", "Clock-out", "Hours Work", "Tardiness", "Remarks"]),
                Expanded(
                  child: ListView(
                    children: [
                      _buildReportRow(["1.11.2025", "0900", "1700", "8 hours", "0 minute", "On Time"]),
                      _buildReportRow(["2.11.2025", "0915", "1710", "7 hours 55 minutes", "15 minutes", "Late"]),
                      _buildReportRow(["3.11.2025", "0900", "1700", "8 hours", "0 minute", "On Time"]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildBlueButton("GENERATE"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==========================================
  //  MISSING HELPER METHODS ADDED BELOW
  // ==========================================

  Widget _buildFilterField(String label, String value, {double width = 200}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerLeft,
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildBlueButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B1D4D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSmallDropdown(String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      width: 200,
      height: 35,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          contentPadding: EdgeInsets.only(bottom: 12, left: 10),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, size: 18),
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<String> labels) {
    return Container(
      color: const Color(0xFFA7BBC7),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: labels.map((l) => Expanded(child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
      ),
    );
  }

  Widget _buildReportRow(List<String> values) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: values.map((v) => Expanded(child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)))).toList(),
      ),
    );
  }
}