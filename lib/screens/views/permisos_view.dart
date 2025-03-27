import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/users_provider.dart';

class PermisosView extends StatefulWidget {
  const PermisosView({super.key});

  @override
  State<PermisosView> createState() => _PermisosViewState();
}

class _PermisosViewState extends State<PermisosView> {
  Map<int, Set<int>> permisosPorUsuario = {};

  final Map<String, List<int>> categorias = {
    "Gestión de Ciclos": [1, 2, 3],
    "Gestión de Insumos": [4, 5, 6],
    "Gestión de Tipos de Cultivos": [7, 8, 9],
    "Gestión de Variedades de Cultivos": [10, 11, 12],
  };

  final Map<String, String> descripciones = {
    "Gestión de Ciclos": "Crear, editar y eliminar ciclos",
    "Gestión de Insumos": "Crear, editar y eliminar insumos",
    "Gestión de Tipos de Cultivos": "Crear, editar y eliminar tipos de cultivos",
    "Gestión de Variedades de Cultivos": "Crear, editar y eliminar variedades de cultivos",
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<UsersProvider>(context, listen: false);
      await provider.fetchUsers();
      await provider.fetchAllPermisos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<UsersProvider>(context);
    final allUsers = usersProvider.users;
    final users = (allUsers ?? []).where((u) => u['rol']?['rol_id'] != 1).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Permisos')),
      body: allUsers == null
          ? const Center(child: CircularProgressIndicator()) // Cargando datos
          : users.isEmpty
              ? const Center(child: Text('No hay usuarios disponibles para asignar permisos.'))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userId = user['uss_id'] as int;

                    permisosPorUsuario[userId] ??= (user['permisos'] as List<dynamic>)
                        .map((p) => p['perm_id'] as int)
                        .toSet();

                    final userPermisos = permisosPorUsuario[userId]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: Text(user['uss_nombre'] ?? 'Nombre no disponible'),
                        subtitle: Text(user['email'] ?? ''),
                        children: [
                          Column(
                            children: categorias.entries.map((categoria) {
                              final nombre = categoria.key;
                              final permisosGrupo = categoria.value;
                              final descripcion = descripciones[nombre] ?? '';

                              final tieneTodos = permisosGrupo.every((p) => userPermisos.contains(p));

                              return CheckboxListTile(
                                title: Text(nombre),
                                subtitle: Text(descripcion),
                                value: tieneTodos,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      userPermisos.addAll(permisosGrupo);
                                    } else {
                                      userPermisos.removeAll(permisosGrupo);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final permisosActuales = (user['permisos'] as List<dynamic>)
                                    .map((p) => p['perm_id'] as int)
                                    .toSet();
                                final nuevosPermisos = permisosPorUsuario[userId]!;

                                final aAgregar = nuevosPermisos.difference(permisosActuales).toList();
                                final aQuitar = permisosActuales.difference(nuevosPermisos).toList();

                                bool exitoAgregar = true;
                                bool exitoQuitar = true;

                                if (aAgregar.isNotEmpty) {
                                  exitoAgregar = await usersProvider.asignarPermisos(userId, aAgregar);
                                }

                                if (aQuitar.isNotEmpty) {
                                  exitoQuitar = await usersProvider.quitarPermisos(userId, aQuitar);
                                }

                                final snackBar = SnackBar(
                                  content: Text(
                                    (exitoAgregar && exitoQuitar)
                                        ? 'Permisos actualizados con éxito'
                                        : 'Hubo un error al actualizar algunos permisos',
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                await usersProvider.fetchUsers();
                                setState(() {});
                              },
                              icon: const Icon(Icons.save),
                              label: const Text("Guardar Cambios"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
