// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mspaa/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  void _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = null;
        _isError = false;
      });

      final success = await _apiService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _message = success
            ? "Hemos enviado un correo con el token de recuperación."
            : "Ocurrió un error al enviar el correo.";
        _isError = !success;
      });

      if (success && mounted) {
        // Esperar un momento antes de redirigir (opcional)
        await Future.delayed(const Duration(seconds: 2));
        // Redirigir con el email como parámetro
        if (context.mounted) {
          GoRouter.of(context).go('/reset-password?email=${_emailController.text.trim()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar contraseña")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Ingresa tu correo electrónico para recibir un token de recuperación.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El campo no puede estar vacío.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _sendResetEmail,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Enviar token"),
                      ),
                const SizedBox(height: 20),
                if (_message != null)
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _isError ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).go('/login');
                  },
                  child: const Text(
                    "Volver al inicio de sesión",
                    style: TextStyle(color: Color.fromARGB(255, 25, 116, 53)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
