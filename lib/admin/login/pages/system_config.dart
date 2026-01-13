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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  
  bool isEditing = false; 
  bool isSaving = false;
  bool geofenceOn = true;

  @override
  void initState() {
    super.initState();
    // Listen to Auth State changes to ensure we load data as soon as the user is ready
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        _loadUserData(user.uid);
        _loadSystemSettings();
      }
    });
  }

  // --- DATABASE OPERATIONS ---

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _nameController.text = doc.data()?['name'] ?? "";
          _idController.text = doc.data()?['employeeID'] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error loading user: $e");
    }
  }

  void _loadSystemSettings() {
    FirebaseFirestore.instance.collection('config').doc('settings').get().then((doc) {
      if (doc.exists && mounted) {
        setState(() {
          geofenceOn = doc.data()?['geofencingEnabled'] ?? true;
          _radiusController.text = (doc.data()?['allowedRadius'] ?? 200).toString();
        });
      }
    });
  }

  Future<void> _saveProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);
    try {
      // Use set with merge:true to ensure document creation if it doesn't exist
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'employeeID': _idController.text.trim(),
        'email': user.email,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          isEditing = false;
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin Profile Synced to Cloud"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Save failed: $e");
      setState(() => isSaving = false);
    }
  }

  // ... (Geofence save logic remains same as previous) ...

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
                  _buildAdminProfileSection(),
                  const SizedBox(height: 50),
                  const Divider(),
                  const SizedBox(height: 30),
                  _buildGeofencingSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header, Profile Fields, and Geofencing UI sections from previous code
  // ...
  
  Widget _buildAdminProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Admin Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit, 
                         color: isEditing ? Colors.green : Colors.blueGrey),
              onPressed: () {
                if (isEditing) {
                  _saveProfile();
                } else {
                  setState(() => isEditing = true);
                }
              },
            ),
            if (isSaving) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const CircleAvatar(radius: 35, backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, size: 45)),
            const SizedBox(width: 30),
            _buildProfileField("ID", _idController, isEditing),
            const SizedBox(width: 20),
            _buildProfileField("Name", _nameController, isEditing),
            const SizedBox(width: 20),
            _buildProfileField("Email", TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? ""), false),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, bool enabled) {
    return Column(
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
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
      ],
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

  Widget _buildGeofencingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Geofencing Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text("Enable Geofencing Restriction", style: TextStyle(fontSize: 16)),
              const Spacer(),
              Switch(
                value: geofenceOn, 
                activeColor: const Color(0xFF0B1D4D), 
                onChanged: (v) {
                  setState(() => geofenceOn = v);
                  _saveGeofenceSettings();
                }
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text("Allowed Attendance Radius (meters)", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 20),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _radiusController, 
                  textAlign: TextAlign.center, 
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                  onSubmitted: (value) => _saveGeofenceSettings(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveGeofenceSettings,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D)),
                child: const Text("Set Radius", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveGeofenceSettings() async {
    try {
      int radius = int.tryParse(_radiusController.text) ?? 200;
      await FirebaseFirestore.instance.collection('config').doc('settings').set({
        'geofencingEnabled': geofenceOn,
        'allowedRadius': radius,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Geofencing updated"), backgroundColor: Colors.blueGrey),
        );
      }
    } catch (e) {
      debugPrint("Error saving settings: $e");
    }
  }
}