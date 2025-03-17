// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/services/api_service.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  void _logout(BuildContext context) async {
    // Lógica para cerrar sesión
    final ApiService apiService = ApiService();
    await apiService.logout();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cerrando sesión...")),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        Navigator.pop(context); // Cierra el menú
        GoRouter.of(context).replace('/login'); // Redirige a login
      }
    });
  }

  void _openSideMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.black54),
                ),
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
                        child: Consumer<UsersProvider>(
                          builder: (context, userProvider, child) {
                            final userInfo = userProvider.userData ?? {
                              "uss_nombre": "Cargando...",
                              "uss_email": "Cargando...",
                              "rol": "Cargando..."
                            };

                            return Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    children: [
                                      const CircleAvatar(
                                        radius: 30,
                                        child: Icon(Icons.person, size: 40),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(userInfo["uss_nombre"]!,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text(userInfo["uss_email"]!,
                                          style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                      Text("Rol: ${userInfo["rol"]['rol_desc']!}",
                                          style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                const Divider(),
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
                            );
                          },
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
          _logout(context);
        } else {
          Navigator.pop(context);
          GoRouter.of(context).go(route!);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Llama a fetchUserData para obtener los datos del usuario al abrir el Header
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UsersProvider>(context, listen: false);
      userProvider.fetchUserData(); // Aseguramos que se llame cuando se construye el widget
    });

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
