// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/cultivos_variedades_provider.dart';
import 'package:mspaa/screens/forms/add_variedad_screen.dart';
import 'package:mspaa/screens/forms/edit_variedad_screen.dart';

class VariedadesView extends StatefulWidget {
  final Map<String, dynamic> cultivo;

  const VariedadesView({super.key, required this.cultivo});

  @override
  _VariedadesViewState createState() => _VariedadesViewState();
}

class _VariedadesViewState extends State<VariedadesView> {
  List<Map<String, dynamic>> variedades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVariedades();
  }

  Future<void> _loadVariedades() async {
    final provider = Provider.of<CultivosVariedadesProvider>(context, listen: false);
    final cultivoId = widget.cultivo['tpCul_id'];

    try {
      final fetchedVariedades = await provider.fetchVariedadesPorCultivo(cultivoId);
      setState(() {
        variedades = fetchedVariedades;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error al cargar variedades: $e");
    }
  }

  Future<void> _confirmarEliminacion(BuildContext context, int variedadId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Variedad'),
        content: const Text('¿Estás seguro de eliminar esta variedad?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<CultivosVariedadesProvider>(context, listen: false);
      final eliminado = await provider.deleteVariedad(variedadId);

      if (eliminado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Variedad eliminada con éxito')),
        );
        await _loadVariedades();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la variedad')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UsersProvider>(context, listen: false);
    final nombreCultivo = widget.cultivo['tpCul_nombre'] ?? 'Cultivo';

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreCultivo),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Center(
                    child: Text(
                      'Variedades de $nombreCultivo',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                ),
                if (userProvider.hasPermissions([10, 11, 12]))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddVariedadScreen(cultivoId: widget.cultivo['tpCul_id']),
                            ),
                          );
                          if (result == true) {
                            await _loadVariedades();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar Variedad"),
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
                  child: variedades.isEmpty
                      ? const Center(child: Text('No hay variedades disponibles.'))
                      : ListView.builder(
                          itemCount: variedades.length,
                          itemBuilder: (context, index) {
                            final variedad = variedades[index];
                            final nombre = variedad['tpVar_nombre'] ?? 'Nombre no disponible';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 5,
                              color: Colors.white,
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                leading: CircleAvatar(
                                  backgroundColor: const Color.fromARGB(255, 0, 111, 32),
                                  child: Text(
                                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'V',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                trailing: (userProvider.hasPermissions([10, 11, 12])) ?
                                  Wrap(
                                    spacing: 12,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: 'Editar',
                                        onPressed: () async {
                                          final result = await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => EditVariedadScreen(variedad: variedad),
                                            ),
                                          );
                                          if (result == true) {
                                            await _loadVariedades();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Eliminar',
                                        onPressed: () {
                                          _confirmarEliminacion(context, variedad['tpVar_id']);
                                        },
                                      ),
                                    ],
                                  ):null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
