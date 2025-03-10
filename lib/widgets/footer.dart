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
            top: -20, // Ajuste para que sobresalga
            child: FloatingActionButton(
              heroTag: null, // 🔹 Desactiva la animación Hero
              onPressed: () {
                context.go('/add-activity');
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

  // 🔹 Widget para los iconos con navegación
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
