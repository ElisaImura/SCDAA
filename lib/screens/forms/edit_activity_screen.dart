// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unused_field, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:mspaa/providers/cycle_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditActivityScreen extends StatefulWidget {
  final Map<String, dynamic> activityData;

  const EditActivityScreen({super.key, required this.activityData});

  @override
  _EditActivityScreenState createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _insumoController = TextEditingController();
  final TextEditingController _newInsumoController = TextEditingController();
  final TextEditingController _densidadController = TextEditingController();
  final TextEditingController _cosRendiController = TextEditingController();
  final TextEditingController _cosHumeController = TextEditingController();
  final TextEditingController _conCantController = TextEditingController();
  final TextEditingController _unidadController = TextEditingController();

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

    _descripcionController.text = widget.activityData['act_desc'];
    _selectedCiclo = widget.activityData['ciclo']['ci_id'].toString();
    _selectedTipoActividad = widget.activityData['tpAct_id'].toString();
    _selectedDate = DateTime.parse(widget.activityData['act_fecha']);
    
    if (widget.activityData['ciclo']['act_ciclos'] is List &&
        widget.activityData['ciclo']['act_ciclos'].isNotEmpty) {
      _ussId = widget.activityData['ciclo']['act_ciclos'][0]['uss_id'] as int?;
    } else {
      print("No hay datos en act_ciclos o la lista está vacía.");
      _ussId = null; // O asigna un valor por defecto si es necesario
    }

    print('Usuario: $_ussId');

    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);

    // ✅ Llamar a los fetchers de manera diferida para evitar conflictos con el árbol de widgets
    Future.delayed(Duration.zero, () {
      cycleProvider.fetchCiclosActivos();
      activityProvider.fetchUsuarios();
    });

    // Configurar estado de la actividad
    _activityState = _getActivityStateString(widget.activityData['act_estado']);

    print('Sie_densidad: ${widget.activityData['ciclo']['datos_ciclo']['sie_densidad']}');

    if (widget.activityData['ciclo']['datos_ciclo']['sie_densidad'] != null) {
      _densidadController.text = widget.activityData['ciclo']['datos_ciclo']['sie_densidad'].toString();
    }
    if (widget.activityData['ciclo']['datos_ciclo']['cos_rendi'] != null) {
      _cosRendiController.text = widget.activityData['ciclo']['datos_ciclo']['cos_rendi'].toString();
    }
    if (widget.activityData['ciclo']['datos_ciclo']['cos_hume'] != null) {
      _cosHumeController.text = widget.activityData['ciclo']['datos_ciclo']['cos_hume'].toString();
    }
    if (widget.activityData['control_germinacion'] != null) {
      if (widget.activityData['control_germinacion']['con_cant'] != null) {
        _conCantController.text = widget.activityData['control_germinacion']['con_cant'].toString();
      }
      if (widget.activityData['control_germinacion']['con_vigor'] != null) {
        _conVigor = widget.activityData['control_germinacion']['con_vigor'];
      }
    }

    if (widget.activityData['ciclo']['insumos'] is List) {
      for (var insumo in widget.activityData['ciclo']['insumos']) {
        _selectedInsumos.add({
          'ins_desc': insumo['ins_desc'],
          'ins_id': insumo['ins_id'],
          'ins_cant': insumo['ins_cant'],
          'ins_unidad_medida': insumo['ins_unidad_medida'], // Add unidad de medida
          'controller': TextEditingController(text: insumo['ins_cant'].toString()), // ✅ Controlador para cantidad
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final cycleProvider = Provider.of<CycleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Actividad"),
        actions: [
          GestureDetector(
            onTap: () async {
              if (_selectedDate.isAfter(DateTime.now())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No se puede cambiar el estado si la fecha es futura"))
                );
                return;
              }
              final String? newState = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Cambiar Estado de la Actividad'),
                    content: DropdownButton<String>(
                      value: _activityState,  // El valor actual del estado
                      onChanged: (String? newValue) {
                        // Cambiar el estado de la actividad
                        Navigator.pop(context, newValue); // Cerrar el diálogo y devolver el valor seleccionado
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
                setState(() {
                  _activityState = newState; // Actualizar el estado de la actividad
                });
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
                    _buildCicloText(activityProvider, cycleProvider),
                    const SizedBox(height: 20),
                    _buildTipoActividadDropdown(activityProvider),
                    const SizedBox(height: 20),
                    _buildResponsableDropdown(activityProvider),
                    const SizedBox(height: 20),
                    if (_selectedTipoActividad == "3") _buildDensidadField(),
                    if (_selectedTipoActividad == "6") _buildCosechaFields(),
                    if (_selectedTipoActividad == "4") _buildConCantField(),
                    if (_selectedTipoActividad == "4") _buildConVigorField(),
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

  Widget _buildSaveButton() {
    void onSaveSuccess(BuildContext context) {
      // Recargar las actividades y tareas después de guardar la actividad
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      if (mounted) {
        activityProvider.fetchActividadesRecientes();
        activityProvider.fetchTareas(); 
      }

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Actividad actualizada con éxito")));

      // Navegar a la pantalla de inicio después de un pequeño retraso
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) { // Verificar si el widget sigue montado
          Navigator.pop(context, true);  // Volver a la pantalla de detalles enviando `true`
          GoRouter.of(context).go('/home'); // Redirigir al home
        }
      });
    }

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
              "act_id": widget.activityData["act_id"],
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

            // 3. Llamar a la función asincrónica de actualización fuera de setState
            bool success = await Provider.of<ActivityProvider>(context, listen: false).updateActivity(activityData);

            // Verificar si el widget sigue montado antes de llamar a setState
            if (mounted) {
              setState(() {
                // Aquí solo actualizas el estado, no haces trabajo asíncrono.
              });

              // Llamar a la función de éxito si todo salió bien
              if (success) {
                onSaveSuccess(context); // Llamar a la función de éxito
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error al actualizar la actividad"))
                );
              }
            }
          }
        },
        child: const Text("Actualizar Actividad"),
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
          if (mounted) { // Verificar si el widget aún está montado
            setState(() {
              _selectedDate = pickedDate;
            });
          }
        }
      },
    );
  }

  Widget _buildCicloText(ActivityProvider activityProvider, CycleProvider cycleProvider) {
    String cicloNombre = "Cargando...";

    // Buscar el nombre del ciclo seleccionado
    if (_selectedCiclo != null) {
      var ciclo = cycleProvider.ciclosActivos.firstWhere(
        (c) => c["ci_id"].toString() == _selectedCiclo,
        orElse: () => cycleProvider.ciclo ?? {},
      );

      if (ciclo.isNotEmpty) {
        cicloNombre = ciclo["ci_nombre"] ?? "Ciclo no encontrado";
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Text(
            "Ciclo:", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8), // Espacio entre el título y el nombre del ciclo
          Expanded( // Para que el nombre del ciclo no se corte si es largo
            child: Text(
              cicloNombre,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              overflow: TextOverflow.ellipsis, // Si es largo, muestra "..."
            ),
          ),
        ],
      ),
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
        if (mounted) { // Verificar si el widget aún está montado
          setState(() {
            _selectedTipoActividad = value;
          });
        }
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

          // Sección para buscar insumos existentes
          AbsorbPointer(
            absorbing: _activityState == 'Pendiente',  // Bloqueado si el estado es Pendiente
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
                  _selectedInsumos.add({
                    'ins_desc': suggestion['ins_desc'] ?? '',
                    'ins_id': suggestion['ins_id'] ?? 0,
                    'ins_cant': 0.0,
                    'ins_unidad_medida': suggestion['ins_unidad_medida'] ?? '',
                    'controller': TextEditingController(text: ''),
                  });
                  _newInsumoController.clear();
                });
              },
            ),
          ),

          // Mensaje si no hay insumos preexistentes
          if (_activityState != 'Pendiente' && Provider.of<ActivityProvider>(context).insumos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "No hay insumos preexistentes disponibles. Agrega un nuevo insumo.",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),

          const SizedBox(height: 10),

          // Sección para agregar un nuevo insumo
          if (_activityState != 'Pendiente') 
            Row(
              children: [
                // Descripción del nuevo insumo
                Expanded(
                  child: TextFormField(
                    controller: _newInsumoController,
                    decoration: const InputDecoration(
                      labelText: "Nuevo Insumo",
                      hintText: "Nombre del insumo",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Unidad de medida del nuevo insumo
                Expanded(
                  child: TextFormField(
                    controller: _unidadController,
                    decoration: const InputDecoration(
                      labelText: "Unidad de medida",
                      hintText: "Unidad",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),

          // Botón para agregar insumo nuevo
          if (_activityState != 'Pendiente')
            ElevatedButton.icon(
              onPressed: () {
                if (_newInsumoController.text.isNotEmpty && _unidadController.text.isNotEmpty) {
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
          const SizedBox(height: 15),

          // Mostrar la lista de insumos agregados
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
                                insumo['ins_cant'] = value.isEmpty ? 0.0 : double.tryParse(value) ?? 0.0;
                              });
                            },
                            enabled: _activityState != 'Pendiente',  // Bloqueado si el estado es Pendiente
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(insumo['ins_unidad_medida'] ?? ''),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: _activityState == 'Pendiente' ? null : () {
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
            enabled: _activityState != 'Pendiente',  // Bloqueado si el estado es Pendiente
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
            enabled: _activityState != 'Pendiente',  // Bloqueado si el estado es Pendiente
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
        enabled: _activityState != 'Pendiente',  // Bloqueado si el estado es Pendiente
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
        enabled: _activityState != 'Pendiente',  // Bloqueado si el estado es Pendiente
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
                value: _ussId, // Asegúrate de que el valor se está actualizando correctamente
                decoration: const InputDecoration(
                  labelText: "Selecciona un responsable",
                  border: OutlineInputBorder(),
                ),
                items: activityProvider.usuarios.map<DropdownMenuItem<int>>((usuario) {
                  return DropdownMenuItem(
                    value: usuario["uss_id"],
                    child: Text(usuario["uss_nombre"] ?? "Sin nombre"),
                  );
                }).toList(),
                onChanged: (value) {
                  if (mounted) { // Verificar si el widget aún está montado
                    setState(() {
                      _ussId = value;
                      print('Usuario seleccionado: $_ussId');
                    });
                  }
                },
              ),
      ],
    );
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

  String _getActivityStateString(int state) {
    switch (state) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'En progreso';
      case 3:
        return 'Finalizada';
      default:
        return 'Desconocido';
    }
  }
}
