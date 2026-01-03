import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEmployeePage extends StatefulWidget {
  final String id;
  final String name;
  final String email;
  final String department;

  const EditEmployeePage({
    super.key,
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  @override
  State<EditEmployeePage> createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 1. Controllers to handle user input
  late TextEditingController _fNameController;
  late TextEditingController _lNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _deptController;
  late TextEditingController _positionController;

  String _selectedShift = "Fixed";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Logic to split "Alice Wong" into First and Last names
    List<String> names = widget.name.split(" ");
    String fName = names.isNotEmpty ? names.first : "";
    String lName = names.length > 1 ? names.sublist(1).join(" ") : "";

    // 2. Initialize controllers with existing data
    _fNameController = TextEditingController(text: fName);
    _lNameController = TextEditingController(text: lName);
    _emailController = TextEditingController(text: widget.email);
    _deptController = TextEditingController(text: widget.department);
    _phoneController = TextEditingController(text: "0123456789"); // Default placeholder
    _positionController = TextEditingController(text: "Employee"); // Default placeholder
  }

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deptController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  // 3. DATABASE LOGIC: Update Employee in Firestore
  Future<void> _updateEmployee() async {
    setState(() => _isLoading = true);
    try {
      String fullName = "${_fNameController.text.trim()} ${_lNameController.text.trim()}";
      
      await _firestore.collection('employees').doc(widget.id).update({
        'name': fullName,
        'email': _emailController.text.trim(),
        'department': _deptController.text.trim(),
        'phone': _phoneController.text.trim(),
        'position': _positionController.text.trim(),
        'shiftType': _selectedShift,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile for $fullName updated successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildMainFormCard(),
              ],
            ),
          ),
    );
  }

  // --- UI SECTIONS ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Edit Employee', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text('Modify employee information and work schedule', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildMainFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildCardBlueHeader(),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSection(),
                const SizedBox(width: 40),
                Expanded(child: _buildPersonalColumn()),
                const SizedBox(width: 40),
                Expanded(child: _buildJobColumn()),
              ],
            ),
          ),
          _buildFooterButtons(),
        ],
      ),
    );
  }

  Widget _buildCardBlueHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(color: Color(0xFFA6BDCC), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      child: const Text('Employee Profile Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
          child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: () {}, child: const Text("Change Photo", style: TextStyle(fontSize: 12))),
      ],
    );
  }

  Widget _buildPersonalColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1D4D))),
        const SizedBox(height: 20),
        _buildField("Employee ID (ReadOnly)", TextEditingController(text: widget.id), enabled: false),
        _buildField("First Name", _fNameController),
        _buildField("Last Name", _lNameController),
        _buildField("Email Address", _emailController),
        _buildField("Phone Number", _phoneController),
      ],
    );
  }

  Widget _buildJobColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Job Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1D4D))),
        const SizedBox(height: 20),
        _buildField("Position", _positionController),
        _buildField("Department", _deptController),
        const SizedBox(height: 20),
        const Text('Work Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildClickableToggle("Fixed"),
            const SizedBox(width: 10),
            _buildClickableToggle("Shift"),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Color(0xFFF0F4F7), borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          const SizedBox(width: 15),
          ElevatedButton.icon(
            onPressed: _updateEmployee,
            icon: const Icon(Icons.save, size: 18),
            label: const Text("Save Changes"),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: TextStyle(color: enabled ? Colors.black : Colors.grey),
              decoration: InputDecoration(
                filled: true,
                fillColor: enabled ? const Color(0xFFF9F9F9) : const Color(0xFFEEEEEE),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableToggle(String label) {
    bool isActive = _selectedShift == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedShift = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0B1D4D) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF0B1D4D)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.white : const Color(0xFF0B1D4D))),
      ),
    );
  }
}