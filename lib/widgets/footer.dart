import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none, // Evita recortes del botón flotante
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF393939),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home, "Inicio", "/home"),
                _buildNavItem(context, Icons.calendar_today, "Calendario", "/calendar"),
                const SizedBox(width: 60), // Espacio para el botón flotante
                _buildNavItem(context, Icons.bar_chart, "Reportes", "/reports"),
                _buildNavItem(context, Icons.settings, "Configuración", "/config"),
              ],
            ),
          ),

          // Botón central flotante
          Positioned(
            top: -15, // Ajuste para que sobresalga
            child: FloatingActionButton(
              heroTag: null, // Desactiva la animación Hero
              onPressed: () {
                _showActionDialog(context); // Mostrar ventana emergente al hacer clic
              },
              shape: const CircleBorder(),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 8,
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            )
          ),
        ],
      ),
    );
  }

  // Mostrar un cuadro de diálogo con dos botones de opción
  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón para agregar actividad
              _buildDialogButton(
                context,
                Icons.add_task,
                "Agregar Actividad",
                const Color.fromARGB(255, 38, 89, 40),
                '/add-activity',
              ),
              const SizedBox(width: 16), // Espacio entre los botones
              // Botón para agregar solo clima
              _buildDialogButton(
                context,
                Icons.cloud,
                "Agregar Solo Clima",
                const Color.fromARGB(255, 35, 129, 41),
                '/add-weather', // Ruta correcta para AddWeatherScreen
                isFromFooter: true, // Pasa la flag extra para saber que es desde el footer
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para crear los botones del cuadro de diálogo
  Widget _buildDialogButton(BuildContext context, IconData icon, String label, Color color, String route, {bool isFromFooter = false}) {
    return ElevatedButton(
      onPressed: () {
        if (route == '/add-weather') {
          context.push(route, extra: {'isFromFooter': isFromFooter}); // Pass extra for weather
        } else {
          context.push(route); // Normal navigation without extra data
        }
        Navigator.pop(context); // Cerrar el diálogo
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Asignar color al botón
        maximumSize: const Size(120, 120), // Botón cuadrado
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordes redondeados
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrar el contenido dentro del botón
        children: [
          Icon(icon, color: Colors.white, size: 36), // Icono encima del texto
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // Widget para los iconos con navegación
  Widget _buildNavItem(BuildContext context, IconData icon, String tooltip, String route) {
    return IconButton(
      onPressed: () {
        context.go(route); // Usa GoRouter para navegar
      },
      icon: Icon(icon, color: Colors.white),
      tooltip: tooltip,
      splashRadius: 25,
    );
  }
}
