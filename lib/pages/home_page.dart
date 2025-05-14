import 'package:central_atendimento_utf/pages/add_request_page.dart';
import 'package:central_atendimento_utf/pages/detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String getCustomDate(Timestamp dataTimestamp) {
    DateTime toDate = dataTimestamp.toDate();
    return "${toDate.day.toString().padLeft(2, '0')}/${toDate.month.toString().padLeft(2, '0')}/${toDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(
          "Solicitações Públicas",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddRequestPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('solicitacoes')
                .orderBy('data', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text("Ainda não há solicitações realizadas"));
          }
          return ListView(
            children:
                docs.map((doc) {
                  final data = doc.data();
                  return ListTile(
                    title: Text(data['titulo'] ?? 'Sem título'),
                    subtitle: Text(getCustomDate((data['data'] as Timestamp))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => SolicitacaoDetalhesPage(solicitacao: doc),
                        ),
                      );
                    },
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
