// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mspaa/providers/cycle_provider.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/activity_provider.dart';

class AddCycleScreen extends StatefulWidget {
  const AddCycleScreen({super.key});

  @override
  _AddCycleScreenState createState() => _AddCycleScreenState();
}

class _AddCycleScreenState extends State<AddCycleScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _selectedTipoCultivo;
  String? _selectedVariedad;
  String? _selectedLote;
  bool _mostrarNuevaVariedad = false;
  bool _mostrarNuevoLote = false; // Flag para el nuevo lote
  String? cicloNombre; // Nueva variable para el nombre del ciclo
  final TextEditingController _variedadController = TextEditingController();
  final TextEditingController _loteController = TextEditingController(); // Controlador para el nuevo lote
  final TextEditingController _cicloNombreController = TextEditingController(); // Controlador para el nombre del ciclo

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final cycleProvider = Provider.of<CycleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Nuevo Ciclo")),
      body: activityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seleccionar Fecha de Inicio del Ciclo
                    ListTile(
                      title: Text("Fecha de Inicio: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
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
                    ),
                    const SizedBox(height: 15),

                    // Campo para el nombre del ciclo
                    TextFormField(
                      controller: _cicloNombreController,
                      decoration: const InputDecoration(
                          labelText: "Nombre del nuevo ciclo", border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                      onChanged: (value) {
                        setState(() {
                          cicloNombre = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Seleccionar Tipo de Cultivo
                    DropdownButtonFormField<String>(
                      value: _selectedTipoCultivo,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: "Tipo de Cultivo", border: OutlineInputBorder()),
                      items: activityProvider.tiposCultivos.map((cultivo) {
                        return DropdownMenuItem(
                          value: cultivo["tpCul_id"]?.toString() ?? "",
                          child: Text(cultivo["tpCul_nombre"] ?? "Sin Nombre"),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          _selectedTipoCultivo = value;
                          _selectedVariedad = null;
                          _mostrarNuevaVariedad = false;
                          activityProvider.variedades.clear();
                        });

                        if (value != null) {
                          await activityProvider.getVariedadesByCultivo(value);
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    // Seleccionar o Agregar Variedad
                    DropdownButtonFormField<String>(
                      value: _selectedVariedad,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: "Variedad", border: OutlineInputBorder()),
                      items: [
                        if (activityProvider.variedades.isNotEmpty)
                          ...activityProvider.variedades.map((variedad) {
                            return DropdownMenuItem(
                              value: variedad["tpVar_id"].toString(),
                              child: Text(variedad["tpVar_nombre"] ?? "Sin Nombre"),
                            );
                          }),
                        const DropdownMenuItem(value: "nuevo", child: Text("➕ Nueva Variedad")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedVariedad = value;
                          _mostrarNuevaVariedad = value == "nuevo";
                        });
                      },
                      disabledHint: const Text("Selecciona un Tipo de Cultivo"),
                    ),

                    const SizedBox(height: 15),

                    // Campo de Nueva Variedad (solo si se elige "Nueva Variedad")
                    if (_mostrarNuevaVariedad)
                      TextFormField(
                        controller: _variedadController,
                        decoration: const InputDecoration(
                            labelText: "Nombre de la Nueva Variedad", border: OutlineInputBorder()),
                        validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                      ),
                    if (_mostrarNuevaVariedad) const SizedBox(height: 15),

                    // Seleccionar o Agregar Lote
                    DropdownButtonFormField<String>(
                      value: _selectedLote,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: "Lote", border: OutlineInputBorder()),
                      items: [
                        if (activityProvider.lotes.isNotEmpty)
                          ...activityProvider.lotes.map((lote) {
                            return DropdownMenuItem(
                              value: lote["lot_id"].toString(),
                              child: Text(lote["lot_nombre"]),
                            );
                          }),
                        const DropdownMenuItem(value: "nuevo", child: Text("➕ Nuevo Lote")),
                      ],
                      onChanged: (value) async {
                        setState(() {
                          _selectedLote = value;
                          _mostrarNuevoLote = value == "nuevo";
                        });

                        if (value != null && value != "nuevo") {
                          bool hasActiveCycle = await cycleProvider.checkActiveCycle(int.parse(value));
                          if (hasActiveCycle) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("El lote ya tiene un ciclo activo."))
                            );
                            setState(() {
                              _selectedLote = null;
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo de Nuevo Lote (solo si se elige "Nuevo Lote")
                    if (_mostrarNuevoLote)
                      TextFormField(
                        controller: _loteController,
                        decoration: const InputDecoration(labelText: "Nombre del Nuevo Lote", border: OutlineInputBorder()),
                        validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                      ),
                    if (_mostrarNuevoLote) const SizedBox(height: 15),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedTipoCultivo != null &&
                              (_selectedVariedad != null || _mostrarNuevaVariedad) &&
                              _selectedLote != null) {

                            // Obtener el id de nuevo lote si se seleccionó "Nuevo Lote"
                            int? loteId;
                            if (_mostrarNuevoLote) {
                              // Guardar el nuevo lote y obtener su ID
                              loteId = await activityProvider.addLote(
                                _loteController.text,
                              );
                            } else {
                              // Verificar si el lote ya tiene un ciclo activo
                              bool hasActiveCycle = await cycleProvider.checkActiveCycle(int.parse(_selectedLote!));

                              if (hasActiveCycle) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("El lote ya tiene un ciclo activo."))
                                );
                                return;
                              } else {
                                loteId = int.parse(_selectedLote!);
                              }
                            }

                            // Obtener el id de la nueva variedad si se seleccionó "Nueva Variedad"
                            int? variedadId;
                            if (_mostrarNuevaVariedad) {
                              int cultivoId = int.parse(_selectedTipoCultivo!);
                              // Guardar la nueva variedad y obtener su ID
                              variedadId = await activityProvider.addVariedad(
                                _variedadController.text,
                                cultivoId
                              );
                            } else {
                              // Si no es una nueva variedad, usar la seleccionada
                              variedadId = int.parse(_selectedVariedad!);
                            }

                            // Verifica que se haya obtenido un ID de variedad válido
                            if (variedadId == null || loteId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Error al obtener el ID del lote o la variedad"))
                              );
                              return;
                            }

                            // Datos que se enviarán al backend
                            Map<String, dynamic> cicloData = {
                              "tpCult_id": int.parse(_selectedTipoCultivo!),
                              "tpVar_id": variedadId,
                              "lot_id": loteId,
                              "ci_fechaini": DateFormat("yyyy-MM-dd").format(_selectedDate),
                              "uss_id": await activityProvider.getLoggedUserId(),
                              "ci_nombre": cicloNombre ?? "", // Usamos el nombre del ciclo
                            };

                            // Llamar a la función addCiclo
                            bool success = await cycleProvider.addCiclo(cicloData);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Ciclo guardado con éxito")));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Error al guardar el ciclo. Por favor, inténtelo de nuevo.")));
                            }
                          }
                        },
                        child: const Text("Guardar Ciclo"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
