import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddRequestPage extends StatefulWidget {
  const AddRequestPage({super.key});

  @override
  State<AddRequestPage> createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  late String? _fotoBase64 = "";
  XFile? image;

  Future<void> _getLocationAndUpload(BuildContext context) async {
    await Geolocator.requestPermission();
    final position = await Geolocator.getCurrentPosition();
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('solicitacoes').add({
      'titulo': tituloController.text,
      'descricao': descricaoController.text,
      'fotoUrl': "imageUrl",
      'usuario': user?.email,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'data': Timestamp.now(),
      'imagem_base64': _fotoBase64,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> tirarFoto() async {
      final picker = ImagePicker();
      final imagem = await picker.pickImage(source: ImageSource.camera);

      if (imagem != null) {
        final originalBytes = await imagem.readAsBytes();

        final compressedBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          quality: 60,
          minWidth: 640,
          minHeight: 480,
          format: CompressFormat.jpeg,
        );
        setState(() {
          _fotoBase64 = base64Encode(compressedBytes);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Nova Solicitação", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => _getLocationAndUpload(context),
            child: Text("Cadastrar", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: tituloController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await tirarFoto();
                },
                icon: Icon(Icons.camera_alt),
                label: Text("Tirar Foto"),
              ),
              if (_fotoBase64 != "")
                Image.memory(base64Decode(_fotoBase64!), fit: BoxFit.cover),
            ],
          ),
        ),
      ),
    );
  }
}
