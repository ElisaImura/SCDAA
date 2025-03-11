import 'package:flutter/material.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String estado;
  final String descripcion;
  final String ciclo;
  final String lote;
  final List<dynamic> insumos;

  const ActivityDetailScreen({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.estado,
    required this.descripcion,
    required this.ciclo,
    required this.lote,
    required this.insumos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles de la Actividad"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView( // Añadimos SingleChildScrollView aquí
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(fecha, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Estado: $estado", style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.repeat, color: Colors.grey),
                const SizedBox(width: 8),
                Text(ciclo, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.map, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Lote: $lote", style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Descripción:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              "Insumos:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            insumos.isNotEmpty
              ? Column(
                  children: insumos.toSet().toList().map((insumo) { // Usamos `toSet` para eliminar duplicados
                    return ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.blue),
                      title: Text(insumo['ins_desc']),
                      subtitle: Text(
                        "Cantidad: ${insumo['ins_cant']}",
                      ),
                    );
                  }).toList(),
                )
              : const Text("No hay insumos registrados."),
            const SizedBox(height: 20), // Espacio entre los insumos y los botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  label: const Text("Eliminar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
