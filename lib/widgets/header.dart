// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  Future<void> _logout(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cerrando sesión...')),
    );

    final api = context.read<ApiService>();

    try {
      await api.logout();
    } catch (_) {
      
    }

    // limpia token local
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    // 1) marca estado auth como logged out
    context.read<AuthNotifier>().setLoggedIn(false);

    // 2) cierra el overlay del menú
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // cierra la PageRouteBuilder del menú
    }
    // 3) navega a welcome (si no lo hizo ya el redirect de GoRouter)
    if (context.mounted) {
      context.go('/');
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
                      offset: Offset(
                        MediaQuery.of(context).size.width * (1 - animation.value),
                        0,
                      ),
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
                              "email": "Cargando...",
                              "rol": "Cargando..."
                            };

                            final userName = userInfo["uss_nombre"] ?? "Nombre no disponible";
                            final userEmail = userInfo["email"] ?? "Email no disponible";
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
                                      const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
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

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String? route, {
    bool logout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: logout ? Colors.red : Theme.of(context).primaryColor),
      title: Text(title),
      onTap: () async {
        if (logout) {
          await _logout(context);
          return;
        }
        // Cierra el overlay del menú antes de navegar
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        if (route != null && route.isNotEmpty) {
          context.go(route); // usa push() si quieres una subpágina apilada
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // refresca datos del usuario al montar el Header
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UsersProvider>();
      userProvider.fetchUserData();
    });

    return AppBar(
      title: const Text("SCDAA"),
      automaticallyImplyLeading: false,
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
