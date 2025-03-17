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
  final TextEditingController _conCantController = TextEditingController();


  DateTime _selectedDate = DateTime.now();
  String? _selectedCiclo;
  String? _selectedTipoActividad;
  int? _ussId;
  int? _conVigor;
  String _activityState = 'Pendiente';

  final List<Map<String, dynamic>> _selectedInsumos = [];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      activityProvider.fetchCiclosActivos();
      activityProvider.fetchUsuarios();
    });
    
    _ussId = null;
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
                    _buildResponsableDropdown(activityProvider),
                    const SizedBox(height: 20),
                    // Solo mostramos la sección de densidad si el tipo de actividad es "Siembra"
                    if (_selectedTipoActividad == "3") _buildDensidadField(),
                    if (_selectedTipoActividad == "6") _buildCosechaFields(),
                    if (_selectedTipoActividad == "4")_buildConCantField(),
                    if (_selectedTipoActividad == "4")_buildConVigorField(),
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
          TextFormField(
            controller: _newInsumoController,
            decoration: InputDecoration(
              labelText: "Nuevo insumo",
              hintText: "Agregar nuevo insumo",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  if (_newInsumoController.text.isNotEmpty) {
                    setState(() {
                      _selectedInsumos.add({
                        'ins_desc': _newInsumoController.text,
                        'ins_id': -1, // Identificador único para nuevos insumos
                        'inst_cant': 0.0,
                        'controller': TextEditingController(text: ''),
                      });
                      _newInsumoController.clear();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("El nombre del insumo no puede estar vacío")),
                    );
                  }
                },
              ),
            ),
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
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
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
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

  Widget _buildConCantField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: _conCantController,
        decoration: const InputDecoration(
          labelText: "Cantidad de plantas por ha",
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese la cantidad de plantas por ha';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConVigorField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<int>(
        value: _conVigor,
        decoration: const InputDecoration(labelText: "Vigor de las plantas", border: OutlineInputBorder()),
        items: [
          DropdownMenuItem(value: 1, child: Text("Deficiente")),
          DropdownMenuItem(value: 2, child: Text("Malo")),
          DropdownMenuItem(value: 3, child: Text("Regular")),
          DropdownMenuItem(value: 4, child: Text("Bueno")),
          DropdownMenuItem(value: 5, child: Text("Excelente")),
        ],
        onChanged: (value) {
          setState(() {
            _conVigor = value!;
          });
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
            int? conCant = _selectedTipoActividad == "4" ? int.tryParse(_conCantController.text) : null;
            
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

            // Validación de con_cant y con_vigor antes de agregarlos a la actividad
            if (conCant != null) {
              activityData['con_cant'] = conCant;  // Cantidad de plantas por ha
            }

            if (_conVigor != null) {
              activityData['con_vigor'] = _conVigor;  // Vigor de las plantas (1 a 5)
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

  Widget _buildResponsableDropdown(ActivityProvider activityProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Responsable",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        activityProvider.isLoadingUsuarios
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<int>(
                value: _ussId,  // Ahora _ussId es int o null
                decoration: const InputDecoration(
                  labelText: "Selecciona un responsable",
                  border: OutlineInputBorder(),
                ),
                items: activityProvider.usuarios.map<DropdownMenuItem<int>>((usuario) {
                  return DropdownMenuItem<int>(
                    value: usuario["uss_id"] as int,
                    child: Text(usuario["uss_nombre"] ?? "Sin nombre"),
                  );
                }).toList(),
                onChanged: (value) {
                  Future.microtask(() {
                    setState(() {
                      _ussId = value;
                    });
                  });
                },
              ),
      ],
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

// Mapeo de los valores de con_vigor a los números respectivos (1 a 5)
int? mapVigorToValue(String vigor) {
  switch (vigor) {
    case 'Deficiente':
      return 1;
    case 'Malo':
      return 2;
    case 'Regular':
      return 3;
    case 'Bueno':
      return 4;
    case 'Excelente':
      return 5;
    default:
      return null; // Si no es un valor válido
  }
}