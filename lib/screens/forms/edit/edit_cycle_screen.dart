// edit_cycle_screen.dart
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cycle_provider.dart';

class EditCycleScreen extends StatefulWidget {
  final Map<String, dynamic> ciclo;

  const EditCycleScreen({super.key, required this.ciclo});

  @override
  _EditCycleScreenState createState() => _EditCycleScreenState();
}

class _EditCycleScreenState extends State<EditCycleScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _name = widget.ciclo['ci_nombre'] ?? '';
    _selectedDate = widget.ciclo['ci_fechaini'] != null
        ? DateTime.tryParse(widget.ciclo['ci_fechaini'].toString())
        : null;
    if (_selectedDate != null && _selectedDate!.isAfter(DateTime.now())) {
    }
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _selectedDate = date;
      if (_selectedDate != null && _selectedDate!.isAfter(DateTime.now())) {
      } else {
      }
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final Map<String, dynamic> cicloData = {
        'tpVar_id': widget.ciclo['tpVar_id'],
        'ci_id': widget.ciclo['ci_id'],
        'uss_id': widget.ciclo['uss_id'],
        'lot_id': widget.ciclo['lot_id'],
        'ci_fechaini': _selectedDate?.toIso8601String() ?? widget.ciclo['ci_fechaini'],
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
      appBar: AppBar(title: Text("Editar Ciclo")),
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
                    // Selector de fecha
                    ListTile(
                      title: Text(
                        "Fecha de Inicio: ${_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'Sin fecha'}"
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime initialDate = _selectedDate ?? DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          _onDateChanged(pickedDate);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
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
                      onPressed: (_selectedDate != null && _selectedDate!.isAfter(DateTime.now()))
                          ? null
                          : _saveForm,
                      child: (_selectedDate != null && _selectedDate!.isAfter(DateTime.now()))
                          ? const Text('No se puede guardar ciclo con fecha de inicio futura')
                          : const Text('Guardar Cambios'),
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
