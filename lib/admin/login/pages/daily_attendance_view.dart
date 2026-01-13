import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyAttendancePage extends StatefulWidget {
  const DailyAttendancePage({super.key});

  @override
  State<DailyAttendancePage> createState() => _DailyAttendancePageState();
}

class _DailyAttendancePageState extends State<DailyAttendancePage> {
  final TextEditingController _deptController = TextEditingController();
  
  // FIXED: Ensure this matches the D/M/YYYY format in your DB (e.g., 4/1/2026)
  String selectedDate = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  
  bool _hasSearched = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- DATABASE SYNC LOGIC ---
  Stream<QuerySnapshot> _getFilteredStream() {
    // 1. Pointing to 'attendance_logs' collection
    Query query = _firestore.collection('attendance_logs');

    // 2. Filter by date string
    query = query.where('date', isEqualTo: selectedDate);
    
    if (_deptController.text.isNotEmpty) {
      query = query.where('dept', isEqualTo: _deptController.text.trim());
    }
    
    // 3. Sort by creation. 
    // IMPORTANT: You MUST click the link in your Debug Console to create the Index!
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // FILTER SECTION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Daily Attendance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              Row(
                children: [
                  _buildSearchField("Department Name", _deptController),
                  const SizedBox(width: 40),
                  _buildFilterDatePicker("Date", selectedDate),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => setState(() => _hasSearched = true),
                    style: _buttonStyle(const Color(0xFF0B1D4D)),
                    child: const Text("SEARCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // REAL-TIME TABLE SECTION
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: _boxDecoration(),
            child: Column(
              children: [
                _buildTableHeader(),
                Expanded(
                  child: !_hasSearched 
                    ? const Center(child: Text("Enter search criteria and click Search to view records."))
                    : StreamBuilder<QuerySnapshot>(
                        stream: _getFilteredStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            // This catch displays the index error from your image
                            return Center(
                              child: Text(
                                "Error: Firestore Index required. Check the VS Code Debug Console for the link.",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                          var docs = snapshot.data!.docs;

                          if (docs.isEmpty) {
                            return const Center(child: Text("No records found. Make sure the Date format in DB is D/M/YYYY."));
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.only(top: 10),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              var data = docs[index].data() as Map<String, dynamic>;
                              return _buildDataRow(data);
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- UI HELPERS ---
  Widget _buildDataRow(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.black12)
      ),
      child: Row(
        children: [
          // FIXED: Matches 'id' key in your database
          Expanded(child: Text(data["id"] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(data["name"] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(data["dept"] ?? "N/A")),
          // FIXED: Matches 'in' and 'out' keys in your database
          Expanded(child: Text(data["in"] ?? "--:--", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold))),
          Expanded(child: Text(data["out"] ?? "--:--", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold))),
          Expanded(child: Text(data["status"] ?? "Present", style: TextStyle(fontWeight: FontWeight.bold, color: data["status"] == "Absent" ? Colors.red : Colors.green))),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
  );

  ButtonStyle _buttonStyle(Color color) => ElevatedButton.styleFrom(
    backgroundColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget _buildSearchField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: 300,
          decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black26)),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "e.g. IT Department", contentPadding: EdgeInsets.symmetric(horizontal: 15), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDatePicker(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context, 
              initialDate: DateTime.now(), 
              firstDate: DateTime(2020), 
              lastDate: DateTime(2100)
            );
            if (picked != null) {
              setState(() {
                // Formatting as D/M/YYYY to match your database format
                selectedDate = "${picked.day}/${picked.month}/${picked.year}";
              });
            }
          },
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black26)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(date), const Icon(Icons.calendar_today, size: 18)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: const BoxDecoration(color: Color(0xFF0B1D4D), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      child: const Row(
        children: [
          Expanded(child: Text("Emp ID", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(flex: 2, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("Dept", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("In Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("Out Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
        ],
      ),
    );
  }
}