import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/users_provider.dart';

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
          _buildListTile(Icons.person, 'Nombre de Usuario', () {}),
          _buildListTile(Icons.email, 'Correo Electrónico', () {}),
          _buildListTile(Icons.lock, 'Contraseña', () {}),

          _buildSectionTitle('Sistema'),
          _buildListTile(Icons.notifications, 'Notificaciones', () {}),

          if (userRoleId == 1) ...[
            _buildSectionTitle('Seguridad y Auditoría'),
            _buildListTile(Icons.history, 'Reportes de Auditoría', () {}),
            _buildListTile(Icons.admin_panel_settings, 'Permisos de Usuarios', () {}),
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

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
