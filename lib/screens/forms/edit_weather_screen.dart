// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/weather_provider.dart';

class EditWeatherScreen extends StatefulWidget {
  final Map<String, dynamic> weather;

  const EditWeatherScreen({super.key, required this.weather});

  @override
  _EditWeatherScreenState createState() => _EditWeatherScreenState();
}

class _EditWeatherScreenState extends State<EditWeatherScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _vientoController = TextEditingController();
  TextEditingController _temperaturaController = TextEditingController();
  TextEditingController _humedadController = TextEditingController();
  TextEditingController _lluviaController = TextEditingController();

  late DateTime _selectedDate;
  late DateTime _originalDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.parse(widget.weather['cl_fecha']);
    _vientoController = TextEditingController(text: widget.weather['cl_viento'].toString());
    _temperaturaController = TextEditingController(text: widget.weather['cl_temp'].toString());
    _humedadController = TextEditingController(text: widget.weather['cl_hume'].toString());
    _lluviaController = TextEditingController(text: widget.weather['cl_lluvia'].toString());
    _originalDate = DateTime.parse(widget.weather['cl_fecha']);
    _selectedDate = _originalDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      weatherProvider.checkWeatherForDate(DateFormat('yyyy-MM-dd').format(_selectedDate));
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Datos del Clima"),
      ),
      body: weatherProvider.isLoading
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
          });
          await weatherProvider.checkWeatherForDate(DateFormat('yyyy-MM-dd').format(_selectedDate));
        }
      }
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
      validator: (value) => (value == null || value.isEmpty)
          ? 'Por favor, ingresa la velocidad del viento.'
          : null,
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
      validator: (value) => (value == null || value.isEmpty)
          ? 'Por favor, ingresa la temperatura.'
          : null,
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
      validator: (value) => (value == null || value.isEmpty)
          ? 'Por favor, ingresa la humedad.'
          : null,
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
      validator: (value) => (value == null || value.isEmpty)
          ? 'Por favor, ingresa la cantidad de lluvia.'
          : null,
    );
  }

  Widget _buildSaveButton(WeatherProvider weatherProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedDate != _originalDate && weatherProvider.isWeatherAvailable
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  final nuevaFecha = DateFormat('yyyy-MM-dd').format(_selectedDate);
                  DateFormat('yyyy-MM-dd').format(_originalDate);

                  Map<String, dynamic> updatedData = {
                    "cl_fecha": nuevaFecha,
                    "cl_viento": double.tryParse(_vientoController.text) ?? 0.0,
                    "cl_temp": double.tryParse(_temperaturaController.text) ?? 0.0,
                    "cl_hume": double.tryParse(_humedadController.text) ?? 0.0,
                    "cl_lluvia": double.tryParse(_lluviaController.text) ?? 0.0,
                  };

                  bool success = await weatherProvider.editWeather(widget.weather['cl_id'], updatedData);

                  if (success) {
                    await weatherProvider.fetchWeatherData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Datos del clima actualizados con éxito")),
                    );
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error al actualizar los datos del clima")),
                    );
                  }
                }
              },
        child: _selectedDate != _originalDate && weatherProvider.isWeatherAvailable  // Change button text based on weather availability
            ? const Text("Clima ya registrado para esta fecha")
            : const Text("Guardar Datos"),
      ),
    );
  }

  @override
  void dispose() {
    _vientoController.dispose();
    _temperaturaController.dispose();
    _humedadController.dispose();
    _lluviaController.dispose();
    super.dispose();
  }
}