import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClaimHistoryPage extends StatefulWidget {
  const ClaimHistoryPage({super.key});

  @override
  State<ClaimHistoryPage> createState() => _ClaimHistoryPageState();
}

class _ClaimHistoryPageState extends State<ClaimHistoryPage> {
  String _searchQuery = "";
  final TextEditingController _claimTypeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Stream<QuerySnapshot> _getClaimsStream() {
    return FirebaseFirestore.instance
        .collection('claims')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F2),
      body: Row(
        children: [
          // 1. LEFT SIDEBAR
          _buildSidebar(),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSearchCard(),
                        const SizedBox(height: 30),
                        const Text("History", 
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildClaimsTable(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFF000080), // Deep blue from image
      child: Column(
        children: [
          const SizedBox(height: 40),
          const ListTile(
            leading: Icon(Icons.business_center, color: Colors.white, size: 30),
            title: Text("AttendEase", 
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),
          _sidebarItem(Icons.dashboard, "Dashboard"),
          _sidebarItem(Icons.groups, "Employees"),
          _sidebarItem(Icons.calendar_month, "Attendance"),
          _sidebarItem(Icons.description, "Leave Requests"),
          _sidebarItem(Icons.assessment, "Reports"),
          _sidebarItem(Icons.payments, "Payroll"),
          _sidebarItem(Icons.settings, "Settings"),
          const Spacer(),
          _sidebarItem(Icons.account_circle, "Admin"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      onTap: () {},
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      color: const Color(0xFFD9D9D9), // Light grey header from image
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Claim History", 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              StreamBuilder<QuerySnapshot>(
                stream: _getClaimsStream(),
                builder: (context, snapshot) {
                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Text("$count Total Claims", 
                    style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic));
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 30),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Claims", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          Row(
            children: [
              _buildInput("Claims Type", _claimTypeController, 250),
              const SizedBox(width: 20),
              _buildInput("Date", _dateController, 180),
              const Spacer(),
              ElevatedButton(
                onPressed: () => setState(() => _searchQuery = _claimTypeController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000080),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("SEARCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black12),
          ),
          child: TextField(
            controller: ctrl,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
          ),
        ),
      ],
    );
  }

  Widget _buildClaimsTable() {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: const BoxDecoration(
            color: Color(0xFFA7BBC7), // Muted blue-grey header
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              Expanded(child: Text("Claim ID", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              Expanded(child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              Expanded(flex: 2, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              Expanded(child: Text("Claim Type", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              SizedBox(width: 50, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            ],
          ),
        ),
        // Dynamic List
        StreamBuilder<QuerySnapshot>(
          stream: _getClaimsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            var docs = snapshot.data!.docs;
            
            // Filter logic
            if (_searchQuery.isNotEmpty) {
              docs = docs.where((d) => d['type'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                var data = docs[index].data() as Map<String, dynamic>;
                return _buildDataRow(data);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataRow(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Expanded(child: Text(data['claimId'] ?? 'CLM000', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(data['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(data['email'] ?? 'N/A')),
          Expanded(child: Text(data['type'] ?? 'General', style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 50,
            child: IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.black87),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}