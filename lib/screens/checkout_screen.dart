import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/providers/cart_provider.dart';
import 'package:flutter_connect_shop/screens/home_screen.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key}); 

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState(); //
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los datos de envío
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    // Limpiar los controladores cuando el widget se elimine
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _confirmarOrden() {
    // Aquí se procesaría la orden
    if (_formKey.currentState!.validate()) {
      // 1. Aquí iría la lógica para enviar el pedido a tu Backend (Spring Boot)

      // 2. Limpiar el carrito (si tienes un carrito implementado)
      Provider.of<CartProvider>(context, listen: false).clear();
      
      // 3. Mostrar una confirmación al usuario
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Pedido Confirmado!'),
          content: const Text('¡Gracias por tu compra! Tu orden ha sido procesada.'),
          actions: [
            TextButton(
              onPressed: () {
               // Cerrar diálogo y volver al Home, borrando el historial para no volver al checkout
                Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('VOLVER A LA TIENDA'),
            ),
          ],
        ),
      );
    }
  }


 @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Datos de Envío")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen rápido
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total a Pagar:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("\$${cart.totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              const Text("Información de Entrega", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // Campos del Formulario
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección de Entrega', border: OutlineInputBorder(), prefixIcon: Icon(Icons.home)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo para confirmación', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? 'Email inválido' : null,
              ),
              
              const SizedBox(height: 30),

              // Botón de Confirmación
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: cart.itemCount == 0 ? null : _confirmarOrden, // Deshabilitar si carrito vacío
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("CONFIRMAR PEDIDO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}