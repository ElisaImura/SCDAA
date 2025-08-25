// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../screens/forms/add/add_lote_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../providers/lotes_provider.dart'; // Asegúrate de importar el provider correcto
import '../../../providers/users_provider.dart';

class AddWeatherScreen extends StatefulWidget {
  final bool isFromFooter;
  const AddWeatherScreen({super.key, this.isFromFooter = false});

  @override
  _AddWeatherScreenState createState() => _AddWeatherScreenState();
}

class _AddWeatherScreenState extends State<AddWeatherScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vientoController = TextEditingController();
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _humedadController = TextEditingController();
  final TextEditingController _lluviaController = TextEditingController();

  
  DateTime _selectedDate = DateTime.now();
  int? _selectedLoteId;
  bool _isFutureDate = false; // Nueva variable para controlar si la fecha es futura

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<LotesProvider>(context, listen: false).fetchLotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final lotesProvider = Provider.of<LotesProvider>(context);
    final lotes = lotesProvider.lotes;
    final userInfo = Provider.of<UsersProvider>(context, listen: false).userData;
    final isAdmin = userInfo?['rol']?['rol_id'] == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Datos del Clima"),
      ),
      body: weatherProvider.isLoading || lotes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDatePicker(weatherProvider),
                    const SizedBox(height: 20),
                    _buildLoteDropdown(weatherProvider, lotes.cast<Map<String, dynamic>>(), isAdmin),
                    const SizedBox(height: 20),
                    _buildVientoField(),
                    const SizedBox(height: 20),
                    _buildTemperaturaField(),
                    const SizedBox(height: 20),
                    _buildHumedadField(),
                    const SizedBox(height: 20),
                    _buildLluviaField(),
                    const SizedBox(height: 20),
                    _buildSaveButton(weatherProvider),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDatePicker(WeatherProvider weatherProvider) {
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
            _isFutureDate = pickedDate.isAfter(DateTime.now());
          });

          if (_selectedLoteId != null) {
            await weatherProvider.checkWeatherForDate(
              DateFormat('yyyy-MM-dd').format(_selectedDate),
              _selectedLoteId!,
            );
          }
        }
      },
    );
  }

  Widget _buildLoteDropdown(WeatherProvider weatherProvider, List<Map<String, dynamic>> lotes, bool isAdmin) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: "Seleccionar lote",
        border: OutlineInputBorder(),
      ),
      value: _selectedLoteId,
      items: [
        ...lotes.map((lote) {
          return DropdownMenuItem<int>(
            value: lote['lot_id'],
            child: Text(lote['lot_nombre'] ?? 'Sin nombre'),
          );
        }),
        if (isAdmin)
          const DropdownMenuItem<int>(
            value: -1,
            child: Text("➕ Crear nuevo lote"),
          ),
      ],
      onChanged: (value) async {
        if (value == -1) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLoteScreen()),
          );

          if (result == true) {
            await Provider.of<LotesProvider>(context, listen: false).fetchLotes();

            // Asignar el último lote como seleccionado
            final nuevosLotes = Provider.of<LotesProvider>(context, listen: false).lotes;
            if (nuevosLotes.isNotEmpty) {
              setState(() {
                _selectedLoteId = nuevosLotes.last['lot_id'];
              });

              await weatherProvider.checkWeatherForDate(
                DateFormat('yyyy-MM-dd').format(_selectedDate),
                _selectedLoteId!,
              );
            }
          }
        } else {
          setState(() {
            _selectedLoteId = value;
          });

          if (value != null) {
            await weatherProvider.checkWeatherForDate(
              DateFormat('yyyy-MM-dd').format(_selectedDate),
              value,
            );
          }
        }
      },
    );
  }

  Widget _buildVientoField() {
    return TextFormField(
      controller: _vientoController,
      decoration: const InputDecoration(
        labelText: "Velocidad del Viento (m/s)",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildTemperaturaField() {
    return TextFormField(
      controller: _temperaturaController,
      decoration: const InputDecoration(
        labelText: "Temperatura (°C)",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildHumedadField() {
    return TextFormField(
      controller: _humedadController,
      decoration: const InputDecoration(
        labelText: "Humedad (%)",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildLluviaField() {
    return TextFormField(
      controller: _lluviaController,
      decoration: const InputDecoration(
        labelText: "Cantidad de Lluvia (mm)",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  bool _validateFields() {
    return _vientoController.text.isNotEmpty ||
        _temperaturaController.text.isNotEmpty ||
        _humedadController.text.isNotEmpty ||
        _lluviaController.text.isNotEmpty;
  }

  Widget _buildSaveButton(WeatherProvider weatherProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (weatherProvider.isWeatherAvailable || _isFutureDate)
            ? null
            : () async {
                if (_selectedLoteId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Seleccioná un lote antes de guardar.")),
                  );
                  return;
                }
                if (_formKey.currentState!.validate() && _validateFields()) {
                  Map<String, dynamic> weatherData = {
                    "cl_fecha": DateFormat("yyyy-MM-dd").format(_selectedDate),
                    "cl_viento": double.tryParse(_vientoController.text) ?? 0.0,
                    "cl_temp": double.tryParse(_temperaturaController.text) ?? 0.0,
                    "cl_hume": double.tryParse(_humedadController.text) ?? 0.0,
                    "cl_lluvia": double.tryParse(_lluviaController.text) ?? 0.0,
                    "lot_id": _selectedLoteId!,
                  };

                  bool success = await weatherProvider.addWeatherData(weatherData);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Datos del clima guardados con éxito")),
                    );

                    widget.isFromFooter ? context.go('/home') : Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error al guardar los datos del clima")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, complete al menos un campo de datos del clima")),
                  );
                }
              },
        child: weatherProvider.isWeatherAvailable
            ? const Text("Clima ya registrado para esta fecha y lote")
            : _isFutureDate
                ? const Text("No se puede agregar clima a una fecha futura")
                : const Text("Guardar Datos"),
      ),
    );
  }
}
