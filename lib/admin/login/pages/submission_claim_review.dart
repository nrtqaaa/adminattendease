import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimReviewPage extends StatelessWidget {
  const ClaimReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('claims')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['employeeName']),
                subtitle: Text("${data['claimType']} - RM ${data['amount']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => doc.reference.update({'status': 'Approved'}),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => doc.reference.update({'status': 'Rejected'}),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}