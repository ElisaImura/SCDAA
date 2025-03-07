import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? selectedCycle;
  String? selectedActivity;
  String? selectedLote;
  DateTimeRange? selectedDateRange;

  final List<String> cycles = ['Safra 2025', 'Safrinha 2024', 'Soja Lote 1'];
  final List<String> activities = ['Siembra', 'Cosecha', 'Riego', 'Fumigación'];
  final List<String> lotes = ['Lote 1', 'Lote 2', 'Lote 3'];

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown('Ciclo', selectedCycle, cycles, (value) {
                setState(() => selectedCycle = value);
              }),
              _buildDropdown('Actividad', selectedActivity, activities, (value) {
                setState(() => selectedActivity = value);
              }),
              _buildDropdown('Lote', selectedLote, lotes, (value) {
                setState(() => selectedLote = value);
              }),
              ElevatedButton(
                onPressed: () async {
                  DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => selectedDateRange = picked);
                  }
                },
                child: const Text('Seleccionar Rango de Fechas'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Aplicar filtros aquí
                },
                child: const Text('Aplicar Filtros'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterModal,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // Aquí irá la lógica para exportar el PDF
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Productividad por Lote'),
            _buildBarChart(),
            const SizedBox(height: 20),
            _buildSectionTitle('Uso de Insumos'),
            _buildPieChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: Colors.green)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: Colors.green)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: Colors.green)]),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, color: Colors.blue, title: 'Fertilizante'),
            PieChartSectionData(value: 30, color: Colors.orange, title: 'Pesticida'),
            PieChartSectionData(value: 20, color: Colors.red, title: 'Semillas'),
          ],
        ),
      ),
    );
  }
}
