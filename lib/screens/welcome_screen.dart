import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // 🔹 Diseño ondulado en la parte superior e inferior
          Positioned(top: 0, left: 0, right: 0, child: _buildWaveTop()),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildWaveBottom()),

          // 🔹 Contenido centrado
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Bienvenido a MSPAA",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 42, 122, 48),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Onda en la parte superior
  Widget _buildWaveTop() {
    return SizedBox(
      height: 120,
      child: ClipPath(
        clipper: TopWaveClipper(),
        // ignore: deprecated_member_use
        child: Container(color: const Color.fromARGB(255, 70, 146, 73).withOpacity(0.8)),
      ),
    );
  }

  // 🔹 Onda en la parte inferior
  Widget _buildWaveBottom() {
    return SizedBox(
      height: 150,
      child: ClipPath(
        clipper: BottomWaveClipper(),
        // ignore: deprecated_member_use
        child: Container(color: const Color.fromARGB(255, 64, 123, 67).withOpacity(0.9)),
      ),
    );
  }
}

// 🔹 Clip para la onda superior
class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height - 20);
    path.quadraticBezierTo(3 * size.width / 4, size.height - 50, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// 🔹 Clip para la onda inferior
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width / 4, 0, size.width / 2, 20);
    path.quadraticBezierTo(3 * size.width / 4, 50, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
