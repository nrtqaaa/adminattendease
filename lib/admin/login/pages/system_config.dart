import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SystemConfigPage extends StatefulWidget {
  const SystemConfigPage({super.key});
  @override
  State<SystemConfigPage> createState() => _SystemConfigPageState();
}

class _SystemConfigPageState extends State<SystemConfigPage> {
  final TextEditingController _radiusController = TextEditingController();
  
  String adminName = "Loading...";
  String adminEmail = "Loading...";
  String adminID = "...";
  
  bool geofenceOn = true;
  bool pushNotify = true;
  bool emailNotify = true;
  bool smsNotify = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSystemSettings();
  }

  Future<void> _loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            adminName = doc['name'] ?? "No Name";
            adminEmail = user.email ?? "No Email";
            adminID = doc['employeeID'] ?? "AD-${user.uid.substring(0, 4)}";
          });
        } else {
          // Fallback if document doesn't exist in Firestore yet
          setState(() {
            adminName = "Profile Missing";
            adminEmail = user.email ?? "No Email";
            adminID = "NEW_USER";
          });
        }
      } catch (e) {
        setState(() { adminName = "Error Loading"; });
      }
    }
  }

  void _loadSystemSettings() {
    FirebaseFirestore.instance.collection('config').doc('settings').get().then((doc) {
      if (doc.exists && mounted) {
        setState(() {
          geofenceOn = doc['geofencingEnabled'] ?? true;
          _radiusController.text = (doc['allowedRadius'] ?? 200).toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF1),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAdminProfileSection(),
                      const SizedBox(width: 40),
                      _buildNotificationSection(),
                    ],
                  ),
                  const SizedBox(height: 50),
                  _buildGeofencingSection(),
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      color: const Color(0xFFD9D9D9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("System Configuration", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
    );
  }

  Widget _buildAdminProfileSection() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Admin Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(radius: 35, backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, size: 45)),
              const SizedBox(width: 20),
              Column(
                children: [
                  _buildProfileField("ID", adminID),
                  _buildProfileField("Name", adminName),
                  _buildProfileField("Email", adminEmail),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Notification", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildToggle("Push Notifications", pushNotify, (v) => setState(() => pushNotify = v)),
          _buildToggle("Email Notifications", emailNotify, (v) => setState(() => emailNotify = v)),
          _buildToggle("SMS Notifications", smsNotify, (v) => setState(() => smsNotify = v)),
        ],
      ),
    );
  }

  Widget _buildGeofencingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Geofencing", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text("Geofencing Enable", style: TextStyle(fontSize: 16)),
            const SizedBox(width: 20),
            Switch(value: geofenceOn, activeColor: const Color(0xFF6B58A6), onChanged: (v) => setState(() => geofenceOn = v)),
          ],
        ),
        Row(
          children: [
            const Text("Allowed Radius (meters)", style: TextStyle(fontSize: 16)),
            const SizedBox(width: 20),
            Container(
              width: 80,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), color: Colors.white),
              child: TextField(controller: _radiusController, textAlign: TextAlign.center, decoration: const InputDecoration(border: InputBorder.none)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(value: value, activeColor: const Color(0xFF6B58A6), onChanged: onChanged),
      ],
    );
  }
}