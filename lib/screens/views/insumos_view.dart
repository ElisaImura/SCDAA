// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/insumos_provider.dart';
import 'package:mspaa/screens/forms/add_insumo_screen.dart';
import 'package:mspaa/screens/forms/edit_insumo_screen.dart';

class InsumosView extends StatefulWidget {
  const InsumosView({super.key});

  @override
  _InsumosViewState createState() => _InsumosViewState();
}

class _InsumosViewState extends State<InsumosView> {
  late InsumosProvider _insumosProvider;

  @override
  void initState() {
    super.initState();
    // Cargar insumos al iniciar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insumosProvider = Provider.of<InsumosProvider>(context, listen: false);
      _insumosProvider.fetchInsumos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<InsumosProvider>(builder: (context, insumosProvider, child) {
            final insumos = insumosProvider.insumos;

            if (insumos.isEmpty) {
              return const Center(child: Text('No hay insumos disponibles.'));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Text(
                    'Lista de Insumos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddInsumoScreen(),
                          ),
                        );

                        if (result == true) {
                          await Provider.of<InsumosProvider>(context, listen: false).fetchInsumos();
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.add_box),
                      label: const Text("Agregar Insumo"),
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
                    itemCount: insumos.length,
                    itemBuilder: (context, index) {
                      final insumo = insumos[index];

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
                              insumo['ins_desc'] != null && insumo['ins_desc']!.isNotEmpty
                                  ? insumo['ins_desc'][0].toUpperCase()
                                  : 'I',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            insumo['ins_desc'] ?? 'Descripción no disponible',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            insumo['ins_unidad_medida'] != null ? 'Unidad: ${insumo['ins_unidad_medida']}' : 'Unidad de Medida no disponible',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          trailing: Wrap(
                            spacing: 12,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditInsumoScreen(insumo: insumo),
                                    ),
                                  );

                                  if (result == true) {
                                    await Provider.of<InsumosProvider>(context, listen: false).fetchInsumos();
                                    setState(() {});
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(insumo['ins_id']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  //Metodo para mostrar el dialogo de confirmación de eliminación
  void _showDeleteConfirmationDialog(int insId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Estás seguro?"),
            content: const Text("Esta acción eliminará permanentemente el insumo.\nEsta acción podría generar errores."),
            actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el diálogo
                // Llamar a la función para eliminar la actividad
                _deleteInsumo(insId);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  // Método de eliminación de actividad
  void _deleteInsumo(int insId) async {
    final insumoProvider = Provider.of<InsumosProvider>(context, listen: false);
    
    bool success = await insumoProvider.deleteInsumo(insId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Insumo eliminado con éxito")));
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true); // Volver a la lista de insumos
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al eliminar insumo")));
    }
  }
}
