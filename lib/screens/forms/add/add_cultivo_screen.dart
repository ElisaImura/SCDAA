// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/cultivos_variedades_provider.dart';

class AddCultivoScreen extends StatefulWidget {
  const AddCultivoScreen({super.key});

  @override
  _AddCultivoScreenState createState() => _AddCultivoScreenState();
}

class _AddCultivoScreenState extends State<AddCultivoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nombreCultivo;

  @override
  void initState() {
    super.initState();
    _nombreCultivo = '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Provider.of<CultivosVariedadesProvider>(context, listen: false)
          .addCultivo(_nombreCultivo)
          .then((isAdded) {
        if (isAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tipo de cultivo agregado con éxito')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al agregar el tipo de cultivo')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nuevo Cultivo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Agregar Tipo de Cultivo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Nombre del Tipo de Cultivo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _nombreCultivo = value!;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: const Text('Agregar Tipo de Cultivo'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
