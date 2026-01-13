import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

    // Define Date Range for the selected month
    DateTime firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    
    String startStr = DateFormat('yyyy-MM-dd').format(firstDay);
    String endStr = DateFormat('yyyy-MM-dd').format(lastDay);

    try {
      // 1. Query Attendance Collection
      Query attendanceQuery = FirebaseFirestore.instance.collection('attendance')
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr);

      if (selectedDepartment != "All") {
        attendanceQuery = attendanceQuery.where('department', isEqualTo: selectedDepartment);
      }

      final attendanceSnap = await attendanceQuery.get();

      int p = 0, a = 0, l = 0, m = 0;

      for (var doc in attendanceSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Case-insensitive matching to prevent data sync issues
        String status = (data['status'] ?? "").toString().toLowerCase();
        
        if (status == "present") p++;
        if (status == "absent") a++;
        if (status == "late") l++;
        
        // Checking for missed check-outs
        if (data['clockOut'] == null || data['clockOut'] == "--:--" || data['clockOut'] == "") {
          m++;
        }
      }

      // 2. Query Leave Requests (Approved only)
      Query leaveQuery = FirebaseFirestore.instance.collection('leaveRequests')
          .where('status', isEqualTo: 'Approved')
          .where('startDate', isGreaterThanOrEqualTo: startStr)
          .where('startDate', isLessThanOrEqualTo: endStr);

      if (selectedDepartment != "All") {
        leaveQuery = leaveQuery.where('department', isEqualTo: selectedDepartment);
      }

      final leaveSnap = await leaveQuery.get();

      setState(() {
        totalPresents = p;
        totalAbsents = a;
        totalLate = l;
        missedCheckIns = m;
        totalLeave = leaveSnap.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      // This will now print the error link if a Firestore index is missing
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
                      _buildSearchSection(),
                      const SizedBox(height: 30),
                      _buildStatGrid(),
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
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 24, right: 24),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMonthlyData,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedDepartment,
              decoration: const InputDecoration(
                labelText: "Department", 
                filled: true, 
                fillColor: Colors.white, // FIXED: Changed from fillAreaColor
                border: OutlineInputBorder(),
              ),
              items: ["All", "IT", "HR", "Sales", "Finance"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedDepartment = val!),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: _fetchMonthlyData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000080),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            ),
            child: const Text("GENERATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildStatCard("Total Presents", totalPresents.toString(), const Color(0xFF000080)),
        _buildStatCard("Total Absents", totalAbsents.toString(), Colors.orange),
        _buildStatCard("Total Late", totalLate.toString(), Colors.green),
        _buildStatCard("Total Leave", totalLeave.toString(), Colors.purple),
        _buildStatCard("Missed Check-ins", missedCheckIns.toString(), Colors.redAccent),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
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
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    bool hasData = (totalPresents + totalAbsents + totalLate + totalLeave) > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: hasData 
        ? Row(
            children: [
              SizedBox(
                height: 250, width: 250,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(color: const Color(0xFF000080), value: totalPresents.toDouble(), radius: 50, showTitle: false),
                      PieChartSectionData(color: Colors.orange, value: totalAbsents.toDouble(), radius: 50, showTitle: false),
                      PieChartSectionData(color: Colors.green, value: totalLate.toDouble(), radius: 50, showTitle: false),
                      PieChartSectionData(color: Colors.purple, value: totalLeave.toDouble(), radius: 50, showTitle: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40),
              _buildLegend(),
            ],
          )
        : const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("No data available for this month."),
          )),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(const Color(0xFF000080), "Presents"),
        _buildLegendItem(Colors.orange, "Absents"),
        _buildLegendItem(Colors.green, "Late"),
        _buildLegendItem(Colors.purple, "Leaves"),
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