// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/widgets/footer.dart';
import 'package:mspaa/widgets/header.dart';

class EditUserView extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserView({super.key, required this.user});

  @override
  _EditUserViewState createState() => _EditUserViewState();
}

class _EditUserViewState extends State<EditUserView> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _role;
  List<String> _roles = []; // No usamos late aquí, inicializamos como lista vacía.

  @override
  void initState() {
    super.initState();
    // Inicializamos los campos con los valores actuales del usuario
    _name = widget.user['uss_nombre'] ?? '';
    _email = widget.user['uss_email'] ?? '';
    _role = widget.user['rol']['rol_desc'] ?? '';

    // Cargar roles desde el backend
    Provider.of<UsersProvider>(context, listen: false).fetchRoles().then((_) {
      setState(() {
        _roles = Provider.of<UsersProvider>(context, listen: false).roles
            .map((role) => role['rol_desc'] as String)
            .toList();
      });
    });
  }

  // Función para guardar el formulario y actualizar el usuario
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Llamamos a UsersProvider para actualizar los datos del usuario en el backend
      Provider.of<UsersProvider>(context, listen: false)
          .updateUser(widget.user['uss_id'], _name, _email, _role)
          .then((isUpdated) {
        if (isUpdated) {
          // Si la actualización fue exitosa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario actualizado con éxito')),
          );
          // Volver a la pantalla anterior después de guardar
          Navigator.of(context).pop(true);
        } else {
          // Si hubo un error al actualizar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el usuario')),
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
              'Editar Usuario',
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
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campo para el email
                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Dropdown para el rol
                    _roles.isEmpty
                        ? const Center(child: CircularProgressIndicator()) // Mostrar cargando si no se han cargado los roles
                        : DropdownButtonFormField<String>(
                            value: _role,
                            decoration: const InputDecoration(labelText: 'Rol'),
                            onChanged: (value) {
                              setState(() {
                                _role = value!;
                              });
                            },
                            items: _roles.map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor seleccione un rol';
                              }
                              return null;
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
      bottomNavigationBar: const Footer(),
    );
  }
}
