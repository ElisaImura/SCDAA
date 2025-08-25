// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cultivos_variedades_provider.dart';

class EditVariedadScreen extends StatefulWidget {
  final Map<String, dynamic> variedad;

  const EditVariedadScreen({super.key, required this.variedad});

  @override
  _EditVariedadScreenState createState() => _EditVariedadScreenState();
}

class _EditVariedadScreenState extends State<EditVariedadScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;

  @override
  void initState() {
    super.initState();
    _nombre = widget.variedad['tpVar_nombre'] ?? '';
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<CultivosVariedadesProvider>(context, listen: false);
      final result = await provider.editVariedad(widget.variedad['tpVar_id'], {
        'tpVar_nombre': _nombre,
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Variedad actualizada con éxito')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar la variedad')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Variedad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre de la variedad'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                onSaved: (value) => _nombre = value!,
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
    );
  }
}
