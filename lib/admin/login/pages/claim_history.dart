import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase

class ClaimHistoryPage extends StatefulWidget {
  const ClaimHistoryPage({super.key});

  @override
  State<ClaimHistoryPage> createState() => _ClaimHistoryPageState();
}

class _ClaimHistoryPageState extends State<ClaimHistoryPage> {
  // Logic for filtering
  String _searchQuery = "";
  final TextEditingController _claimTypeController = TextEditingController();

  // Stream to listen to the 'claims' collection in Firestore
  Stream<QuerySnapshot> _getClaimsStream() {
    return FirebaseFirestore.instance
        .collection('claims')
        .orderBy('submittedAt', descending: true) // Newest claims first
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Claim History", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              // Dynamic counter using a StreamBuilder
              StreamBuilder<QuerySnapshot>(
                stream: _getClaimsStream(),
                builder: (context, snapshot) {
                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Text("$count Total Claims", style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                }
              ),
            ],
          ),
        ),

        // SEARCH CARD
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Claims", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              Row(
                children: [
                  _buildSearchInput("Claims Type", 300, _claimTypeController),
                  const SizedBox(width: 32),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = _claimTypeController.text.trim();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1D4D),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                    child: const Text("SEARCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // HISTORY TABLE (DYNAMIC)
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildTableHeader(["Claim ID", "Name", "Email", "Claim Type", "Action"]),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getClaimsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text("Error loading claims"));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      // Filter logic for the list
                      var docs = snapshot.data!.docs;
                      if (_searchQuery.isNotEmpty) {
                        docs = docs.where((doc) => 
                          doc['type'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
                        ).toList();
                      }

                      if (docs.isEmpty) return const Center(child: Text("No claims found."));

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;
                          return _buildHistoryRow(
                            data['claimId'] ?? 'N/A',
                            data['name'] ?? 'Unknown',
                            data['email'] ?? 'N/A',
                            data['type'] ?? 'General',
                          );
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

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
  );

  Widget _buildSearchInput(String label, double width, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Color(0xFFA7BBC7)),
      child: Row(
        children: labels.map((l) => Expanded(child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }

  Widget _buildHistoryRow(String id, String name, String email, String type) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          Expanded(child: Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(email)),
          Expanded(child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blueGrey),
              onPressed: () {
                // Future: Show claim details/attachments
              },
            ),
          ),
        ],
      ),
    );
  }
}