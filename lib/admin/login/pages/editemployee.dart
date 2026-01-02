import 'package:flutter/material.dart';

class EditEmployeePage extends StatefulWidget {
  // 1. Add variables to hold the data passed from the list
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
  String _selectedShift = "Fixed";
  
  // Variables to split the full name into First/Last
  late String firstName;
  late String lastName;

  @override
  void initState() {
    super.initState();
    // Logic to split "Alice Wong" into "Alice" and "Wong"
    List<String> names = widget.name.split(" ");
    firstName = names.isNotEmpty ? names.first : "";
    lastName = names.length > 1 ? names.sublist(1).join(" ") : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Edit Employee', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    Text('Fill in the employee information below', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // MAIN CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // Blue Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFA6BDCC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  // FORM CONTENT
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.person, size: 60, color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 40),

                        // LEFT COLUMN (Personal Info)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              // 2. Use "widget.variable" to display the passed data
                              _buildField("Employee ID", widget.id),
                              _buildField("First Name", firstName),
                              _buildField("Last Name", lastName),
                              _buildField("Email", widget.email),
                              _buildField("Phone Number", "0123456789"), // Placeholder
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),

                        // RIGHT COLUMN (Job Info)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Job Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              _buildField("Position", "Employee"), // Placeholder
                              _buildField("Employment Type", "Full Time"),
                              _buildField("Department", widget.department),
                              _buildField("Date Joined", "01/01/2023"),
                              _buildField("Supervisor", "-"),
                              
                              const SizedBox(height: 20),
                              const Text('Work Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text("Shift Type", style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 15),
                                  _buildClickableToggle("Fixed"),
                                  const SizedBox(width: 10),
                                  _buildClickableToggle("Shift"),
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Text("Work Hours   9:00  to  18:00", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // FOOTER BUTTONS
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F4F7),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text("Cancel"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: () {
                             Navigator.pop(context);
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved details for ${widget.name}")));
                          },
                          icon: const Icon(Icons.save, size: 16),
                          label: const Text("Save Employee"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D), foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(text: TextSpan(text: label, style: const TextStyle(color: Colors.black87, fontSize: 13), children: const [TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: TextField(
              controller: TextEditingController(text: value), // Displays the specific value
              decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF5F5F5), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(color: isActive ? const Color(0xFFC5CAE9) : const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }
}