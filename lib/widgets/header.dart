// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mspaa/services/api_service.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  Future<void> _logout(BuildContext context) async {
    final ApiService apiService = ApiService();
    await apiService.logout(); // ✅ Llamar a la API de logout

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cerrando sesión...")),
    );

    Future.delayed(const Duration(seconds: 1), () {
      GoRouter.of(context).go('/login'); // ✅ Redirigir al login
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("MSPAA"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
