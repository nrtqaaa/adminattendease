import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManualAttendancePage extends StatefulWidget {
  const ManualAttendancePage({super.key});

  @override
  State<ManualAttendancePage> createState() => _ManualAttendancePageState();
}

class _ManualAttendancePageState extends State<ManualAttendancePage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _inTimeController = TextEditingController();
  final TextEditingController _outTimeController = TextEditingController();

  bool _isSearching = false;

  // --- LOGIC: Auto-fill Name from Employee ID ---
  Future<void> _lookupEmployee(String id) async {
    if (id.isEmpty) {
      setState(() => _nameController.clear());
      return;
    }
    
    setState(() => _isSearching = true);
    
    try {
      // FIXED: Queries 'users' collection where 'employeeId' field matches
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users') 
          .where('employeeId', isEqualTo: id.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        setState(() {
          _nameController.text = userData['name'] ?? "";
        });
      } else {
        setState(() {
          _nameController.text = "Employee not found";
        });
      }
    } catch (e) {
      debugPrint("Lookup failed: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // --- LOGIC: Save to Firebase ---
  Future<void> _handleSave() async {
    if (_idController.text.isEmpty || _nameController.text.isEmpty || _nameController.text == "Employee not found" || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a valid Employee ID and Date"), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      // UPDATED: Points to 'attendance_logs' collection
      await FirebaseFirestore.instance.collection('attendance_logs').add({
        'employeeId': _idController.text.trim(),
        'name': _nameController.text.trim(),
        'date': _dateController.text,
        'clockIn': _inTimeController.text,
        'clockOut': _outTimeController.text,
        'duration': _calculateDuration(),
        'status': 'PENDING', // Default status based on DB structure
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance record saved!"), backgroundColor: Colors.green),
        );
        _clearForm();
      }
    } catch (e) {
      debugPrint("Save failed: $e");
    }
  }

  void _clearForm() {
    setState(() {
      _idController.clear();
      _nameController.clear();
      _dateController.clear();
      _inTimeController.clear();
      _outTimeController.clear();
    });
  }

  // --- UI AND HELPER METHODS ---
  // (Duration logic and Pickers remain the same as your previous version)

  String _calculateDuration() {
    if (_inTimeController.text.isEmpty || _outTimeController.text.isEmpty) return "0h 0m";
    try {
      TimeOfDay inTime = _parseTimeString(_inTimeController.text);
      TimeOfDay outTime = _parseTimeString(_outTimeController.text);
      int inMinutes = inTime.hour * 60 + inTime.minute;
      int outMinutes = outTime.hour * 60 + outTime.minute;
      if (outMinutes <= inMinutes) outMinutes += 24 * 60;
      int diff = outMinutes - inMinutes;
      return "${diff ~/ 60}h ${diff % 60}m";
    } catch (e) { return "0h 0m"; }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final format = RegExp(r'(\d+):(\d+)\s+(AM|PM)');
    final match = format.firstMatch(timeStr);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!;
      if (period == "PM" && hour != 12) hour += 12;
      if (period == "AM" && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay.now();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => controller.text = picked.format(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Attendance / Manual Entry", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Manual Attendance Entry Form", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B1D4D))),
                  const Divider(height: 40),
                  const Text("EMPLOYEE INFORMATION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 20),
                  _buildFormRow("Employee ID:", TextField(
                    controller: _idController,
                    onChanged: _lookupEmployee,
                    decoration: InputDecoration(
                      hintText: "e.g. EMP123", // Matches example
                      suffixIcon: _isSearching ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))) : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )),
                  _buildFormRow("Full Name:", _buildTextField(_nameController, "Name will auto-fill", readOnly: true)),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text("ATTENDANCE DETAILS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 20),
                  _buildFormRow("Date:", _buildPickerField(_dateController, "Select Date", Icons.calendar_today, _selectDate)),
                  _buildFormRow("Clock-In:", _buildPickerField(_inTimeController, "Select Time", Icons.access_time, () => _selectTime(_inTimeController))),
                  _buildFormRow("Clock-Out:", _buildPickerField(_outTimeController, "Select Time", Icons.access_time, () => _selectTime(_outTimeController))),
                  const SizedBox(height: 30),
                  Center(child: _buildDurationBadge()),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton("ADD RECORD", const Color(0xFF0B1D4D), _handleSave),
                const SizedBox(width: 20),
                _buildActionButton("CLEAR FORM", Colors.red.shade900, _clearForm),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildFormRow(String label, Widget input) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: input),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPickerField(TextEditingController controller, String hint, IconData icon, VoidCallback onTap) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF0B1D4D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDurationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFF0B1D4D), size: 20),
          const SizedBox(width: 10),
          const Text("Calculated Shift: ", style: TextStyle(fontWeight: FontWeight.w500)),
          Text(_calculateDuration(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0B1D4D))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 200, height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}