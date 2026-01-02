import 'package:flutter/material.dart';

class SystemConfigurationPage extends StatefulWidget {
  const SystemConfigurationPage({super.key});

  @override
  State<SystemConfigurationPage> createState() => _SystemConfigurationPageState();
}

class _SystemConfigurationPageState extends State<SystemConfigurationPage> {
  // Toggle States
  bool pushNotify = true;
  bool emailNotify = true;
  bool smsNotify = true;
  bool geofencingEnabled = true;
  
  final TextEditingController radiusController = TextEditingController(text: "200");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F7), // Light background from screenshot
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            color: const Color(0xFFD9D9D9), // Grey header area
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "System Configuration",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () {}, // Logout logic
                )
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Admin Profile", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PROFILE INFO SECTION
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFFD9D9D9),
                        child: Icon(Icons.person, size: 45, color: Colors.black54),
                      ),
                      const SizedBox(width: 30),
                      Column(
                        children: [
                          _buildProfileField("ID", "AD001"),
                          const SizedBox(height: 15),
                          _buildProfileField("Name", "Syahira binti Azman"),
                          const SizedBox(height: 15),
                          _buildProfileField("Email", "azsyah@ds.com"),
                        ],
                      ),

                      const Spacer(),

                      // NOTIFICATION SECTION
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Notification", 
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildToggleRow("Push Notifications", pushNotify, (val) => setState(() => pushNotify = val)),
                          _buildToggleRow("Email Notifications", emailNotify, (val) => setState(() => emailNotify = val)),
                          _buildToggleRow("SMS Notifications", smsNotify, (val) => setState(() => smsNotify = val)),
                        ],
                      ),
                      const SizedBox(width: 100), // Spacing for right margin
                    ],
                  ),

                  const SizedBox(height: 60),

                  // GEOFENCING SECTION
                  const Text("Geofencing", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Text("Geofencing", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 130),
                      Switch(
                        value: geofencingEnabled,
                        // FIXED: Replaced deprecated activeColor with activeTrackColor
                        activeTrackColor: const Color(0xFF6750A4), 
                        onChanged: (val) => setState(() => geofencingEnabled = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Allowed Radius (meters)", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 20),
                      Container(
                        width: 80,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black26),
                        ),
                        child: TextField(
                          controller: radiusController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build ID, Name, Email boxes
  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Helper to build Notification Toggle Rows
  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 180, child: Text(title, style: const TextStyle(fontSize: 16))),
          Switch(
            value: value,
            // FIXED: Replaced deprecated activeColor with activeTrackColor
            activeTrackColor: const Color(0xFF6750A4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}