// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import '../../../providers/users_provider.dart';
import '../../../screens/forms/edit/edit_lote_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/lotes_provider.dart';
import '../../../screens/forms/add/add_lote_screen.dart';

class LotesView extends StatefulWidget {
  const LotesView({super.key});

  @override
  _LotesViewState createState() => _LotesViewState();
}

class _LotesViewState extends State<LotesView> {
  @override
  void initState() {
    super.initState();
    // Cargamos los lotes al inicio de la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LotesProvider>(context, listen: false).fetchLotes();
    });
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, int loteId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Lote'),
          content: const Text('¿Estás seguro de eliminar este lote?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final provider = Provider.of<LotesProvider>(context, listen: false);
                final isDeleted = await provider.deleteLote(loteId);
                Navigator.of(context).pop();
                if (isDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lote eliminado con éxito')),
                  );
                  await provider.fetchLotes();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar el lote')),
                  );
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UsersProvider>(context, listen: false);
    final isAdmin = userProvider.userData?["rol"]?["rol_id"] == 1;
    
    return Scaffold(
      body: Stack(
        children: [
          Consumer<LotesProvider>(
            builder: (context, lotesProvider, child) {
              final lotes = lotesProvider.lotes;

              if (lotes.isEmpty) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Text(
                        'Lista de Lotes',
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
                                  builder: (context) => const AddLoteScreen(),
                                ),
                              );

                              if (result == true) {
                                await Provider.of<LotesProvider>(context, listen: false).fetchLotes();
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text("Agregar Lote"),
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
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No hay lotes disponibles.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Text(
                      'Lista de Lotes',
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
                                builder: (context) => const AddLoteScreen(),
                              ),
                            );

                            if (result == true) {
                              await Provider.of<LotesProvider>(context, listen: false).fetchLotes();
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text("Agregar Lote"),
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
                      itemCount: lotes.length,
                      itemBuilder: (context, index) {
                        final lot = lotes[index];

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
                                lot['lot_nombre'] != null && lot['lot_nombre']!.isNotEmpty
                                    ? lot['lot_nombre'][0].toUpperCase()
                                    : 'L',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              lot['lot_nombre'] ?? 'Nombre no disponible',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              lot['lot_area'] != null ? 'Área: ${lot['lot_area']} ha' : 'Área no disponible',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            trailing: (isAdmin)
                              ?  Wrap(
                                  spacing: 12,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        final result = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => EditLoteScreen(lote: lot),
                                          ),
                                        );

                                        // Si se ha editado el lote, recargar la lista
                                        if (result == true) {
                                          await Provider.of<LotesProvider>(context, listen: false).fetchLotes();
                                          setState(() {}); // Forzar la actualización de la interfaz de usuario
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(context, lot['lot_id']);
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
              );
            },
          ),
        ],
      ),
    );
  }
}
