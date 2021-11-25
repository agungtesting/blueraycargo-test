import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_blueraycargo/pages/login/login_page.dart';
import 'package:test_blueraycargo/pages/products/products_page_controller.dart';
import 'package:test_blueraycargo/utilities/constants/assets_name/images/image_assets_name.dart';
import 'package:test_blueraycargo/widgets/loading/loading_screen_overlay.dart';
import 'package:test_blueraycargo/widgets/snackbars/snack_bar_error.dart';
import 'package:test_blueraycargo/widgets/snackbars/snack_bar_info.dart';

class ProductsPage extends ConsumerStatefulWidget {
  static const routeName = "/products-page";

  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(productsPageControllerProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Agung Test"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logOutIconClicked(pageController, context),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // to hide keyboard when tap outside textfield
        child: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _form,
                    child: _MainLayout(formKey: _form),
                  ),
                ),
                if (pageController.isLoading)
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const LoadingScreenOverlay(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logOutIconClicked(ProductsPageController pageController, BuildContext context) async {
    final connectedToTheInternet = await pageController.hasConnectivity();
    if (!connectedToTheInternet) {
      showErrorSnackBar(context, content: "Gagal Keluar, tidak ada koneksi Internet.");
      return;
    }

    Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
    pageController.performLogOut();
  }
}

class _MainLayout extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final _productNameTextController = TextEditingController();
  final _productQuantityTextController = TextEditingController();

  _MainLayout({required this.formKey, Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final pageController = ref.watch(productsPageControllerProvider);
    _productNameTextController.text = pageController.selectedProductName;
    _productQuantityTextController.text = (pageController.selectedProductQuantity == 0) ? "" : pageController.selectedProductQuantity.toString();
    _productQuantityTextController.selection = TextSelection.fromPosition(TextPosition(offset: _productQuantityTextController.text.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextTag("Gambar Produk"),
        const SizedBox(height: 8),
        Center(child: _ProductImage()),
        const SizedBox(height: 16),
        _buildTextTag("Nama Produk"),
        TextFormField(
          controller: _productNameTextController,
          autofocus: false,
          autocorrect: false,
          maxLines: 1,
          maxLength: 1000,
          onChanged: (value) => pageController.selectedProductName = value,
          validator: (value) => pageController.validateTitle(),
          decoration: const InputDecoration(
            counterText: "", // to hide the counter
          ),
        ),
        const SizedBox(height: 32),
        _buildTextTag("Jumlah Produk"),
        TextFormField(
          controller: _productQuantityTextController,
          autofocus: false,
          autocorrect: false,
          maxLines: 1,
          keyboardType: TextInputType.number,
          onChanged: (value) => pageController.updateSelectedProductQuantity(value),
          decoration: const InputDecoration(
            counterText: "", // to hide the counter
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: () => _submitButtonClicked(pageController, context, formKey),
            child: const Text("Simpan Produk"),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Daftar Produk",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildTextTag(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
    );
  }

  void _submitButtonClicked(ProductsPageController pageController, BuildContext context, GlobalKey<FormState> form) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    final productImageError = pageController.validateProductImage();
    if (productImageError != null) {
      showErrorSnackBar(context, content: productImageError);
      return;
    }

    final inputIsValid = form.currentState!.validate();
    if (!inputIsValid) return;

    final hasConnectivity = await pageController.hasConnectivity();
    if (!hasConnectivity) {
      showErrorSnackBar(context, content: "Tidak ada koneksi internet.");
      return;
    }

    try {
      await pageController.uploadProductToServer();
      showSnackBarInfo(context, content: "Produk Berhasil Dikirim ke Server!");
    } catch (error) {
      showErrorSnackBar(context, content: error.toString());
    }
  }
}

class _ProductImage extends ConsumerWidget {
  @override
  Widget build(context, ref) {
    final pageController = ref.watch(productsPageControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _onPickImageButtonClicked(pageController, context),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          height: screenWidth * 0.75,
          width: screenWidth * 0.75,
          child: _buildImage(pageController),
        ),
      ),
    );
  }

  Widget _buildImage(ProductsPageController pageController) {
    if (pageController.productImageFile == null) {
      return Image.asset(ImageAssetsName.emptyPicture);
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaY: 4, sigmaX: 4),
            child: Image.file(
              pageController.productImageFile!,
              fit: BoxFit.fill,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Image.file(pageController.productImageFile!),
        ],
      );
    }
  }

  void _onPickImageButtonClicked(ProductsPageController pageController, BuildContext context) async {
    if (pageController.isLoading) return;

    try {
      await pageController.pickAndProcessTheImage(context);
    } catch (error) {
      showErrorSnackBar(context, content: error.toString());
    }
  }
}
