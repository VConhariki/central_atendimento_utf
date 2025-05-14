import 'dart:convert';
import 'dart:typed_data';

import 'package:central_atendimento_utf/edit_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SolicitacaoDetalhesPage extends StatefulWidget {
  final DocumentSnapshot solicitacao;

  const SolicitacaoDetalhesPage({super.key, required this.solicitacao});

  @override
  State<SolicitacaoDetalhesPage> createState() =>
      _SolicitacaoDetalhesPageState();
}

class _SolicitacaoDetalhesPageState extends State<SolicitacaoDetalhesPage> {
  final user = FirebaseAuth.instance.currentUser;
  late DocumentSnapshot solicitacaoAtual;
  @override
  void initState() {
    super.initState();
    solicitacaoAtual = widget.solicitacao;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.solicitacao.data() as Map<String, dynamic>;
    final isDono = data['usuario'] == user?.email;
    final base64Image = data['imagem_base64'];
    Uint8List? imagemBytes =
        base64Image != null ? base64Decode(base64Image) : null;
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text('Detalhes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['titulo'] ?? '',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(data['descricao'] ?? '', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            if (data['imageUrl'] != null)
              Image.network(data['imageUrl'], fit: BoxFit.cover),
            SizedBox(height: 8),
            Text("Localização: ${data['latitude']}, ${data['longitude']}"),
            SizedBox(height: 8),
            Text("Data: ${data['data'].toDate()}"),
            SizedBox(height: 16),
            if (imagemBytes != null)
              Image.memory(imagemBytes, fit: BoxFit.cover),
            SizedBox(height: 16),
            if (isDono)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _editarSolicitacao,
                    child: Text("Editar"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _excluirSolicitacao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Excluir",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 24),
            Text(
              "Comentários",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildComentarios(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarComentario,
        child: Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildComentarios() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('solicitacoes')
              .doc(widget.solicitacao.id)
              .collection('comentarios')
              .orderBy('data', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final comentarios = snapshot.data!.docs;

        if (comentarios.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Nenhum comentário ainda."),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comentarios.length,
          itemBuilder: (context, index) {
            final coment = comentarios[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(coment['texto'] ?? ''),
              subtitle: Text(coment['autor'] ?? ''),
            );
          },
        );
      },
    );
  }

  void _adicionarComentario() {
    showDialog(
      context: context,
      builder: (context) {
        final _controller = TextEditingController();

        return AlertDialog(
          title: Text("Novo comentário"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Digite seu comentário..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                final texto = _controller.text.trim();
                if (texto.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('solicitacoes')
                      .doc(widget.solicitacao.id)
                      .collection('comentarios')
                      .add({
                        'texto': texto,
                        'autor': user?.email ?? 'Anônimo',
                        'data': Timestamp.now(),
                      });
                }
                Navigator.pop(context);
              },
              child: Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  void _excluirSolicitacao() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Excluir solicitação"),
            content: Text("Tem certeza que deseja excluir esta solicitação?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Excluir"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('solicitacoes')
          .doc(widget.solicitacao.id)
          .delete();
      Navigator.pop(context);
    }
  }

  void _editarSolicitacao() async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarSolicitacaoPage(solicitacao: widget.solicitacao),
      ),
    );

    if (atualizado != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('solicitacoes')
              .doc(widget.solicitacao.id)
              .get();
      setState(() {
        solicitacaoAtual = doc;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Solicitação atualizada com sucesso.")),
      );
    }
  }
}
