import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/screens/home_screen.dart';
import 'package:flutter_connect_shop/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitRegister() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('¡Registro exitoso!')));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', height: 100),
                    const SizedBox(height: 40),
                    // Campo Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        hintText: 'Ingresa tu nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo Apellido
                     TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        hintText: 'Ingresa tu apellido',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo Email
                    TextFormField(
                      autofocus: true,
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        hintText: 'Ingresa tu correo electrónico',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo electrónico';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Por favor ingresa un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo Confirmar Contraseña
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor confirma tu contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Botón de Acción
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          "REGISTRARSE",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


@override
void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

}


