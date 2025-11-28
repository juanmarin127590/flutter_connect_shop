import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/providers/auth_provider.dart';
import 'package:flutter_connect_shop/providers/cart_provider.dart';
import 'package:flutter_connect_shop/screens/home_screen.dart';
import 'package:flutter_connect_shop/services/api_service.dart';
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

  void _confirmarOrden() async {
    // Aquí se procesaría la orden
    if (_formKey.currentState!.validate()) {
      // 1. Obtener el token del usuario logueado
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No estás autenticado. Por favor inicia sesión.')),
        );
        return;
      }

      // preparar datos de la orden
      final cart = Provider.of<CartProvider>(context, listen: false);

      // 2. Crear el request de laorden en el servidor (para prueba usaremos IDs hardcodeados (fijos))
      final orderData = {
        "direccionEnvio": {
          "idDireccion": 3
          },
        "metodoPago": { 
            "idMetodoPago": 1 
        },
        "observacionCliente": "Por favor, entregar en portería.", 
        "detalles": cart.cartItems.map((item) => {
          "producto": { 
            "idProducto": item.product.id
            },
          "cantidad": item.quantity,
          //"precioUnitario": item.product.price
        }).toList(),
        //"montoTotal": cart.totalAmount
      };
      
      // 3. Enviar al Backend
      final apiService = ApiService();
      final exito = await apiService.createOrder(token, orderData);

      if (exito) {
        cart.clear(); // Limpiamos carrito local
        if (!mounted) return;

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
    } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar el pedido. Intenta nuevamente.')),
        );
      }
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
                    Text("\$${cart.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
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