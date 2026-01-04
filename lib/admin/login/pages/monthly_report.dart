import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'reportsearch.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  // Filters
  String selectedDepartment = "All";
  DateTime selectedMonth = DateTime.now();

  // Stats Counters
  int totalPresents = 0;
  int totalAbsents = 0;
  int totalLate = 0;
  int totalLeave = 0;
  int missedCheckIns = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyData();
  }

  /// Logic: Query Firestore and Aggregate Totals
  Future<void> _fetchMonthlyData() async {
    setState(() => _isLoading = true);

    // 1. Define Date Range (Start and End of selected month)
    DateTime firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    
    String startStr = DateFormat('yyyy-MM-dd').format(firstDay);
    String endStr = DateFormat('yyyy-MM-dd').format(lastDay);

    try {
      // 2. Query Attendance Collection
      Query attendanceQuery = FirebaseFirestore.instance.collection('attendance')
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr);

      if (selectedDepartment != "All") {
        attendanceQuery = attendanceQuery.where('department', isEqualTo: selectedDepartment);
      }

      final attendanceSnap = await attendanceQuery.get();

      // Reset counters
      int p = 0, a = 0, l = 0, m = 0;

      for (var doc in attendanceSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? "";
        
        if (status == "Present") p++;
        if (status == "Absent") a++;
        if (status == "Late") l++;
        if (data['clockOut'] == null || data['clockOut'] == "--:--") m++;
      }

      // 3. Query Leave Requests (Approved only for this month)
      final leaveSnap = await FirebaseFirestore.instance.collection('leaveRequests')
          .where('status', isEqualTo: 'Approved')
          .where('startDate', isGreaterThanOrEqualTo: startStr)
          .get();

      setState(() {
        totalPresents = p;
        totalAbsents = a;
        totalLate = l;
        missedCheckIns = m;
        totalLeave = leaveSnap.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching report: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0F4),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchSection(context),
                      const SizedBox(height: 30),
                      
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildStatCard("Total Presents", totalPresents.toString()),
                          _buildStatCard("Total Absents", totalAbsents.toString()),
                          _buildStatCard("Total Late", totalLate.toString()),
                          _buildStatCard("Total Leave", totalLeave.toString()),
                          _buildStatCard("Missed Check-ins", missedCheckIns.toString()),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildChartSection(),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFFD9D9D9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Monthly Report", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(DateFormat('MMMM yyyy').format(selectedMonth), style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const Icon(Icons.download_rounded), // Changed to download for report context
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          _buildFilterDropdown("Department", ["All", "IT", "HR", "Sales", "Finance"], (val) {
             setState(() => selectedDepartment = val!);
          }, selectedDepartment),
          const SizedBox(width: 20),
          _buildMonthPicker(),
          const Spacer(),
          ElevatedButton(
            onPressed: _fetchMonthlyData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000080),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            ),
            child: const Text("GENERATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> options, ValueChanged<String?> onChanged, String currentVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: const Color(0xFFE3E8FF), border: Border.all(color: Colors.black12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentVal,
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Month", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        InkWell(
          onTap: () async {
            // Simple Month Picker Logic
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedMonth,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => selectedMonth = picked);
          },
          child: Container(
            width: 200, height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: const Color(0xFFE3E8FF), border: Border.all(color: Colors.black12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('MMMM yyyy').format(selectedMonth)),
                const Icon(Icons.calendar_month, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF000080))),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    double total = (totalPresents + totalAbsents + totalLate + totalLeave).toDouble();
    if (total == 0) total = 1; // Prevent division by zero

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          SizedBox(
            height: 250, width: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: const Color(0xFF000080), value: totalPresents.toDouble(), radius: 50, showTitle: false),
                  PieChartSectionData(color: Colors.yellow[700], value: totalAbsents.toDouble(), radius: 50, showTitle: false),
                  PieChartSectionData(color: Colors.greenAccent[400], value: totalLate.toDouble(), radius: 50, showTitle: false),
                  PieChartSectionData(color: Colors.purple[300], value: totalLeave.toDouble(), radius: 50, showTitle: false),
                ],
              ),
            ),
          ),
          const SizedBox(width: 60),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(const Color(0xFF000080), "Presents"),
        _buildLegendItem(Colors.yellow[700]!, "Absents"),
        _buildLegendItem(Colors.greenAccent[400]!, "Late"),
        _buildLegendItem(Colors.purple[300]!, "Leaves"),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}