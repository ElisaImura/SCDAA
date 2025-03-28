// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mspaa/providers/reportes_provider.dart';
import 'package:provider/provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportesProvider = Provider.of<ReportesProvider>(context, listen: false);
      reportesProvider.cargarReportes();
      reportesProvider.cargarCiclos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportes = Provider.of<ReportesProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4FDF4),
      body: SafeArea(
        child: reportes.cargando
            ? const Center(child: CircularProgressIndicator())
            : reportes.error != null
                ? Center(child: Text(reportes.error!))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Text(
                          "Analisis de datos",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _buildExpansionTile(
                        icon: "🌾",
                        title: "Producción Agrícola",
                        initiallyExpanded: true,
                        children: [
                          _buildSectionTitle("Rendimiento por Lote"),
                          _buildCardList(reportes.rendimientoPorLote, (e) => ListTile(
                                title: Text("${e['cultivo']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text("Lote: ${e['lote']}"),
                                trailing: Text("${e['total_cosechado'] ?? 'N/D'} kg", style: const TextStyle(fontWeight: FontWeight.bold)),
                              )),
                          _buildSectionTitle("Promedio de producción por variedad"),
                          _buildCardList(reportes.promedioPorVariedad, (e) => ListTile(
                                title: Text("${e['cultivo']} - ${e['variedad']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text("Promedio: ${e['promedio_cosecha'] ?? 'N/D'} kg"),
                              )),
                          _buildSectionTitle("Producción por ciclo agrícola"),
                          _buildCardList(reportes.comparativaPorCiclo, (e) => ListTile(
                                title: Text("Ciclo: ${e['ciclo']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text("Cultivo: ${e['cultivo']}"),
                                trailing: Text("${e['total_cosechado'] ?? 'N/D'} kg", style: const TextStyle(fontWeight: FontWeight.bold)),
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildExpansionTile(
                        icon: "🧪",
                        title: "Manejo de Insumos",
                        children: [
                          _buildSectionTitle("Insumos más utilizados"),
                          _buildCardList(reportes.insumosMasUtilizados, (e) => ListTile(
                                title: Text(e['insumo'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: const Text("Total utilizado:"),
                                trailing: Text("${e['total_utilizado']} ${e['unidad']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildExpansionTile(
                        icon: "🌧",
                        title: "Clima y Ambiente",
                        children: [
                          _buildSectionTitle("Seleccionar ciclo para ver lluvia"),
                          _buildDropdown(reportes),
                          if (reportes.cicloSeleccionado != null) ...[
                            const SizedBox(height: 20),
                            _buildSectionTitle("Lluvia diaria en el ciclo seleccionado"),
                            _buildRainChart(reportes),
                          ]
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildExpansionTile({required String icon, required String title, bool initiallyExpanded = false, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF388E3C)),
      ),
    );
  }

  Widget _buildCardList(List data, Widget Function(dynamic) itemBuilder) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text("No hay datos disponibles."),
      );
    }
    return Column(
      children: data.map((e) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: itemBuilder(e),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown(ReportesProvider reportes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        underline: const SizedBox(),
        value: reportes.cicloSeleccionado?['ci_id'],
        hint: const Text("Selecciona un ciclo"),
        items: reportes.ciclos.map((ciclo) {
          return DropdownMenuItem<int>(
            value: ciclo['ci_id'],
            child: Text(ciclo['ci_nombre']),
          );
        }).toList(),
        onChanged: (idSeleccionado) async {
          final ciclo = reportes.ciclos.firstWhere((c) => c['ci_id'] == idSeleccionado);
          reportes.seleccionarCiclo(ciclo);
          final DateTime fechaInicio = DateTime.parse(ciclo['ci_fechaini']);
          final DateTime fechaFin = ciclo['ci_fechafin'] != null ? DateTime.parse(ciclo['ci_fechafin']) : DateTime.now();
          final int loteId = ciclo['lot_id'];
          await reportes.fetchLluviasPorFecha(fechaInicio, fechaFin, loteId: loteId);
        },
      ),
    );
  }

  Widget _buildRainChart(ReportesProvider reportes) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: reportes.lluviasPorFecha.isEmpty
          ? const Center(child: Text("No hay datos de lluvia disponibles para este ciclo."))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Lluvia (mm) por día", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(),
                          bottom: BorderSide(),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text("${value.toInt()} mm", style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: (reportes.lluviasPorFecha.length / 5).ceilToDouble(),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= reportes.lluviasPorFecha.length) return const SizedBox();
                              final fecha = reportes.lluviasPorFecha[index]['fecha'].toString().substring(5);
                              return Text(fecha, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: Colors.green[700],
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withOpacity(0.2),
                          ),
                          dotData: FlDotData(show: true),
                          spots: reportes.lluviasPorFecha.asMap().entries.map((entry) {
                            final index = entry.key.toDouble();
                            final lluvia = (entry.value['total_lluvia'] ?? 0).toDouble();
                            return FlSpot(index, lluvia);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
