// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../../providers/lotes_provider.dart';
import 'package:provider/provider.dart';

class EditLoteScreen extends StatefulWidget {
  final Map<String, dynamic> lote;

  const EditLoteScreen({super.key, required this.lote});

  @override
  _EditLoteScreenState createState() => _EditLoteScreenState();
}

class _EditLoteScreenState extends State<EditLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;

  @override
  void initState() {
    super.initState();
    // Inicializamos el nombre con el valor actual del lote
    _name = widget.lote['lot_nombre'] ?? '';
  }

  // Función para guardar el formulario y actualizar el lote
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Llamamos al LotesProvider para actualizar los datos del lote en el backend
      Provider.of<LotesProvider>(context, listen: false)
          .editLote(widget.lote['lot_id'], {'lot_nombre': _name})
          .then((isUpdated) {
        if (isUpdated) {
          // Si la actualización fue exitosa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lote actualizado con éxito')),
          );
          // Volver a la pantalla anterior después de guardar
          Navigator.of(context).pop(true);
        } else {
          // Si hubo un error al actualizar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el lote')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Lote")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar Lote',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Formulario
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Campo para el nombre
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Nombre del Lote'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del lote';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value!;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Botón para guardar
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
    );
  }
}
