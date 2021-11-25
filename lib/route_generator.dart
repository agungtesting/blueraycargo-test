import 'package:flutter/material.dart';
import 'package:test_blueraycargo/pages/login/login_page.dart';
import 'package:test_blueraycargo/pages/products/products_page.dart';

class RouteGenerator {
  /// to generate route that can be tested.
  /// the widget page can easily be tested in widget testing since we inject the argument through class constructor
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case LoginPage.routeName:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case ProductsPage.routeName:
        return MaterialPageRoute(builder: (_) => const ProductsPage());

      default:
        return _errorRouteGeneration(
          "the route name is not recognized. Probably the route name (${routeSettings.name}) has not been registered in RouteGenerator class",
        );
    }
  }

  static Route<dynamic> _errorRouteGeneration(String message) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error"), centerTitle: true),
        body: const Center(child: Text("Error")),
      );
    });
  }
}
