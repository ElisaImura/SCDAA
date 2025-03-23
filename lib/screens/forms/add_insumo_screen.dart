// add_insumo_screen.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/insumos_provider.dart';
import 'package:mspaa/widgets/footer.dart';
import 'package:mspaa/widgets/header.dart';

class AddInsumoScreen extends StatefulWidget {
  const AddInsumoScreen({super.key});

  @override
  _AddInsumoScreenState createState() => _AddInsumoScreenState();
}

class _AddInsumoScreenState extends State<AddInsumoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  late String _unidadMedida;

  @override
  void initState() {
    super.initState();
    _description = '';
    _unidadMedida = '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _description = _description.toString();
      _unidadMedida = _unidadMedida.toString();

      final insumoData = {
        'ins_desc': _description,
        'ins_unidad_medida': _unidadMedida,
      };

      Provider.of<InsumosProvider>(context, listen: false)
          .addInsumo(insumoData)
          .then((isAdded) {
        if (isAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insumo agregado con éxito')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al agregar el insumo')),
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
              'Agregar Insumo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
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
                      decoration: const InputDecoration(labelText: 'Unidad de Medida'),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una unidad de medida';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _unidadMedida = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: const Text('Guardar Insumo'),
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
