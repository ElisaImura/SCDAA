// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mspaa/screens/forms/edit_lote_screen.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/lotes_provider.dart';
import 'package:mspaa/screens/forms/add_lote_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<LotesProvider>(
            builder: (context, lotesProvider, child) {
              final lotes = lotesProvider.lotes;

              if (lotes.isEmpty) {
                return const Center(child: Text('No hay lotes disponibles.'));
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
                            trailing: Wrap(
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
                                  onPressed: () async {
                                    // Lógica para eliminar el lote
                                    final isDeleted = await Provider.of<LotesProvider>(context, listen: false).deleteLote(lot['lot_id']);
                                    if (isDeleted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Lote eliminado con éxito')),
                                      );
                                      // Recargar la lista de lotes después de eliminar
                                      await Provider.of<LotesProvider>(context, listen: false).fetchLotes();
                                      setState(() {});
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Error al eliminar el lote')),
                                      );
                                    }
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
            },
          ),
        ],
      ),
    );
  }
}
