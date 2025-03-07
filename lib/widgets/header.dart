import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Asegúrate de importar go_router

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("MSPAA"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cerrando sesión...")),
            );
            Future.delayed(const Duration(seconds: 1), () {
              // ignore: use_build_context_synchronously
              context.go('/'); // Redirige a la pantalla de login
            });
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
