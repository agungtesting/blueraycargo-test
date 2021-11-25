import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_blueraycargo/pages/login/login_page.dart';
import 'package:test_blueraycargo/pages/products/products_page.dart';
import 'package:test_blueraycargo/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final bool hasLoggedIn = prefs.getBool("hasLoggedIn") ?? false;

  runApp(
    ProviderScope(
      child: MyApp(hasLoggedIn: hasLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasLoggedIn;

  const MyApp({required this.hasLoggedIn, Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agung Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: hasLoggedIn ? const ProductsPage() : const LoginPage(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
