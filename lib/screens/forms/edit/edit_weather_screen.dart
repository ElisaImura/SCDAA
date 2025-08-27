// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../providers/lotes_provider.dart';

class EditWeatherScreen extends StatefulWidget {
  final Map<String, dynamic> weather;

  const EditWeatherScreen({super.key, required this.weather});

  @override
  _EditWeatherScreenState createState() => _EditWeatherScreenState();
}

class _EditWeatherScreenState extends State<EditWeatherScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vientoController = TextEditingController();
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _humedadController = TextEditingController();
  final TextEditingController _lluviaController = TextEditingController();

  late DateTime _selectedDate;
  late DateTime _originalDate;
  int? _selectedLoteId;
  late int _originalLoteId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.parse(widget.weather['cl_fecha']);
    _originalDate = _selectedDate;
    _selectedLoteId = widget.weather['lot_id'];
    _originalLoteId = widget.weather['lot_id'];

    _vientoController.text = widget.weather['cl_viento'].toString();
    _temperaturaController.text = widget.weather['cl_temp'].toString();
    _humedadController.text = widget.weather['cl_hume'].toString();
    _lluviaController.text = widget.weather['cl_lluvia'].toString();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<LotesProvider>(context, listen: false).fetchLotes();
      await Provider.of<WeatherProvider>(context, listen: false).checkWeatherForDate(
        DateFormat('yyyy-MM-dd').format(_selectedDate),
        _selectedLoteId!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final lotes = Provider.of<LotesProvider>(context).lotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Datos del Clima"),
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
                    _buildLoteDropdown(weatherProvider, lotes.cast<Map<String, dynamic>>()),
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

  Widget _buildLoteDropdown(WeatherProvider weatherProvider, List<Map<String, dynamic>> lotes) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: "Seleccionar lote",
        border: OutlineInputBorder(),
      ),
      value: _selectedLoteId,
      items: lotes.map((lote) {
        return DropdownMenuItem<int>(
          value: lote['lot_id'],
          child: Text(lote['lot_nombre'] ?? 'Sin nombre'),
        );
      }).toList(),
      onChanged: (value) async {
        if (value == null) return;

        setState(() {
          _selectedLoteId = value;
        });

        if (value != _originalLoteId || _selectedDate != _originalDate) {
          await weatherProvider.checkWeatherForDate(
            DateFormat('yyyy-MM-dd').format(_selectedDate),
            value,
          );
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) => (value == null || value.isEmpty)
          ? 'Por favor, ingresa la cantidad de lluvia.'
          : null,
    );
  }

  Widget _buildSaveButton(WeatherProvider weatherProvider) {
    final isDuplicate = (_selectedDate != _originalDate || _selectedLoteId != _originalLoteId)
        && weatherProvider.isWeatherAvailable;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDuplicate ? null : () async {
          if (!_formKey.currentState!.validate()) return;

          final nuevaFecha = DateFormat('yyyy-MM-dd').format(_selectedDate);
          final updatedData = {
            "cl_fecha": nuevaFecha,
            "cl_viento": double.tryParse(_vientoController.text) ?? 0.0,
            "cl_temp": double.tryParse(_temperaturaController.text) ?? 0.0,
            "cl_hume": double.tryParse(_humedadController.text) ?? 0.0,
            "cl_lluvia": double.tryParse(_lluviaController.text) ?? 0.0,
            "lot_id": _selectedLoteId!,
          };

          final success = await weatherProvider.editWeather(widget.weather['cl_id'], updatedData);
          if (!mounted) return;

          if (success) {
            // ✅ NO toques providers ni Scaffold aquí
            Navigator.of(context).pop({
              'changed': true,
              'cl_fecha': nuevaFecha,
              'lot_id': _selectedLoteId,
              'message': 'Datos del clima actualizados con éxito',
            });
          } else {
            // Error sí puede mostrar snackbar (sigue en esta pantalla)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error al actualizar los datos del clima")),
            );
          }
        },
        child: isDuplicate
            ? const Text("Clima ya registrado para esta fecha y lote")
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