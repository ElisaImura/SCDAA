// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _insumoController = TextEditingController();
  final TextEditingController _newInsumoController = TextEditingController();
  final TextEditingController _densidadController = TextEditingController();
  final TextEditingController _cosRendiController = TextEditingController();
  final TextEditingController _cosHumeController = TextEditingController();


  DateTime _selectedDate = DateTime.now();
  String? _selectedCiclo;
  String? _selectedTipoActividad;
  int? _ussId;
  String _activityState = 'Pendiente';

  final List<Map<String, dynamic>> _selectedInsumos = [];

  @override
  void initState() {
    super.initState();
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    activityProvider.fetchCiclosActivos();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ussId = prefs.getInt("uss_id") ?? 1;
    });
  }

  void _changeActivityState(String newState) {
    setState(() {
      _activityState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Actividad"),
        actions: [
          GestureDetector(
            onTap: () async {
              final String? newState = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Cambiar Estado de la Actividad'),
                    content: DropdownButton<String>(
                      value: _activityState,
                      onChanged: (String? newValue) {
                        Navigator.pop(context, newValue);
                      },
                      items: <String>['Pendiente', 'En progreso', 'Finalizada']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                    ),
                  );
                },
              );

              if (newState != null) {
                _changeActivityState(newState);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text(_activityState),
                backgroundColor: _getStatusColor(_activityState),
              ),
            ),
          ),
        ],
      ),
      body: activityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    _buildCicloDropdown(activityProvider),
                    const SizedBox(height: 20),
                    _buildTipoActividadDropdown(activityProvider),
                    const SizedBox(height: 20),
                    // Solo mostramos la sección de densidad si el tipo de actividad es "Siembra"
                    if (_selectedTipoActividad == "3") _buildDensidadField(),
                    if (_selectedTipoActividad == "6") _buildCosechaFields(),
                    if (["1", "2", "3", "5"].contains(_selectedTipoActividad)) _buildInsumosSection(),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }
 
  Widget _buildDatePicker() {
    return ListTile(
      title: Text("Fecha: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
    );
  }

  Widget _buildCicloDropdown(ActivityProvider activityProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedCiclo,
      decoration: const InputDecoration(labelText: "Ciclo", border: OutlineInputBorder()),
      items: [
        ...activityProvider.ciclosActivos.map((ciclo) {  // Usamos ciclosActivos en lugar de ciclos
          String loteName = activityProvider.lotes.isNotEmpty
              ? activityProvider.lotes.firstWhere(
                  (lote) => lote['lot_id'] == ciclo['lot_id'],
                  orElse: () => {'lot_nombre': 'Desconocido'})['lot_nombre']
              : 'Desconocido';
          return DropdownMenuItem(
            value: ciclo["ci_id"].toString(),
            child: Text("${ciclo['ci_nombre']} ($loteName)"),
          );
        }),
        const DropdownMenuItem(value: "nuevo", child: Text("➕ Crear nuevo ciclo")),
      ],
      onChanged: (value) {
        setState(() {
          if (value == "nuevo") {
            context.push('/add-cycle');
          } else {
            _selectedCiclo = value;
          }
        });
      },
    );
  }

  Widget _buildTipoActividadDropdown(ActivityProvider activityProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedTipoActividad,
      decoration: const InputDecoration(labelText: "Tipo de Actividad", border: OutlineInputBorder()),
      items: activityProvider.tiposActividades.map((tipo) {
        return DropdownMenuItem(
          value: tipo["tpAct_id"].toString(),
          child: Text(tipo["tpAct_nombre"]),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTipoActividad = value;
        });
      },
    );
  }

  Widget _buildInsumosSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Insumos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TypeAheadField<Map<String, dynamic>>(
            controller: _insumoController,
            suggestionsCallback: (pattern) async {
              final prefs = await SharedPreferences.getInstance();
              final String? token = prefs.getString("auth_token");
              final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
              if (activityProvider.insumos.isEmpty) {
                if (token == null) {
                  if (kDebugMode) {
                    print("Error: Token is null, please log in again.");
                  }
                } else {
                  if (activityProvider.insumos.isEmpty) {
                    await activityProvider.fetchInsumos(token);
                  }
                }
              }
              return activityProvider.insumos.toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion["ins_desc"] ?? "Sin nombre"),
              );
            },
            onSelected: (suggestion) {
              setState(() {
                _selectedInsumos.add({
                  'ins_desc': suggestion['ins_desc'],
                  'ins_id': suggestion['ins_id'],
                  'inst_cant': 0.0,
                  'controller': TextEditingController(text: ''),
                });
                _insumoController.clear();
              });
            },
          ),
          const SizedBox(height: 15),
          // Campo para agregar un insumo nuevo manualmente
          TextFormField(
            controller: _newInsumoController,
            decoration: const InputDecoration(
              labelText: "Nuevo insumo",
              hintText: "Agregar nuevo insumo",
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  var datos = {
                    'ins_desc': value,
                    'ins_id': -1, // Asignamos un valor único para indicar que es nuevo
                    'inst_cant': 0.0,
                    'controller': TextEditingController(text: ''),
                  };
                  
                  // Add the map directly to the list
                  _selectedInsumos.add(datos);  // Adding the map to the list directly

                  _newInsumoController.clear();
                });
              }

            },
          ),
          const SizedBox(height: 15),
          if (_selectedInsumos.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: _selectedInsumos.map((insumo) {
                  TextEditingController cantidadController = insumo['controller'];
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(insumo["ins_desc"] ?? "Sin nombre")),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: cantidadController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: '0.0',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                insumo['inst_cant'] = value.isEmpty ? 0.0 : double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          _selectedInsumos.remove(insumo);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descripcionController,
      decoration: const InputDecoration(labelText: "Descripción", border: OutlineInputBorder()),
    );
  }

  Widget _buildCosechaFields() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _cosRendiController,
            decoration: const InputDecoration(
              labelText: "Rendimiento (kg/ha)",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa el rendimiento de la cosecha.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _cosHumeController,
            decoration: const InputDecoration(
              labelText: "Humedad del Grano (%)",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa la humedad del grano.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDensidadField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: _densidadController,
        decoration: const InputDecoration(
          labelText: "Densidad de Semilla (kg/ha)",
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingresa la densidad de semilla.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate() &&
              _selectedCiclo != null &&
              _selectedTipoActividad != null) {

            // 1. Guardar los insumos nuevos primero
            List<Map<String, dynamic>> insumosData = [];
            List<Map<String, dynamic>> insumosNuevos = [];

            double? cosRendi = _selectedTipoActividad == "6" ? double.tryParse(_cosRendiController.text) : null;
            double? cosHume = _selectedTipoActividad == "6" ? double.tryParse(_cosHumeController.text) : null;
            
            // Filtrar insumos nuevos (con ins_id == -1)
            for (var insumo in _selectedInsumos) {
              if (insumo['ins_id'] == -1) {
                // Es un insumo nuevo, lo agregamos a la lista de insumos nuevos
                insumosNuevos.add({
                  'ins_desc': insumo['ins_desc'],
                  'inst_cant': insumo['inst_cant'] ?? 0.0,
                });
              } else {
                // Es un insumo ya existente, lo agregamos a los insumosData
                insumosData.add({
                  'ins_id': insumo['ins_id'],
                  'ins_cant': insumo['inst_cant'] ?? 0.0,
                });
              }
            }

            // Si hay insumos nuevos, los guardamos primero
            if (insumosNuevos.isNotEmpty) {
              List<Map<String, dynamic>> insumosGuardados = await Provider.of<ActivityProvider>(context, listen: false)
                  .addInsumoNuevo(insumosNuevos);  // Llamamos a la función para guardar los insumos nuevos

              if (insumosGuardados.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error al guardar los insumos nuevos")));
                return;
              }

              // Agregamos los insumos nuevos con sus ids a la lista de insumos que se enviará a la actividad
              for (var insumoNuevo in insumosNuevos) {
                // Comparamos el insumoNuevo con los insumos guardados para obtener el ins_id
                for (var insumoGuardado in insumosGuardados) {
                  if (insumoNuevo['ins_desc'] == insumoGuardado['ins_desc']) {
                    insumosData.add({
                      'ins_id': insumoGuardado['ins_id'],  // Asignamos el ins_id recuperado
                      'ins_cant': insumoNuevo['inst_cant'],  // Asignamos la cantidad del insumo nuevo
                    });
                  }
                }
              }
            }

            //Mapeamos el estado a su valor numérico
            int activityState = _getActivityStateValue(_activityState);

            // 2. Crear el objeto de actividad
            Map<String, dynamic> activityData = {
              "tpAct_id": int.parse(_selectedTipoActividad!),
              "ci_id": int.parse(_selectedCiclo!),
              "act_fecha": DateFormat("yyyy-MM-dd").format(_selectedDate),
              "act_desc": _descripcionController.text,
              "act_estado": activityState,
              "uss_id": _ussId
            };

            //Agrega datos de siembra
            if (_densidadController.text.isNotEmpty) {
              activityData['sie_densidad'] = _densidadController.text;
            }

            //Agrega datos de cosecha
            if (cosRendi != null && cosHume != null) {
              activityData['cos_rendi'] = cosRendi;
              activityData['cos_hume'] = cosHume;
            }

            // Agregar los insumos a la actividad
            if (insumosData.isNotEmpty) {
              activityData['insumos'] = insumosData;
            }

            if (kDebugMode) {
              print("Datos que se enviarán a la API: $activityData");
            }

            // 3. Guardar la actividad
            bool success = await Provider.of<ActivityProvider>(context, listen: false).addActivity(activityData);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Actividad guardada con éxito")));
              context.go('/home');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al guardar actividad")));
            }
          }
        },
        child: const Text("Guardar Actividad"),
      ),
    );
  }

  
}


Color _getStatusColor(String status) {
  switch (status) {
    case 'Pendiente':
      return Colors.orange;
    case 'En progreso':
      return Colors.blue;
    case 'Finalizada':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
// Función para mapear el estado a su valor numérico
int _getActivityStateValue(String state) {
  switch (state) {
    case 'Pendiente':
      return 1;
    case 'En progreso':
      return 2;
    case 'Finalizada':
      return 3;
    default:
      return 1; // Valor predeterminado (Pendiente)
  }
}