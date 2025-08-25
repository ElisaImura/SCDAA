// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/users_provider.dart';

class AddUserView extends StatefulWidget {
  const AddUserView({super.key});

  @override
  _AddUserViewState createState() => _AddUserViewState();
}

class _AddUserViewState extends State<AddUserView> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _password; // Add a new field for the password
  late int _role; // Change _role to int
  List<Map<String, dynamic>> _roles = []; // Change _roles to hold maps with role data.

  @override
  void initState() {
    super.initState();
    // Cargar roles desde el backend
    Provider.of<UsersProvider>(context, listen: false).fetchRoles().then((_) {
      setState(() {
        _roles = Provider.of<UsersProvider>(context, listen: false).roles;
        if (_roles.isNotEmpty) {
          _role = _roles.first['rol_id']; // Initialize _role with the first role's id
        }
      });
    }).catchError((error) {
      // Manejo de errores al cargar roles
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los roles')),
      );
    });
  }

  // Función para guardar el formulario y agregar el usuario
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Llamamos a UsersProvider para agregar el nuevo usuario en el backend
      Provider.of<UsersProvider>(context, listen: false)
          .addUser(_name, _email, _role, _password) // Pass the role_id
          .then((isAdded) {
        if (isAdded) {
          // Si la adición fue exitosa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario agregado con éxito')),
          );
          // Volver a la pantalla anterior después de guardar
          Navigator.of(context).pop(true);
        } else {
          // Si hubo un error al agregar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al agregar el usuario')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nuevo Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Agregar Usuario',
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
                    // Campo para la contraseña
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una contraseña';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                      obscureText: true, // Hide the password
                    ),
                    const SizedBox(height: 16),
                    // Dropdown para el rol
                    _roles.isEmpty
                        ? const Center(child: CircularProgressIndicator()) // Mostrar cargando si no se han cargado los roles
                        : DropdownButtonFormField<int>(
                            decoration: const InputDecoration(labelText: 'Rol'),
                            onChanged: (value) {
                              setState(() {
                                _role = value!;
                              });
                            },
                            items: _roles.map((role) {
                              return DropdownMenuItem<int>(
                                value: role['rol_id'],
                                child: Text(role['rol_desc']),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor seleccione un rol';
                              }
                              return null;
                            },
                          ),
                    const SizedBox(height: 32),
                    // Botón para guardar
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: const Text('Agregar Usuario'),
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
