import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SystemConfigPage extends StatefulWidget {
  const SystemConfigPage({super.key});
  @override
  State<SystemConfigPage> createState() => _SystemConfigPageState();
}

class _SystemConfigPageState extends State<SystemConfigPage> {
  // Controllers for editing
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  
  bool isEditing = false; // Toggle for edit mode
  bool isSaving = false;

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
        if (doc.exists && mounted) {
          setState(() {
            _nameController.text = doc['name'] ?? "";
            _idController.text = doc['employeeID'] ?? "AD-${user.uid.substring(0, 4)}";
          });
        }
      } catch (e) {
        debugPrint("Error loading user: $e");
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

  // FUNCTION TO SAVE UPDATED PROFILE TO FIREBASE
  Future<void> _saveProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'employeeID': _idController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      setState(() => isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    } finally {
      setState(() => isSaving = false);
    }
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
          Row(
            children: [
              const Text("Admin Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              // EDIT / SAVE BUTTON
              IconButton(
                icon: Icon(isEditing ? Icons.check_circle : Icons.edit, color: Colors.blueGrey),
                onPressed: () {
                  if (isEditing) {
                    _saveProfile();
                  } else {
                    setState(() => isEditing = true);
                  }
                },
              ),
              if (isSaving) const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(radius: 35, backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, size: 45)),
              const SizedBox(width: 20),
              Column(
                children: [
                  _buildProfileField("ID", _idController, isEditing),
                  _buildProfileField("Name", _nameController, isEditing),
                  _buildProfileField("Email", TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? ""), false), // Email usually locked
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey[200], 
              borderRadius: BorderRadius.circular(8), 
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]
            ),
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
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
              child: TextField(
                controller: _radiusController, 
                textAlign: TextAlign.center, 
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none)
              ),
            ),
          ],
        ),
      ],
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