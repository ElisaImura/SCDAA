// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/screens/forms/add/add_cultivo_screen.dart';
import 'package:mspaa/screens/forms/edit/edit_cultivo_screen.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/cultivos_variedades_provider.dart';
import 'package:mspaa/screens/views/variedades_view.dart';

class CultivosView extends StatefulWidget {
  const CultivosView({super.key});

  @override
  _CultivosViewState createState() => _CultivosViewState();
}

class _CultivosViewState extends State<CultivosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CultivosVariedadesProvider>(context, listen: false).fetchCultivos();
    });
  }

  Future<void> _confirmarEliminacion(BuildContext context, int cultivoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Tipo de Cultivo'),
        content: const Text('¿Estás seguro de eliminar este tipo de cultivo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<CultivosVariedadesProvider>(context, listen: false);
      final eliminado = await provider.deleteCultivo(cultivoId);

      if (eliminado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de cultivo eliminado con éxito')),
        );
        await provider.fetchCultivos();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el cultivo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UsersProvider>(context, listen: false);
    final isAdmin = userProvider.userData?["rol"]?["rol_id"] == 1;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Center(
              child: Text(
                'Tipos de Cultivos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ),
          ),

          // Botón para agregar nuevo tipo de cultivo
          if (userProvider.hasPermissions([7, 8, 9]) || isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddCultivoScreen()),
                    );
                    if (result == true) {
                      await Provider.of<CultivosVariedadesProvider>(context, listen: false).fetchCultivos();
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar Tipo de Cultivo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

          // Lista de cultivos desde el Provider
          Expanded(
            child: Consumer<CultivosVariedadesProvider>(
              builder: (context, provider, child) {
                final cultivos = provider.cultivos;

                if (cultivos.isEmpty) {
                  return const Center(child: Text('No hay cultivos disponibles.'));
                }

                return ListView.builder(
                  itemCount: cultivos.length,
                  itemBuilder: (context, index) {
                    final cultivo = cultivos[index];
                    final nombre = cultivo['tpCul_nombre'] ?? 'Nombre no disponible';
                    final cultivoId = cultivo['tpCul_id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: (userProvider.hasPermissions([7, 8, 9]) || isAdmin) ? ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        title: Text(
                          nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 0, 111, 32),
                          child: Text(
                            nombre.isNotEmpty ? nombre[0].toUpperCase() : 'C',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => EditCultivoScreen(cultivo: cultivo),
                                          ),
                                        );
                                        if (result == true) {
                                          await Provider.of<CultivosVariedadesProvider>(context, listen: false)
                                              .fetchCultivos();
                                          setState(() {});
                                        }
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text("Editar"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _confirmarEliminacion(context, cultivoId),
                                      icon: const Icon(Icons.delete),
                                      label: const Text("Eliminar"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VariedadesView(cultivo: cultivo),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    label: const Text("Ver variedades"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ): ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text(
                            nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color.fromARGB(255, 0, 111, 32),
                            child: Text(
                              nombre.isNotEmpty ? nombre[0].toUpperCase() : 'C',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VariedadesView(cultivo: cultivo),
                              ),
                            );
                          },
                        )
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
