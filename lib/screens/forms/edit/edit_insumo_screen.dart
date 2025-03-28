// edit_insumo_screen.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/insumos_provider.dart';
import 'package:mspaa/widgets/footer.dart';
import 'package:mspaa/widgets/header.dart';

class EditInsumoScreen extends StatefulWidget {
  final Map<String, dynamic> insumo;

  const EditInsumoScreen({super.key, required this.insumo});

  @override
  _EditInsumoScreenState createState() => _EditInsumoScreenState();
}

class _EditInsumoScreenState extends State<EditInsumoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _description = widget.insumo['ins_desc'] ?? '';
    _unit = widget.insumo['ins_unidad_medida'] ?? '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final insumoData = {
        'ins_desc': _description,
        'ins_unidad_medida': _unit,
      };

      Provider.of<InsumosProvider>(context, listen: false)
          .editInsumo(widget.insumo['ins_id'], insumoData)
          .then((isUpdated) {
        if (isUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insumo actualizado con éxito')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el insumo')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Header(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar Insumo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(labelText: 'Descripción del Insumo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una descripción';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unidad de Medida'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una unidad de medida';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _unit = value!;
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
