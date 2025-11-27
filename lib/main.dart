import 'package:flutter_connect_shop/providers/auth_provider.dart';
import 'package:flutter_connect_shop/providers/cart_provider.dart';
import 'package:flutter_connect_shop/providers/products_provider.dart';
import 'package:flutter_connect_shop/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  /*
  // PRUEBA DE CONEXIÓN (Borrar después)
  print("--- INTENTANDO CONECTAR A LA API ---");
  try {
    final api = ApiService();
    final products = await api.getProducts(); 
    print("Conexión Exitosa: Se encontraron ${products.length} productos");
    // Nota: Descomenta las lineas de arriba cuando tu servidor Java esté corriendo
  } catch (e) {
    print("Error conectando: $e");
  }
  */

  runApp(const ConnetShopApp());
}

class ConnetShopApp extends StatelessWidget {
  const ConnetShopApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Connect Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          scaffoldBackgroundColor: const Color(0xFFF4F6F9), // Color de fondo
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
