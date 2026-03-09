import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Мои Пријави")),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("reports")
            .where("userId", isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {

              final r = reports[index];

              return ListTile(
                leading: Image.network(
                  r["imageUrl"],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),

                title: Text(r["category"]),

                subtitle: Text("Статус: ${r["status"]}"),
              );
            },
          );
        },
      ),
    );
  }
}