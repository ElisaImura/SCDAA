// edit_cycle_screen.dart
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/cycle_provider.dart';
import 'package:mspaa/widgets/footer.dart';
import 'package:mspaa/widgets/header.dart';

class EditCycleScreen extends StatefulWidget {
  final Map<String, dynamic> ciclo;

  const EditCycleScreen({super.key, required this.ciclo});

  @override
  _EditCycleScreenState createState() => _EditCycleScreenState();
}

class _EditCycleScreenState extends State<EditCycleScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.ciclo['ci_nombre'] ?? '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Solo agrega los campos que no son null
      final Map<String, dynamic> cicloData = {
        'tpVar_id': widget.ciclo['tpVar_id'],
        'ci_id': widget.ciclo['ci_id'],
        'uss_id': widget.ciclo['uss_id'],
        'lot_id': widget.ciclo['lot_id'],
        'ci_fechaini': widget.ciclo['ci_fechaini'],
        'ci_nombre': _name,
        'ci_fechafin': widget.ciclo['ci_fechafin'],
        'cos_rendi': widget.ciclo['cos_rendi'],
        'cos_hume': widget.ciclo['cos_hume'],
        'sie_densidad': widget.ciclo['sie_densidad'],
      }..removeWhere((key, value) => value == null);

      Provider.of<CycleProvider>(context, listen: false)
          .editCiclo(widget.ciclo['ci_id'], cicloData)
          .then((isUpdated) {
        if (isUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ciclo actualizado con éxito')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el ciclo')),
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
              'Editar Ciclo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Nombre del Ciclo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del ciclo';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value!;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: const Text('Guardar Cambios'),
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
