import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/screens/forms/edit/edit_username.dart';
import 'package:mspaa/screens/forms/edit/edit_email.dart';
import 'package:mspaa/screens/forms/edit/edit_password.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userInfo = context.watch<UsersProvider>().userData;

    final userRoleId = userInfo?["rol"]?["rol_id"];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Cuenta'),
          _buildListTile(Icons.person, 'Nombre de Usuario', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditUsernameScreen(),
              ),
            );
          }),
          _buildListTile(Icons.email, 'Correo Electrónico', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditEmailScreen(),
              ),
            );
          }),
          _buildListTile(Icons.lock, 'Contraseña', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditPasswordScreen(),
              ),
            );
          }),

          _buildSectionTitle('Sistema'),
          _buildListTile(Icons.notifications, 'Notificaciones', () {}, isDisabled: true),

          if (userRoleId == 1) ...[
            _buildSectionTitle('Seguridad y Auditoría'),
            _buildListTile(Icons.history, 'Reportes de Auditoría', () {}, isDisabled: true),
            _buildListTile(Icons.admin_panel_settings, 'Permisos de Usuarios', () {context.push('/permisos');}),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, {bool isDisabled = false}) {
    return ListTile(
      leading: Icon(icon, color: isDisabled ? Colors.grey : Colors.green),
      title: Text(
        title,
        style: TextStyle(color: isDisabled ? Colors.grey : Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: isDisabled ? null : onTap,
    );
  }
}
