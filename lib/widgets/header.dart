// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/services/api_service.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  void _logout(BuildContext context) async {
    // Mostrar mensaje de logout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cerrando sesión...")),
    );

    // Llamamos a la función logout del API
    final ApiService apiService = ApiService();
    await apiService.logout();

    // Usamos addPostFrameCallback para asegurarnos de que la redirección se ejecute después de cerrar sesión
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final currentLocation = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

        // Asegurarse de que no estemos ya en la pantalla de login
        if (currentLocation != '/login') {
          GoRouter.of(context).replace('/login'); // Usar replace para evitar que el usuario pueda volver atrás
        }
      }
    });

    // Cierra el menú lateral si está abierto
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
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

                            final userName = userInfo["uss_nombre"] ?? "Nombre no disponible";
                            final userEmail = userInfo["uss_email"] ?? "Email no disponible";
                            final userRole = userInfo["rol"]?["rol_desc"] ?? "Rol no disponible";

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
                                      Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text(userEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                      Text("Rol: $userRole", style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                                      _buildMenuItem(context, Icons.assignment, "Actividades", "/actividades"),
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
      title: const Text("SCDAA"),
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
