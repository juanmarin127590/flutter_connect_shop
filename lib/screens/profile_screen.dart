import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_connect_shop/providers/auth_provider.dart';
import 'package:flutter_connect_shop/screens/login_screen.dart';
import 'package:flutter_connect_shop/screens/admin/admin_products_screen.dart';
import 'package:flutter_connect_shop/screens/admin/admin_orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFFF4F6F9),
        elevation: 1,
      ),
      body: isAuthenticated
          ? _buildProfileContent(context, authProvider)
          : _buildNotAuthenticatedContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthProvider authProvider) {
    // Verificar si el usuario tiene rol de ADMINISTRADOR
    final isAdmin = authProvider.isAdmin;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header del perfil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isAdmin ? Colors.purple.shade200 : Colors.orange.shade200,
                  isAdmin ? Colors.purple.shade400 : Colors.orange.shade400,
                  isAdmin ? Colors.purple.shade600 : Colors.orange.shade600,
                ],
              ),
            ),
            child: Column(
              children: [
                // Avatar con elevación
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      size: 60,
                      color: isAdmin
                          ? Colors.purple.shade600
                          : Colors.orange.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Información del usuario con sombra
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Usuario Conectado',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Badge de sesión activa con elevación y animación
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isAdmin
                            ? Colors.purple.shade400
                            : Colors.green.shade400,
                        isAdmin
                            ? Colors.purple.shade600
                            : Colors.green.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isAdmin ? Colors.purple : Colors.green)
                            .withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAdmin ? 'Administrador' : 'Sesión activa',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SECCIÓN DE ADMINISTRADOR (Solo visible si el usuario es admin)
          if (isAdmin) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: Colors.purple.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Panel de Administración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
            ),

            _buildProfileOption(
              icon: Icons.inventory_2_outlined,
              title: 'Gestión de Productos',
              subtitle: 'Crear, modificar o eliminar productos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminProductsScreen(),
                  ),
                );
              },
            ),

            _buildProfileOption(
              icon: Icons.receipt_long_outlined,
              title: 'Gestión de Pedidos',
              subtitle: 'Ver todos los pedidos y actualizar estados',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
                );
              },
            ),

            const Divider(height: 32, thickness: 1),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mi Cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Opciones del perfil
          _buildProfileOption(
            icon: Icons.person_outline,
            title: 'Información Personal',
            subtitle: 'Gestiona tu información de perfil',
            onTap: () {
              // TODO: Implementar pantalla de edición de perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función próximamente disponible'),
                ),
              );
            },
          ),

          _buildProfileOption(
            icon: Icons.location_on_outlined,
            title: 'Direcciones',
            subtitle: 'Gestiona tus direcciones de envío',
            onTap: () {
              // TODO: Ya existe la pantalla de direcciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función próximamente disponible'),
                ),
              );
            },
          ),

          _buildProfileOption(
            icon: Icons.shopping_bag_outlined,
            title: 'Mis Pedidos',
            subtitle: 'Ver historial de pedidos',
            onTap: () {
              Navigator.pushNamed(context, '/orders');
            },
          ),

          _buildProfileOption(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Configura tus preferencias',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función próximamente disponible'),
                ),
              );
            },
          ),

          _buildProfileOption(
            icon: Icons.security_outlined,
            title: 'Seguridad',
            subtitle: 'Cambia tu contraseña',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función próximamente disponible'),
                ),
              );
            },
          ),

          _buildProfileOption(
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            subtitle: '¿Necesitas ayuda?',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función próximamente disponible'),
                ),
              );
            },
          ),

          const Divider(height: 32, thickness: 1),

          // Botón de cerrar sesión
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, authProvider),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Información de la versión
          Text(
            'Connect Shop v1.0.0',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNotAuthenticatedContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'No has iniciado sesión',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Inicia sesión para acceder a tu perfil y realizar pedidos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.orange.shade600),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Cerrar el diálogo
                Navigator.of(ctx).pop();

                // Realizar el logout
                await authProvider.logout();

                // Mostrar mensaje de confirmación
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Regresar a la pantalla anterior (Home)
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
