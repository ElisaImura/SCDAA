// ciclos_view.dart
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/cycle_provider.dart';
import 'package:mspaa/screens/forms/add_cycle_screen.dart';
import 'package:mspaa/screens/forms/edit_cycle_screen.dart';

class CiclosView extends StatefulWidget {
  const CiclosView({super.key});

  @override
  _CiclosViewState createState() => _CiclosViewState();
}

class _CiclosViewState extends State<CiclosView> {

  bool _mostrarTodosActivos = false;
  bool _mostrarTodosInactivos = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CycleProvider>(context, listen: false);
      provider.fetchCiclosActivos();
      provider.fetchCiclosInactivos(); // nuevo
    });
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, cicloId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Ciclo'),
          content: const Text('¿Estás seguro de eliminar este ciclo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final provider = Provider.of<CycleProvider>(context, listen: false);
                final isDeleted = provider.deleteCiclo(cicloId);
                Navigator.of(context).pop();
                if (await isDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ciclo eliminado con éxito')),
                  );
                  await provider.fetchCiclosActivos();
                  await provider.fetchCiclosInactivos();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar el ciclo')),
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
    final tienePermisoCiclos = userProvider.hasPermissions([1, 2, 3]);

    return Scaffold(
      body: Consumer<CycleProvider>(builder: (context, cycleProvider, child) {
        final ciclosActivos = cycleProvider.ciclosActivos;
        final ciclosInactivos = cycleProvider.ciclosInactivos;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Center(
                  child: Text(
                    'Lista de Ciclos',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ),
              ),
              if (isAdmin || tienePermisoCiclos)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddCycleScreen(),
                          ),
                        );

                        if (result == true) {
                          await Provider.of<CycleProvider>(context, listen: false).fetchCiclosActivos();
                          await Provider.of<CycleProvider>(context, listen: false).fetchCiclosInactivos();
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("Agregar Ciclo"),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de ciclos activos
                      _buildSectionTitle('Ciclos Activos', context),
                      if (ciclosActivos.isEmpty)
                        _buildEmptyState('No hay ciclos activos disponibles.')
                      else
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _mostrarTodosActivos
                              ? ciclosActivos.length
                              : (ciclosActivos.length > 3 ? 3 : ciclosActivos.length),
                          itemBuilder: (context, index) {
                            final ciclo = ciclosActivos[index];
                            return _buildCicloCard(context, ciclo, isAdmin, tienePermisoCiclos);
                          },
                        ),
                      
                      if (ciclosActivos.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _mostrarTodosActivos = !_mostrarTodosActivos;
                              });
                            },
                            child: Center(child: Text(_mostrarTodosActivos ? 'Ver menos' : 'Ver más'),)
                          ),
                        ),

                      const SizedBox(height: 15),

                      // Sección de ciclos inactivos
                      _buildSectionTitle('Ciclos Inactivos', context),
                      if (ciclosInactivos.isEmpty)
                        _buildEmptyState('No hay ciclos inactivos disponibles.')
                      else
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _mostrarTodosInactivos
                              ? ciclosInactivos.length
                              : (ciclosInactivos.length > 3 ? 3 : ciclosInactivos.length),
                          itemBuilder: (context, index) {
                            final ciclo = ciclosInactivos[index];
                            return _buildCicloCard(context, ciclo, isAdmin, tienePermisoCiclos);
                          },
                        ),

                      if (ciclosInactivos.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _mostrarTodosInactivos = !_mostrarTodosInactivos;
                              });
                            },
                            child: Center(child: Text(_mostrarTodosInactivos ? 'Ver menos' : 'Ver más'),)
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCicloCard(BuildContext context, Map<String, dynamic> ciclo, bool isAdmin, bool tienePermisoCiclos) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          ciclo['ci_nombre'] ?? 'Nombre no disponible',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            ciclo['ci_descripcion'] ?? 'Descripción no disponible',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        trailing: (isAdmin || tienePermisoCiclos)
          ? Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Editar',
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EditCycleScreen(ciclo: ciclo)),
                    );
                    if (result == true) {
                      await Provider.of<CycleProvider>(context, listen: false).fetchCiclosActivos();
                      await Provider.of<CycleProvider>(context, listen: false).fetchCiclosInactivos();
                      setState(() {});
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Eliminar',
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, ciclo['ci_id']);
                  },
                ),
              ],
            )
          : null,
      ),
    );
  }

}
