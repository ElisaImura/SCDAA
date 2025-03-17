// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:mspaa/providers/activity_provider.dart';
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
    // Cargar los datos de la actividad para edición
    _descripcionController.text = widget.activityData['act_desc'];
    _selectedCiclo = widget.activityData['ciclo']['ci_id'].toString();
    _selectedTipoActividad = widget.activityData['tpAct_id'].toString();
    _selectedDate = DateTime.parse(widget.activityData['act_fecha']);
    
    
    //Busca el ciclo actual
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    // 🔹 Cargar el ciclo específico si no está en los ciclos activos
    if (_selectedCiclo != null &&
        !activityProvider.ciclosActivos.any((ciclo) => ciclo["ci_id"].toString() == _selectedCiclo)) {
      
      // 📌 Llamar a la API para cargar el ciclo específico
      activityProvider.fetchCicloEspecifico(int.parse(_selectedCiclo!));
    }


    // Configurar el estado de la actividad
    _activityState = widget.activityData['act_estado'] == 1
        ? "Pendiente"
        : widget.activityData['act_estado'] == 2
            ? "En curso"
            : "Finalizado";

    // Configurar el resto de los valores para los campos (si están disponibles)
    if (widget.activityData['ciclo']['sie_densidad'] != null) {
      _densidadController.text = widget.activityData['ciclo']['sie_densidad'];
    }
    if (widget.activityData['ciclo']['datos_ciclo']['cos_rendi'] != null) {
      _cosRendiController.text = widget.activityData['ciclo']['datos_ciclo']['cos_rendi'].toString();
    }
    if (widget.activityData['ciclo']['datos_ciclo']['cos_hume'] != null) {
      _cosHumeController.text = widget.activityData['ciclo']['datos_ciclo']['cos_hume'].toString();
    }
    if(widget.activityData['control_germinacion']!=null){
      if (widget.activityData['control_germinacion']['con_cant'] != null) {
        _conCantController.text = widget.activityData['control_germinacion']['con_cant'].toString();
      }
      if (widget.activityData['control_germinacion']['con_vigor'] != null) {
        _conVigor = widget.activityData['control_germinacion']['con_vigor'];
      }
    }

    // Cargar insumos si es necesario
    if (widget.activityData['insumos'] != null) {
      _selectedInsumos.addAll(widget.activityData['insumos']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Actividad"),
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
                setState(() {
                  _activityState = newState;
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
                    _buildCicloText(activityProvider),
                    const SizedBox(height: 20),
                    _buildTipoActividadDropdown(activityProvider),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate() &&
              _selectedCiclo != null &&
              _selectedTipoActividad != null) {
            Map<String, dynamic> activityData = {
              "act_id": widget.activityData["act_id"],
              "tpAct_id": int.parse(_selectedTipoActividad!),
              "ci_id": int.parse(_selectedCiclo!),
              "act_fecha": DateFormat("yyyy-MM-dd").format(_selectedDate),
              "act_desc": _descripcionController.text,
              "act_estado": _getActivityStateValue(_activityState),
              "uss_id": 1
            };

            if (_selectedTipoActividad == "3" && _densidadController.text.isNotEmpty) {
              activityData['sie_densidad'] = _densidadController.text;
            }

            if (_selectedTipoActividad == "6" && _cosRendiController.text.isNotEmpty && _cosHumeController.text.isNotEmpty) {
              activityData['cos_rendi'] = double.tryParse(_cosRendiController.text);
              activityData['cos_hume'] = double.tryParse(_cosHumeController.text);
            }

            if (_selectedTipoActividad == "4") {
              if (_conCantController.text.isNotEmpty) {
                activityData['con_cant'] = int.tryParse(_conCantController.text);
              }
              if (_conVigor != null) {
                activityData['con_vigor'] = _conVigor;
              }
            }

            if (_selectedInsumos.isNotEmpty) {
              activityData['insumos'] = _selectedInsumos.map((insumo) {
                return {
                  'ins_desc': insumo['ins_desc'],
                  'ins_id': insumo['ins_id'],
                  'ins_cant': insumo['inst_cant'],
                };
              }).toList();
            }

            print(activityData);

            bool success = await Provider.of<ActivityProvider>(context, listen: false).updateActivity(activityData);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Actividad actualizada con éxito"))
              );

              await Future.delayed(const Duration(milliseconds: 500)); // Esperar un poco

              if (mounted) {
                Navigator.pop(context, true);  // ✅ Volver a la pantalla de detalles enviando `true`
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error al actualizar la actividad"))
              );
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
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
    );
  }

  Widget _buildCicloText(ActivityProvider activityProvider) {
    String cicloNombre = "Cargando...";

    // Buscar el nombre del ciclo seleccionado
    if (_selectedCiclo != null) {
      var ciclo = activityProvider.ciclosActivos.firstWhere(
        (c) => c["ci_id"].toString() == _selectedCiclo,
        orElse: () => activityProvider.ciclo ?? {},
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
        return 1;
    }
  }
}
