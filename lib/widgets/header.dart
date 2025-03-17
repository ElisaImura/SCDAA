import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mspaa/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "nombre": prefs.getString("user_name") ?? "Usuario",
      "email": prefs.getString("user_email") ?? "correo@example.com",
      "rol": prefs.getString("user_role") ?? "Desconocido",
    };
  }

  void _logout(BuildContext context) async {
    final ApiService apiService = ApiService();
    await apiService.logout(); // ✅ Logout FIRST

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cerrando sesión...")),
    );

    // ✅ Delay before closing the menu
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        Navigator.pop(context); // ✅ THEN close menu safely
        GoRouter.of(context).replace('/login'); // ✅ Use replace() for safe navigation
      }
    });
  }

  void _openSideMenu(BuildContext context) async {
    final userInfo = await _getUserInfo();

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Stack(
              children: [
                // Fondo semitransparente
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.black54),
                ),

                // Menú Lateral
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(MediaQuery.of(context).size.width * (1 - animation.value), 0),
                      child: child,
                    );
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      elevation: 10,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                        ),
                        child: Column(
                          children: [
                            // Botón de cerrar
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 30),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),

                            // Información del Usuario
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  const CircleAvatar(
                                    radius: 30,
                                    child: Icon(Icons.person, size: 40),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(userInfo["nombre"]!,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(userInfo["email"]!,
                                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                  Text("Rol: ${userInfo["rol"]!}",
                                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                            ),

                            const Divider(),

                            // Opciones de Navegación
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                children: [
                                  _buildMenuItem(context, Icons.timeline, "Ciclos", "/ciclos"),
                                  _buildMenuItem(context, Icons.grass, "Insumos", "/insumos"),
                                  _buildMenuItem(context, Icons.location_on, "Lotes", "/lotes"),
                                  _buildMenuItem(context, Icons.people, "Usuarios", "/usuarios"),
                                  _buildMenuItem(context, Icons.eco, "Cultivos y Variedades", "/cultivos"),
                                  const Divider(),
                                  _buildMenuItem(context, Icons.logout, "Cerrar sesión", null, logout: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String? route, {bool logout = false}) {
    return ListTile(
      leading: Icon(icon, color: logout ? Colors.red : Theme.of(context).primaryColor),
      title: Text(title),
      onTap: () {
        if (logout) {
          _logout(context); // ✅ Perform logout first
        } else {
          Navigator.pop(context); // ✅ Close menu before navigating
          GoRouter.of(context).go(route!);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("MSPAA"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _openSideMenu(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
