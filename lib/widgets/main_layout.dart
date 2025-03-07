import 'package:flutter/material.dart';
import 'package:mspaa/widgets/header.dart';
import 'package:mspaa/widgets/footer.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // Widget que cambiará

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: child, // Permite que el contenido se expanda y no desaparezca
            ),
            const SizedBox(height: 16), // Espacio para evitar que el contenido quede oculto tras el footer
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
