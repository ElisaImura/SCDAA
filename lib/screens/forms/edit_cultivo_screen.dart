// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/widgets/footer.dart';
import 'package:mspaa/widgets/header.dart';
import 'package:mspaa/providers/cultivos_variedades_provider.dart';

class EditCultivoScreen extends StatefulWidget {
  final Map<String, dynamic> cultivo;

  const EditCultivoScreen({super.key, required this.cultivo});

  @override
  _EditCultivoScreenState createState() => _EditCultivoScreenState();
}

class _EditCultivoScreenState extends State<EditCultivoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;

  @override
  void initState() {
    super.initState();
    _nombre = widget.cultivo['tpCul_nombre'] ?? '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final cultivoId = widget.cultivo['tpCul_id'];
      final dataActualizada = {'tpCul_nombre': _nombre};

      Provider.of<CultivosVariedadesProvider>(context, listen: false)
          .editCultivo(cultivoId, dataActualizada)
          .then((isUpdated) {
        if (isUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tipo de cultivo actualizado con éxito')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el cultivo')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Header(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar Tipo de Cultivo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _nombre,
                      decoration: const InputDecoration(labelText: 'Nombre del Tipo de Cultivo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del cultivo';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _nombre = value!;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: const Text('Guardar cambios'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
