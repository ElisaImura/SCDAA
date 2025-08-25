// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/activity_provider.dart';
import '../../../screens/views/act_detail_screen.dart';

class ActivitiesView extends StatefulWidget {
  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  // Filtros
  int? _estadoSeleccionado;
  String? _responsableSeleccionado;
  String? _cicloSeleccionado;
  String? _loteSeleccionado;
  DateTimeRange? _fechaSeleccionada;


  @override
  void initState() {
    super.initState();
    // Fetch all activities when the view is initialized
    Provider.of<ActivityProvider>(context, listen: false).fetchAllActividades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Text(
                'Lista de Actividades',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.filter_alt),
                  label: const Text("Filtros"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(
                            child: _buildFiltros(context, isDialog: true),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_hayFiltrosActivos())
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "Filtros activos",
                      style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildActivitiesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros(BuildContext context, {bool isDialog = false}) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final actividades = activityProvider.actividades;

        final estados = [1, 2, 3];
        final responsables = {
          for (var a in actividades)
            if (a['ciclo']['act_ciclos'].isNotEmpty)
              a['ciclo']['act_ciclos'][0]['uss_nombre']
        }.toList();
        final ciclos = {
          for (var a in actividades) a['ciclo']['datos_ciclo']['ci_nombre']
        }.toList();
        final lotes = {
          for (var a in actividades)
            if (a['ciclo']['lote'] != null)
              a['ciclo']['lote']['lot_nombre']
        }.toList();

        // --- CAMBIO: Usar StatefulBuilder para que el botón de limpiar filtros reaccione inmediatamente ---
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final bool hayFiltros = _hayFiltrosActivos();

            // Tamaño uniforme para todos los campos
            const double fieldWidth = 220;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Filtrar actividades",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<int?>(
                        value: _estadoSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          isDense: true,
                          prefixIcon: const Icon(Icons.check_circle_outline),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos')),
                          ...estados.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(_getActivityStateString(e)),
                              )),
                        ],
                        onChanged: (v) {
                          setState(() => _estadoSeleccionado = v);
                          setStateDialog(() {});
                        },
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<String?>(
                        value: _responsableSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Responsable',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          isDense: true,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos')),
                          ...responsables.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e ?? 'Desconocido'),
                              )),
                        ],
                        onChanged: (v) {
                          setState(() => _responsableSeleccionado = v);
                          setStateDialog(() {});
                        },
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<String?>(
                        value: _cicloSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Ciclo',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          isDense: true,
                          prefixIcon: const Icon(Icons.crop),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos')),
                          ...ciclos.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e ?? 'Desconocido'),
                              )),
                        ],
                        onChanged: (v) {
                          setState(() => _cicloSeleccionado = v);
                          setStateDialog(() {});
                        },
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<String?>(
                        value: _loteSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Lote',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          isDense: true,
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos')),
                          ...lotes.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e ?? 'Desconocido'),
                              )),
                        ],
                        onChanged: (v) {
                          setState(() => _loteSeleccionado = v);
                          setStateDialog(() {});
                        },
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(_fechaSeleccionada == null
                            ? 'Fechas'
                            : '${_fechaSeleccionada!.start.toString().substring(0, 10)} - ${_fechaSeleccionada!.end.toString().substring(0, 10)}'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.green[700]!),
                        ),
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _fechaSeleccionada = picked);
                            setStateDialog(() {});
                          }
                        },
                      ),
                    ),
                    if (hayFiltros && isDialog)
                      Tooltip(
                        message: "Limpiar todos los filtros",
                        child: TextButton.icon(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          label: const Text(
                            "Limpiar filtros",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () {
                            setState(() {
                              _estadoSeleccionado = null;
                              _responsableSeleccionado = null;
                              _cicloSeleccionado = null;
                              _loteSeleccionado = null;
                              _fechaSeleccionada = null;
                            });
                            setStateDialog(() {});
                          },
                        ),
                      ),
                  ],
                ),
                if (isDialog)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text("Cerrar"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green[700],
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  bool _hayFiltrosActivos() {
    return _estadoSeleccionado != null ||
        _responsableSeleccionado != null ||
        _cicloSeleccionado != null ||
        _loteSeleccionado != null ||
        _fechaSeleccionada != null;
  }

  Widget _buildActivitiesList() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        List<Map<String, dynamic>> activities = activityProvider.actividades;

        // --- FILTROS ---
        activities = activities.where((activity) {
          // Estado
          if (_estadoSeleccionado != null &&
              activity['act_estado'] != _estadoSeleccionado) {
            return false;
          }
          // Responsable
          if (_responsableSeleccionado != null) {
            final responsable = activity['ciclo']['act_ciclos'].isNotEmpty
                ? activity['ciclo']['act_ciclos'][0]['uss_nombre']
                : null;
            if (responsable != _responsableSeleccionado) return false;
          }
          // Ciclo
          if (_cicloSeleccionado != null &&
              activity['ciclo']['datos_ciclo']['ci_nombre'] != _cicloSeleccionado) {
            return false;
          }
          // Lote
          if (_loteSeleccionado != null) {
            final lote = activity['ciclo']['lote']?['lot_nombre'];
            if (lote != _loteSeleccionado) return false;
          }
          // Fechas
          if (_fechaSeleccionada != null) {
            final fecha = DateTime.tryParse(activity['act_fecha']);
            if (fecha == null ||
                fecha.isBefore(_fechaSeleccionada!.start) ||
                fecha.isAfter(_fechaSeleccionada!.end)) {
              return false;
            }
          }
          return true;
        }).toList();

        // Mostrar las actividades si están vacías
        if (activities.isEmpty) {
          return const Center(child: Text('No hay actividades disponibles.'));
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            // Información de la actividad
            var activity = activities[index];
            var ciclo = activity['ciclo']['datos_ciclo'];
            var lote = activity['ciclo']['lote'];
            var tipoActividad = activity['tipo_actividad']?['tpAct_nombre'] ?? 'Sin tipo';
            var descripcion = (activity['act_desc'] ?? '').toString().trim();
            if (descripcion.isEmpty) descripcion = 'Sin descripción';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título: Ciclo + Tipo de actividad (sin icono)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${ciclo['ci_nombre']} - $tipoActividad',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityDetailScreen(actividad: activity),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1.2),
                    // Descripción (siempre mostrar)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes, color: Colors.blueGrey, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              descripcion,
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Otros datos
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 6),
                        Text('Fecha: ${activity['act_fecha']}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.blueGrey, size: 18),
                        const SizedBox(width: 6),
                        Text('Estado: ${_getActivityStateString(activity['act_estado'])}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text('Responsable: ${activity['ciclo']['act_ciclos'].isNotEmpty ? activity['ciclo']['act_ciclos'][0]['uss_nombre'] : 'Desconocido'}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 18),
                        const SizedBox(width: 6),
                        Text('Lote: ${lote != null ? lote['lot_nombre'] : 'Desconocido'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Función para obtener el nombre del estado de la actividad
  String _getActivityStateString(int state) {
    switch (state) {
      case 1:
        return 'Pendientes';
      case 2:
        return 'En progreso';
      case 3:
        return 'Terminados';
      default:
        return 'Desconocido';
    }
  }
}
