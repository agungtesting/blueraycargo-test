import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_blueraycargo/pages/login/login_page_controller.dart';
import 'package:test_blueraycargo/pages/products/products_page.dart';
import 'package:test_blueraycargo/utilities/constants/assets_name/images/image_assets_name.dart';
import 'package:test_blueraycargo/widgets/buttons/login_icon_button.dart';
import 'package:test_blueraycargo/widgets/snackbars/snack_bar_error.dart';

class LoginPage extends ConsumerWidget {
  static const routeName = "/login-page";

  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = ref.watch(loginPageControllerProvider);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoogleLoginButton(),
          const SizedBox(height: 32),
          if (pageController.isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class _GoogleLoginButton extends ConsumerWidget {
  @override
  Widget build(context, ref) {
    final pageController = ref.watch(loginPageControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LoginIconButton(
        buttonText: 'Masuk dengan Google',
        imageAssetName: ImageAssetsName.google,
        buttonClicked: () => _performLoginUsingGoogle(context, pageController),
      ),
    );
  }

  void _performLoginUsingGoogle(BuildContext context, LoginPageController pageController) async {
    final hasConnectivity = await pageController.hasConnectivity();
    if (!hasConnectivity) {
      showErrorSnackBar(context, content: "Tidak ada koneksi internet.");
      return;
    }

    final hasLoggedInSuccessfully = await pageController.signInWithGoogle();

    if (pageController.errorMessage != null) {
      showErrorSnackBar(context, content: pageController.errorMessage!);
      return;
    }

    if (hasLoggedInSuccessfully) {
      Navigator.of(context).pushReplacementNamed(ProductsPage.routeName);
    }
  }
}
