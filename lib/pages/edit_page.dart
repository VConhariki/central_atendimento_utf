import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarSolicitacaoPage extends StatefulWidget {
  final DocumentSnapshot solicitacao;

  const EditarSolicitacaoPage({super.key, required this.solicitacao});

  @override
  State<EditarSolicitacaoPage> createState() => _EditarSolicitacaoPageState();
}

class _EditarSolicitacaoPageState extends State<EditarSolicitacaoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();
    final data = widget.solicitacao.data() as Map<String, dynamic>;
    _tituloController = TextEditingController(text: data['titulo']);
    _descricaoController = TextEditingController(text: data['descricao']);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarEdicao() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('solicitacoes')
          .doc(widget.solicitacao.id)
          .update({
            'titulo': _tituloController.text.trim(),
            'descricao': _descricaoController.text.trim(),
          });

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Solicitação"),
        leading: BackButton(),
        actions: [
          TextButton(
            onPressed: _salvarEdicao,
            child: Text("Salvar", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o título'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: 4,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe a descrição'
                            : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
