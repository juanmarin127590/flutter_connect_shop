import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/models/delivery_address.dart';
import 'package:flutter_connect_shop/providers/auth_provider.dart';
import 'package:flutter_connect_shop/providers/cart_provider.dart';
import 'package:flutter_connect_shop/providers/delivery_address_provider.dart';
import 'package:flutter_connect_shop/screens/home_screen.dart';
import 'package:flutter_connect_shop/services/api_service.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key}); 

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late Future _direccionesFuture;
  Direccion? _direccionSeleccionada;
  bool _mostrarFormulario = false;

  // Controladores para el formulario de nueva dirección
  final _nombreDestinatarioController = TextEditingController();
  final _callePrincipalController = TextEditingController();
  final _numeroExteriorController = TextEditingController();
  final _informacionAdicionalController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();
  final _codigoPostalController = TextEditingController();
  final _paisController = TextEditingController();
  bool _esPrincipal = false;

  @override
  void initState() {
    super.initState();
    _direccionesFuture = _cargarDirecciones();
  }

  Future _cargarDirecciones() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      await Provider.of<DireccionProvider>(context, listen: false)
          .fetchDirecciones(token);
    }
  }

  @override
  void dispose() {
    _nombreDestinatarioController.dispose();
    _callePrincipalController.dispose();
    _numeroExteriorController.dispose();
    _informacionAdicionalController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    _codigoPostalController.dispose();
    _paisController.dispose();
    super.dispose();
  }

  Future<void> _guardarNuevaDireccion() async {
    if (!_formKey.currentState!.validate()) return;

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No estás autenticado')),
      );
      return;
    }

    final nuevaDireccion = Direccion(
      nombreDestinatario: _nombreDestinatarioController.text.trim(),
      callePrincipal: _callePrincipalController.text.trim(),
      numeroExterior: _numeroExteriorController.text.trim(),
      informacionAdicional: _informacionAdicionalController.text.trim().isEmpty 
          ? null 
          : _informacionAdicionalController.text.trim(),
      ciudad: _ciudadController.text.trim(),
      estado: _estadoController.text.trim(),
      codigoPostal: _codigoPostalController.text.trim(),
      pais: _paisController.text.trim(),
      principalEnvio: _esPrincipal,
    );

    final direccionProvider = Provider.of<DireccionProvider>(context, listen: false);
    final exito = await direccionProvider.crearDireccion(token, nuevaDireccion);

    if (!mounted) return;

    if (exito) {
      setState(() {
        _mostrarFormulario = false;
        _direccionSeleccionada = direccionProvider.direcciones.last;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dirección guardada exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la dirección')),
      );
    }
  }

  Future<void> _confirmarOrden() async {
    if (_direccionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona o crea una dirección de envío')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No estás autenticado')),
      );
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);

    final orderData = {
      "direccionEnvio": {
        "idDireccion": _direccionSeleccionada!.idDireccion
      },
      "metodoPago": { 
        "idMetodoPago": 1 
      },
      "observacionCliente": "Pedido realizado desde la google app",
      "detalles": cart.cartItems.map((item) => {
        "producto": { 
          "idProducto": item.product.id
        },
        "cantidad": item.quantity,
      }).toList(),
    };
    
    final apiService = ApiService();
    final exito = await apiService.createOrder(token, orderData);

    if (exito) {
      cart.clear();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Pedido Confirmado!'),
          content: const Text('¡Gracias por tu compra! Tu orden ha sido procesada.'),
          actions: [
            TextButton(
              onPressed: () {
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

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: FutureBuilder(
        future: _direccionesFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Consumer<DireccionProvider>(
            builder: (ctx, direccionProvider, child) {
              // Auto-seleccionar dirección principal si existe
              if (_direccionSeleccionada == null && direccionProvider.direccionPrincipal != null) {
                _direccionSeleccionada = direccionProvider.direccionPrincipal;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen del pedido
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
                          const Text("Total a Pagar:", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("\$${cart.totalAmount.toStringAsFixed(2)}", 
                            style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sección de direcciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Dirección de Envío", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (direccionProvider.tieneDirecciones && !_mostrarFormulario)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _mostrarFormulario = true;
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Nueva"),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Mostrar direcciones existentes o formulario
                    if (_mostrarFormulario)
                      _buildFormularioNuevaDireccion()
                    else if (direccionProvider.tieneDirecciones)
                      _buildListaDirecciones(direccionProvider)
                    else
                      _buildSinDirecciones(),

                    const SizedBox(height: 30),

                    // Botón de confirmación
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: cart.itemCount == 0 ? null : _confirmarOrden,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("CONFIRMAR PEDIDO", 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSinDirecciones() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.location_off, size: 60, color: Colors.grey),
            const SizedBox(height: 15),
            const Text("No tienes direcciones guardadas", 
              style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _mostrarFormulario = true;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Agregar Dirección"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaDirecciones(DireccionProvider provider) {
    return Column(
      children: provider.direcciones.map((direccion) {
        final isSelected = _direccionSeleccionada?.idDireccion == direccion.idDireccion;
        
        return Card(
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            leading: Radio<int>(
              value: direccion.idDireccion!,
              groupValue: _direccionSeleccionada?.idDireccion,
              onChanged: (value) {
                setState(() {
                  _direccionSeleccionada = direccion;
                });
              },
            ),
            title: Text(direccion.nombreDestinatario,
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              "${direccion.callePrincipal} ${direccion.numeroExterior}\n"
              "${direccion.ciudad}, ${direccion.estado} ${direccion.codigoPostal}",
            ),
            trailing: direccion.principalEnvio 
              ? const Chip(
                  label: Text("Principal", style: TextStyle(fontSize: 10)),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                )
              : null,
            onTap: () {
              setState(() {
                _direccionSeleccionada = direccion;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFormularioNuevaDireccion() {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nueva Dirección", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _mostrarFormulario = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _nombreDestinatarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del destinatario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _callePrincipalController,
                decoration: const InputDecoration(
                  labelText: 'Calle principal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _numeroExteriorController,
                decoration: const InputDecoration(
                  labelText: 'Número exterior',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _informacionAdicionalController,
                decoration: const InputDecoration(
                  labelText: 'Información adicional (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                  hintText: 'Ej: Apartamento, piso, etc.',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ciudadController,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _estadoController,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codigoPostalController,
                      decoration: const InputDecoration(
                        labelText: 'Código Postal',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _paisController,
                      decoration: const InputDecoration(
                        labelText: 'País',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              CheckboxListTile(
                title: const Text("Establecer como dirección principal"),
                value: _esPrincipal,
                onChanged: (value) {
                  setState(() {
                    _esPrincipal = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardarNuevaDireccion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("GUARDAR DIRECCIÓN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}