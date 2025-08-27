// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/cycle_provider.dart';
import '../../../providers/users_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/weather_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _newInsumoController = TextEditingController();
  final TextEditingController _densidadController = TextEditingController();
  final TextEditingController _cosRendiController = TextEditingController();
  final TextEditingController _cosHumeController = TextEditingController();
  final TextEditingController _conCantController = TextEditingController();
  final TextEditingController _unidadController = TextEditingController();


  DateTime _selectedDate = DateTime.now().toLocal();
  String? _selectedCiclo;
  String? _selectedTipoActividad;
  int? _ussId;
  int? _conVigor;
  String _activityState = 'Pendiente';

  final List<Map<String, dynamic>> _selectedInsumos = [];

  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
        final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
        cycleProvider.fetchCiclosActivos();
        activityProvider.fetchUsuarios();
        // Cargar insumos automáticamente
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString("auth_token");
        if (token != null) {
          await activityProvider.fetchInsumos(token);
          if (mounted) setState(() {});
        }
      });
      _ussId = null;
  }

  // Helper para refrescar la disponibilidad de clima según lote y fecha
  Future<void> _refreshWeatherAvailability() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

    int? selectedLoteId;
    if (_selectedCiclo != null) {
      final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
      final ciclo = cycleProvider.ciclosActivos.firstWhere(
        (c) => c['ci_id'].toString() == _selectedCiclo,
        orElse: () => <String, dynamic>{},
      );
      selectedLoteId = ciclo['lot_id'];
    }

    if (selectedLoteId != null) {
      final fecha = DateFormat('yyyy-MM-dd').format(_selectedDate);
      await weatherProvider.checkWeatherForDate(fecha, selectedLoteId);
      if (mounted) setState(() {});
    }
  }

  void _changeActivityState(String newState) {
    setState(() {
      _activityState = newState;
    });
  }

  bool _isFutureDate() {
  return _selectedDate.isAfter(DateTime.now().toLocal());
  }

  Widget _buildDatePicker() {
    return ListTile(
      title: Text("Fecha: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020).toLocal(),
          lastDate: DateTime(2030).toLocal(),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            if (_isFutureDate()) {
              _changeActivityState('Pendiente');
            }
          });
          // ✅ Consultar clima para (lote, nueva fecha)
          await _refreshWeatherAvailability();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final cycleProvider = Provider.of<CycleProvider>(context);
    final userInfo = context.watch<UsersProvider>().userData;
    final userId = userInfo?["uss_id"];
    final isAdmin = userInfo?["rol"]?["rol_id"] == 1;

    final userProvider = Provider.of<UsersProvider>(context, listen: false);

    bool tienePermisoCiclos = userProvider.hasPermissions([1, 2, 3]);
    bool tienePermisoInsumos = userProvider.hasPermissions([4, 5, 6]);

    if (!isAdmin && _ussId == null) {
      _ussId = userId;
    }

    // Obtener el lote del ciclo seleccionado
    int? selectedLoteId;
    if (_selectedCiclo != null) {
      final ciclo = cycleProvider.ciclosActivos.firstWhere(
        (c) => c['ci_id'].toString() == _selectedCiclo,
        orElse: () => <String, dynamic>{},
      );
      selectedLoteId = ciclo['lot_id'];
    }

    // Verificar si hay clima para la fecha y lote seleccionados
    bool showAddWeatherButton = false;
    if (selectedLoteId != null) {
      showAddWeatherButton = !weatherProvider.isWeatherAvailable;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Actividad"),
        actions: [
          GestureDetector(
            onTap: () async {
              if (_isFutureDate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No se puede cambiar el estado si la fecha es futura")),
                );
                return;
              }
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
                    _buildCicloDropdown(activityProvider, cycleProvider, isAdmin, tienePermisoCiclos),
                    const SizedBox(height: 20),
                    _buildTipoActividadDropdown(activityProvider),
                    const SizedBox(height: 20),
                    if (isAdmin) ...[
                      _buildResponsableDropdown(activityProvider),
                      const SizedBox(height: 20),
                    ],
                    // Solo mostramos la sección de densidad si el tipo de actividad es "Siembra"
                    if (_selectedTipoActividad == "3") _buildDensidadField(),
                    if (_selectedTipoActividad == "6") _buildCosechaFields(),
                    if (_selectedTipoActividad == "4")_buildConCantField(),
                    if (_selectedTipoActividad == "4")_buildConVigorField(),
                    // 🔴 Mostrar insumos SIEMPRE para los tipos válidos
                    if (["1", "2", "3", "5"].contains(_selectedTipoActividad))
                      _buildInsumosSection(isAdmin, tienePermisoInsumos, disabled: _activityState == 'Pendiente'),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    // Mostrar el boton de agregar clima solo si no hay clima cargado anteriormente para la fecha
                    if (showAddWeatherButton && !weatherProvider.isLoading)
                      _buildAddWeatherButton(),
                    const SizedBox(height: 10),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }
 
  Widget _buildCicloDropdown(ActivityProvider activityProvider, CycleProvider cycleProvider, bool isAdmin, bool tienePermisoCiclos,) {
    return DropdownButtonFormField<String>(
      value: _selectedCiclo,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
      decoration: const InputDecoration(labelText: "Ciclo", border: OutlineInputBorder()),
      items: [
        ...cycleProvider.ciclosActivos.map((ciclo) {
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
        if (isAdmin || tienePermisoCiclos)
          const DropdownMenuItem(value: "nuevo", child: Text("➕ Crear nuevo ciclo")),
      ],
      onChanged: (value) async {
        if (value == "nuevo") {
          context.push('/add-cycle');
          await cycleProvider.fetchCiclosActivos();
        } else {
          setState(() {
            _selectedCiclo = value;
          });
          // ✅ Al cambiar ciclo (lote), refrescar clima para la fecha actual
          await _refreshWeatherAvailability();

          // Verificar si el tipo de actividad es "Siembra"
          if (_selectedTipoActividad == "3") {
            final cicloSeleccionado = _selectedCiclo;
            if (cicloSeleccionado != null) {
              // Espera a que las actividades se carguen
              await activityProvider.fetchAllActividades();

              // Verificar si ya existe una actividad de Siembra para el ciclo seleccionado
              final actividadExistente = activityProvider.actividades.firstWhere(
                (actividad) =>
                    actividad['tpAct_id'] == 3 && // Si es tipo "Siembra"
                    actividad['ciclo']['ci_id'] == int.parse(cicloSeleccionado), // Si el ciclo coincide
                orElse: () => {}, // Retorna un mapa vacío si no hay coincidencia
              );

              if (actividadExistente.isNotEmpty) {
                // Si ya existe una actividad de "Siembra" para este ciclo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ya existe una actividad de Siembra para este ciclo")),
                );
                // Evitar que el usuario seleccione "Siembra" en este ciclo
                setState(() {
                  _selectedTipoActividad = null;  // Volver al valor por defecto o cualquier otra lógica
                });
              }
            }
          }
        }
      },
    );
  }

  Widget _buildTipoActividadDropdown(ActivityProvider activityProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedTipoActividad,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
      decoration: const InputDecoration(labelText: "Tipo de Actividad", border: OutlineInputBorder()),
      items: activityProvider.tiposActividades.map((tipo) {
        return DropdownMenuItem(
          value: tipo["tpAct_id"].toString(),
          child: Text(tipo["tpAct_nombre"]),
        );
      }).toList(),
      onChanged: (value) async {
        setState(() {
          _selectedTipoActividad = value;
        });

        // Verificar si el tipo de actividad es "Siembra"
        if (_selectedTipoActividad == "3") {
          final cicloSeleccionado = _selectedCiclo;
          if (cicloSeleccionado != null) {
            // Espera a que las actividades se carguen
            await activityProvider.fetchAllActividades();

            // Verificar si ya existe una actividad de Siembra para el ciclo seleccionado
            final actividadExistente = activityProvider.actividades.firstWhere(
              (actividad) =>
                  actividad['tpAct_id'] == 3 && // Si es tipo "Siembra"
                  actividad['ciclo']['ci_id'] == int.parse(cicloSeleccionado), // Si el ciclo coincide
              orElse: () => {}, // Retorna un mapa vacío si no hay coincidencia
            );

            if (actividadExistente.isNotEmpty) {
              // Si ya existe una actividad de "Siembra" para este ciclo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ya existe una actividad de Siembra para este ciclo")),
              );
              // Evitar que el usuario seleccione "Siembra" en este ciclo
              setState(() {
                _selectedTipoActividad = null;  // Volver al valor por defecto o cualquier otra lógica
              });
            }
          }
        }
      },
    );
  }

  Widget _buildInsumosSection(bool isAdmin, bool tienePermisoInsumos, {bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Insumos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          // Sección para buscar insumos existentes
          AbsorbPointer(
            absorbing: disabled,
            child: TypeAheadField<Map<String, dynamic>>(
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: "Buscar Insumo",
                    hintText: "Buscar por nombre",
                    border: OutlineInputBorder(),
                  ),
                  enabled: !disabled,
                );
              },
              suggestionsCallback: (pattern) async {
                final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
                final prefs = await SharedPreferences.getInstance();
                final String? token = prefs.getString("auth_token");

                if (activityProvider.insumos.isEmpty && token != null) {
                  await activityProvider.fetchInsumos(token);
                }

                // Si no hay insumos, mostrar mensaje indicando que no hay insumos disponibles
                if (activityProvider.insumos.isEmpty) {
                  return []; // Vacío para mostrar el mensaje de "no hay insumos"
                }

                return activityProvider.insumos.where((insumo) {
                  return (insumo['ins_desc'] as String).toLowerCase().contains(pattern.toLowerCase());
                }).toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion['ins_desc'] ?? "Sin nombre"),
                );
              },
              onSelected: (suggestion) {
                setState(() {
                  // Check if the insumo already exists in the selected list
                  bool alreadyExists = _selectedInsumos.any((insumo) => insumo['ins_desc'] == suggestion['ins_desc']);
                  
                  if (alreadyExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Este insumo ya fue agregado."))
                    );
                  } else {
                    _selectedInsumos.add({
                      'ins_desc': suggestion['ins_desc'] ?? '',
                      'ins_id': suggestion['ins_id'] ?? 0,
                      'ins_cant': 0.0,
                      'ins_unidad_medida': suggestion['ins_unidad_medida'] ?? '',
                      'controller': TextEditingController(text: ''),
                    });
                    _newInsumoController.clear();
                  }
                });
              },
            ),
          ),

          // Mensaje si no hay insumos preexistentes
          if (!disabled && Provider.of<ActivityProvider>(context).insumos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "No hay insumos preexistentes disponibles. Agrega un nuevo insumo.",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),

          const SizedBox(height: 10),

          // Sección para agregar un nuevo insumo
          if ((isAdmin || tienePermisoInsumos))
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _newInsumoController,
                    decoration: const InputDecoration(
                      labelText: "Nuevo Insumo",
                      hintText: "Nombre del insumo",
                      border: OutlineInputBorder(),
                    ),
                    enabled: !disabled,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _unidadController,
                    decoration: const InputDecoration(
                      labelText: "Unidad de medida",
                      hintText: "Unidad",
                      border: OutlineInputBorder(),
                    ),
                    enabled: !disabled,
                  ),
                ),
              ],
            ),
          if ((isAdmin || tienePermisoInsumos)) const SizedBox(height: 10),
          // Botón para agregar insumo nuevo
          if ((isAdmin || tienePermisoInsumos))
            ElevatedButton.icon(
              onPressed: disabled
                  ? null
                  : () {
                      if (_newInsumoController.text.isNotEmpty && _unidadController.text.isNotEmpty) {
                        // Check if the new insumo already exists
                        bool alreadyExists = _selectedInsumos.any((insumo) => insumo['ins_desc'] == _newInsumoController.text);

                        if (alreadyExists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Este insumo ya fue agregado."))
                          );
                        } else {
                          setState(() {
                            _selectedInsumos.add({
                              'ins_desc': _newInsumoController.text,
                              'ins_id': -1, // Identificador único para nuevos insumos
                              'ins_cant': 0.0,
                              'ins_unidad_medida': _unidadController.text,
                              'controller': TextEditingController(text: ''),
                            });
                            _newInsumoController.clear();
                            _unidadController.clear();
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("El nombre del insumo y la unidad de medida no pueden estar vacíos")),
                        );
                      }
                    },
              icon: const Icon(Icons.add),
              label: const Text("Agregar Insumo"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          // Mostrar la lista de insumos agregados
          if (_selectedInsumos.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(top: 15),
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
                                insumo['ins_cant'] = value.isEmpty ? 0.0 : double.tryParse(value) ?? 0.0;
                              });
                            },
                            enabled: !disabled,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(insumo['ins_unidad_medida'] ?? ''),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: disabled ? null : () {
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
            validator: _activityState == 'Pendiente' ? null : (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa el rendimiento de la cosecha.';
              }
              return null;
            },
            enabled: _activityState != 'Pendiente',
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _cosHumeController,
            decoration: const InputDecoration(
              labelText: "Humedad del Grano (%)",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: _activityState == 'Pendiente' ? null : (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa la humedad del grano.';
              }
              return null;
            },
            enabled: _activityState != 'Pendiente',
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
        validator: _activityState == 'Pendiente' ? null : (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingresa la densidad de semilla.';
          }
          return null;
        },
        enabled: _activityState != 'Pendiente',
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
        validator: _activityState == 'Pendiente' ? null : (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese la cantidad de plantas por ha';
          }
          return null;
        },
        enabled: _activityState != 'Pendiente',
      ),
    );
  }

  Widget _buildConVigorField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<int>(
        value: _conVigor ?? 1,
        decoration: const InputDecoration(labelText: "Vigor de las plantas", border: OutlineInputBorder()),
        items: [
          DropdownMenuItem(value: 1, child: Text("Deficiente")),
          DropdownMenuItem(value: 2, child: Text("Malo")),
          DropdownMenuItem(value: 3, child: Text("Regular")),
          DropdownMenuItem(value: 4, child: Text("Bueno")),
          DropdownMenuItem(value: 5, child: Text("Excelente")),
        ],
        onChanged: _activityState == 'Pendiente' ? null : (value) {
          setState(() {
            _conVigor = value!;
          });
        },
      ),
    );
  }

  Widget _buildAddWeatherButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navegar a la pantalla de agregar clima
          context.push('/add-weather'); // Esto abre la pantalla AddWeatherScreen
        },
        child: const Text("Agregar Clima"),
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
                  'ins_cant': insumo['ins_cant'] ?? 0.0,
                  'ins_unidad_medida': insumo['ins_unidad_medida'],
                });
              } else {
                // Es un insumo ya existente, lo agregamos a los insumosData
                insumosData.add({
                  'ins_id': insumo['ins_id'],
                  'ins_cant': insumo['ins_cant'] ?? 0.0,
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
                      'ins_cant': insumoNuevo['ins_cant'],  // Asignamos la cantidad del insumo nuevo
                      'ins_unidad_medida': insumoGuardado['ins_unidad_medida'],  // Asignamos la unidad de medida
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

            // 3. Guardar la actividad
            bool success = await Provider.of<ActivityProvider>(context, listen: false).addActivity(activityData);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Actividad guardada con éxito")));
              Navigator.pop(context, true);
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
        const SizedBox(height: 4),
        activityProvider.isLoadingUsuarios
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<int>(
                value: _ussId,  // Ahora _ussId es int o null
                validator: (value) {
                  if (value == null) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
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