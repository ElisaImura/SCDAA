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
      appBar: AppBar(
        title: const Text('📊 Reportes Agrícolas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF0FFF0)],
          ),
        ),
        child: reportes.cargando
            ? const Center(child: CircularProgressIndicator())
            : reportes.error != null
                ? Center(child: Text(reportes.error!))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildExpansionTile(
                        icon: "📦",
                        title: "Producción Agrícola",
                        initiallyExpanded: true,
                        children: [
                          _buildSectionTitle("🌾 Rendimiento por Lote"),
                          _buildCardList(reportes.rendimientoPorLote, (e) => ListTile(
                                title: Text("${e['cultivo']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text("Lote: ${e['lote']}"),
                                trailing: Text("${e['total_cosechado'] ?? 'N/D'} kg"),
                              )),
                          _buildSectionTitle("📈 Promedio de producción por variedad"),
                          _buildCardList(reportes.promedioPorVariedad, (e) => ListTile(
                                title: Text("${e['cultivo']} - ${e['variedad']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text("Promedio por ciclo: ${e['promedio_cosecha'] ?? 'N/D'} kg"),
                              )),
                          _buildSectionTitle("📅 Producción por ciclo agrícola"),
                          _buildCardList(reportes.comparativaPorCiclo, (e) => ListTile(
                                title: Text("Ciclo: ${e['ciclo']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text("Cultivo: ${e['cultivo']}"),
                                trailing: Text("${e['total_cosechado'] ?? 'N/D'} kg"),
                              )),
                        ],
                      ),
                      _buildExpansionTile(
                        icon: "🧪",
                        title: "Manejo de Insumos",
                        children: [
                          _buildSectionTitle("🧪 Insumos más utilizados"),
                          _buildCardList(reportes.insumosMasUtilizados, (e) => ListTile(
                                title: Text(e['insumo'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: const Text("Total utilizado:"),
                                trailing: Text("${e['total_utilizado']} ${e['unidad']}"),
                              )),
                        ],
                      ),
                      _buildExpansionTile(
                        icon: "🌧",
                        title: "Clima y Ambiente",
                        children: [
                          _buildSectionTitle("📆 Seleccionar ciclo para gráfico de lluvia"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                final DateTime fechaFin = ciclo['ci_fechafin'] != null
                                    ? DateTime.parse(ciclo['ci_fechafin'])
                                    : DateTime.now();
                                await reportes.fetchLluviasPorFecha(fechaInicio, fechaFin);
                              },
                            ),
                          ),
                          if (reportes.cicloSeleccionado != null) ...[
                            const SizedBox(height: 20),
                            _buildSectionTitle("🌧️ Lluvia diaria en el ciclo seleccionado"),
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
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      backgroundColor: Colors.green[50],
      collapsedBackgroundColor: Colors.green[100],
      title: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      children: children,
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCardList(List data, Widget Function(dynamic) itemBuilder) {
    if (data.isEmpty) {
      return const Text("No hay datos disponibles.");
    }
    return Column(
      children: data.map((e) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: itemBuilder(e),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRainChart(ReportesProvider reportes) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: reportes.lluviasPorFecha.isEmpty
          ? const Center(child: Text("No hay datos de lluvia disponibles para este ciclo."))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8),
                  child: Text("Lluvia (mm) por día", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
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
                            reservedSize: 32,
                            interval: (reportes.lluviasPorFecha.length / 5).ceilToDouble(),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= reportes.lluviasPorFecha.length) return const SizedBox();
                              final fecha = reportes.lluviasPorFecha[index]['fecha'].toString().substring(5);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(fecha, style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: Colors.teal,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.teal.withOpacity(0.2),
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
