// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _variedadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Ciclo")),
      body: activityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seleccionar Tipo de Cultivo
                    DropdownButtonFormField<String>(
                      value: _selectedTipoCultivo,
                      decoration: const InputDecoration(labelText: "Tipo de Cultivo", border: OutlineInputBorder()),
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
                      decoration: const InputDecoration(labelText: "Variedad", border: OutlineInputBorder()),
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
                        decoration: const InputDecoration(labelText: "Nombre de la Nueva Variedad", border: OutlineInputBorder()),
                        validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                      ),
                    if (_mostrarNuevaVariedad) const SizedBox(height: 15),

                    // Seleccionar Lote
                    DropdownButtonFormField<String>(
                      value: _selectedLote,
                      decoration: const InputDecoration(labelText: "Lote", border: OutlineInputBorder()),
                      items: activityProvider.lotes.map((lote) {
                        return DropdownMenuItem(
                          value: lote["lot_id"].toString(),
                          child: Text(lote["lot_nombre"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLote = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

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

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedTipoCultivo != null &&
                              _selectedVariedad != null &&
                              _selectedLote != null) {
                            bool success = await activityProvider.addCiclo({
                              "tpCult_id": int.parse(_selectedTipoCultivo!),
                              "var_id": _mostrarNuevaVariedad
                                  ? await activityProvider.addVariedad(_variedadController.text, _selectedTipoCultivo!)
                                  : int.parse(_selectedVariedad!),
                              "lot_id": int.parse(_selectedLote!),
                              "ci_fechaini": DateFormat("yyyy-MM-dd").format(_selectedDate),
                              "uss_id": await activityProvider.getLoggedUserId(),
                            });

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Ciclo guardado con éxito")));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Error al guardar el ciclo")));
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
