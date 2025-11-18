import 'package:ecommerce_connect_shop/providers/cart_provider.dart';
import 'package:ecommerce_connect_shop/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar Provider



void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const ConnetShopApp()));
}

class ConnetShopApp extends StatelessWidget {
  const ConnetShopApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9), // Color de fondo 
        useMaterial3: true,
      ),
     home: const HomeScreen(),
    );
  }
}
