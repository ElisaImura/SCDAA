// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../../screens/forms/edit/edit_user_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/users_provider.dart';
import '../../../widgets/header.dart';
import '../../../widgets/footer.dart';
import '../../../screens/forms/add/add_user_screen.dart';  // Asegúrate de importar la pantalla para agregar un nuevo usuario

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  _UsersViewState createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  @override
  void initState() {
    super.initState();
    // Cargamos los usuarios al inicio de la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = context.watch<UsersProvider>().userData;
    final isAdmin = userInfo?["rol"]?["rol_id"] == 1; 
    
    return Scaffold(
      appBar: const Header(),
      body: Stack(
        children: [
          Consumer<UsersProvider>(
            builder: (context, usersProvider, child) {
              final users = usersProvider.users;

              if (users == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (users.isEmpty) {
                return const Center(child: Text('No hay usuarios disponibles.'));
              }

              return Column(
                // Agrega esto dentro del Column, justo después del título "Lista de Usuarios"
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Text(
                      'Lista de Usuarios',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddUserView(),
                              ),
                            );

                            if (result == true) {
                              await Provider.of<UsersProvider>(context, listen: false).fetchUsers();
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text("Agregar Usuario"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        // Comprobamos si el usuario es el administrador (id == 1)
                        bool isSupperAdmin = user['uss_id'] == 1;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          color: Colors.white,
                          // ignore: deprecated_member_use
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundColor: const Color.fromARGB(255, 0, 111, 32),
                              child: Text(
                                user['uss_nombre'] != null && user['uss_nombre']!.isNotEmpty
                                    ? user['uss_nombre'][0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user['uss_nombre'] ?? 'Nombre no disponible',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              user['email'] ?? 'Email no disponible',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            trailing: (isAdmin)
                              ? Wrap(
                                  spacing: 12,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        final result = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => EditUserView(user: user),
                                          ),
                                        );

                                        // Si se ha editado el usuario, recargar la lista
                                        if (result == true) {
                                          await Provider.of<UsersProvider>(context, listen: false).fetchUsers();
                                          setState(() {}); // Forzar la actualización de la interfaz de usuario
                                        }
                                      },
                                    ),
                                    // Botón de eliminación, deshabilitado si es el administrador
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: isSupperAdmin ? Colors.grey : Colors.red, // Si es admin, gris
                                      ),
                                      onPressed: isSupperAdmin
                                          ? null // Si es el administrador, no hacer nada al presionar
                                          : () async {
                                              // Lógica para eliminar el usuario
                                              final isDeleted = await Provider.of<UsersProvider>(context, listen: false).deleteUser(user['uss_id']);
                                              if (isDeleted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Usuario eliminado con éxito')),
                                                );
                                                // Recargar la lista de usuarios después de eliminar
                                                await Provider.of<UsersProvider>(context, listen: false).fetchUsers();
                                                setState(() {});
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Error al eliminar el usuario')),
                                                );
                                              }
                                            },
                                    ),
                                  ],
                                ): null,
                          ),
                        );
                      },
                    ),
                  ),
                  const Footer(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
