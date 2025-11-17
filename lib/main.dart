import 'package:ecommerce_connect_shop/providers/cart_provider.dart';
import 'package:ecommerce_connect_shop/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // This line is already correct, no change needed.


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const ConnectShopApp()));
}

class ConnetShopAppp extends StatelessWidget {
  const ConnetShopAppp({super.key});

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

