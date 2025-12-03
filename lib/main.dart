import 'package:flutter_connect_shop/providers/auth_provider.dart';
import 'package:flutter_connect_shop/providers/cart_provider.dart';
import 'package:flutter_connect_shop/providers/delivery_address_provider.dart';
import 'package:flutter_connect_shop/providers/orders_provider.dart';
import 'package:flutter_connect_shop/providers/products_provider.dart';
import 'package:flutter_connect_shop/providers/register_provider.dart';
import 'package:flutter_connect_shop/repositories/implementations/auth_repository_impl.dart';
import 'package:flutter_connect_shop/repositories/implementations/user_repository_impl.dart';
import 'package:flutter_connect_shop/screens/home_screen.dart';
import 'package:flutter_connect_shop/screens/login_screen.dart';
import 'package:flutter_connect_shop/screens/orders_screen.dart';
import 'package:flutter_connect_shop/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(const ConnetShopApp());
}

class ConnetShopApp extends StatelessWidget {
  const ConnetShopApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Crear las instancias de servicios y repositorios
    final apiService = ApiService();
    final authRepository = AuthRepositoryImpl(apiService);
    final userRepository = UserRepositoryImpl(apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => RegisterProvider(userRepository)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => DireccionProvider()),
      ],
      child: MaterialApp(
        title: 'Connect Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          scaffoldBackgroundColor: const Color(0xFFF4F6F9), // Color de fondo
          useMaterial3: true,
        ),
        routes: {
          '/orders': (context) => const OrdersScreen(),
        },
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            // Si está autenticado, vamos al Home
            if (auth.isAuthenticated) {
              return const HomeScreen();
            }
            // Si no, intentamos el autologin y mostramos un spinner mientras tanto
            return FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) =>
                  authResultSnapshot.connectionState == ConnectionState.waiting
                      ? const Scaffold(body: Center(child: CircularProgressIndicator())) // Pantalla de carga
                      : const LoginScreen(), // Si el autologin falla, vamos al Login
            );
          },
        ),
      ),
    );
  }
}
