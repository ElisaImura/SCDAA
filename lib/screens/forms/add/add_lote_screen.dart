// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/lotes_provider.dart';
import 'package:mspaa/widgets/footer.dart';
import 'package:mspaa/widgets/header.dart';

class AddLoteScreen extends StatefulWidget {
  const AddLoteScreen({super.key});

  @override
  _AddLoteScreenState createState() => _AddLoteScreenState();
}

class _AddLoteScreenState extends State<AddLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = ''; // Inicializamos el nombre vacío
  }

  // Función para guardar el formulario y agregar el lote
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Llamamos a LotesProvider para agregar el nuevo lote en el backend
      Provider.of<LotesProvider>(context, listen: false)
          .addLote(_name) // Pasamos el nombre del lote
          .then((isAdded) {
        if (isAdded) {
          // Si la adición fue exitosa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lote agregado con éxito')),
          );
          // Volver a la pantalla anterior después de guardar
          Navigator.of(context).pop(true);
        } else {
          // Si hubo un error al agregar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al agregar el lote')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0), // Altura personalizada del header
        child: Header(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Agregar Lote',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Formulario
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Campo para el nombre del lote
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Nombre del Lote'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre para el lote';
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
                      child: const Text('Agregar Lote'),
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
