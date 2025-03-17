import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Configuración de Actividades Agrícolas'),
          _buildListTile(Icons.agriculture, 'Tipos de Cultivo', 'Personalizar cultivos', () {}),
          _buildListTile(Icons.local_florist, 'Variedades de Cultivo', 'Configurar variedades específicas', () {}),
          _buildListTile(Icons.inventory, 'Insumos', 'Administrar insumos utilizados', () {}),
          _buildListTile(Icons.map, 'Lotes', 'Definir áreas de producción', () {}),
          
          _buildSectionTitle('Gestión de Usuarios y Permisos'),
          _buildListTile(Icons.people, 'Administrar Usuarios', 'Gestionar accesos', () {}),
          _buildListTile(Icons.lock, 'Permisos', 'Configurar privilegios', () {}),
          
          _buildSectionTitle('Información del Usuario'),
          _buildListTile(Icons.person, 'Nombre de Usuario', 'Modificar nombre de usuario', () {}),
          _buildListTile(Icons.email, 'Correo Electrónico', 'Actualizar email', () {}),
          _buildListTile(Icons.lock, 'Contraseña', 'Cambiar contraseña', () {}),
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

  Widget _buildListTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}