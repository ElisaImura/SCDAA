// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/activity_provider.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCiclo;
  String? _selectedTipoActividad;
  final bool _mostrarNuevoCiclo = false;

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Actividad")),
      body: activityProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) // 🔄 Muestra un loader si aún carga
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seleccionar Ciclo
                    DropdownButtonFormField<String>(
                      value: _selectedCiclo,
                      decoration: const InputDecoration(labelText: "Ciclo", border: OutlineInputBorder()),
                      items: [
                        ...activityProvider.ciclos.map((ciclo) => DropdownMenuItem(
                              value: ciclo["ci_id"].toString(),
                              child: Text("Ciclo ${ciclo["ci_id"]}"),
                            )),
                        const DropdownMenuItem(value: "nuevo", child: Text("➕ Crear nuevo ciclo")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == "nuevo") {
                            context.push('/add-cycle'); // ✅ Abre AddCycleScreen
                          } else {
                            _selectedCiclo = value;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    if (_mostrarNuevoCiclo)
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Nombre del Nuevo Ciclo", border: OutlineInputBorder()),
                        validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                      ),
                    if (_mostrarNuevoCiclo) const SizedBox(height: 15),

                    // Seleccionar Tipo de Actividad
                    DropdownButtonFormField<String>(
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
                    ),
                    const SizedBox(height: 15),

                    // Seleccionar Fecha
                    ListTile(
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
                    ),
                    const SizedBox(height: 15),

                    // Descripción
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(labelText: "Descripción", border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                    ),
                    const SizedBox(height: 20),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && _selectedCiclo != null && _selectedTipoActividad != null) {
                            bool success = await Provider.of<ActivityProvider>(context, listen: false).addActivity({
                              "tpAct_id": int.parse(_selectedTipoActividad!),
                              "ci_id": int.parse(_selectedCiclo!),
                              "act_fecha": DateFormat("yyyy-MM-dd").format(_selectedDate),
                              "act_desc": _descripcionController.text,
                              "act_estado": 1, // Pendiente
                              "uss_id": 1, // Usuario autenticado
                            });

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Actividad guardada con éxito")));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al guardar")));
                            }
                          }
                        },
                        child: const Text("Guardar Actividad"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
