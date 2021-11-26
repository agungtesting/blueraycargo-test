import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_blueraycargo/pages/login/login_page.dart';
import 'package:test_blueraycargo/pages/products/products_page_controller.dart';
import 'package:test_blueraycargo/shared_providers/product_list_controller_provider.dart';
import 'package:test_blueraycargo/utilities/constants/assets_name/images/image_assets_name.dart';
import 'package:test_blueraycargo/widgets/lists/available_product_list.dart';
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
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // if reach bottom of list view then try to get more data
        final availableProductsController = ref.read(availableProductListControllerProvider);
        availableProductsController.performInfiniteScrolling();
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      // force to get available products for the first time
      final controller = ref.read(availableProductListControllerProvider);

      controller.checkIfHasExceededTheTimeLimit();
      controller.getItems();
    });
    super.initState();
  }

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
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _form,
                    child: _MainLayout(formKey: _form, scrollController: _scrollController),
                  ),
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
  final ScrollController scrollController;
  final _productNameTextController = TextEditingController();
  final _productQuantityTextController = TextEditingController();

  _MainLayout({
    required this.formKey,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    final pageController = ref.watch(productsPageControllerProvider);
    final availableProductListController = ref.watch(availableProductListControllerProvider);

    final isEditing = pageController.isEditing;

    _productNameTextController.text = pageController.selectedProductName;
    _productQuantityTextController.text = (pageController.selectedProductQuantity == 0 && !isEditing) ? "" : pageController.selectedProductQuantity.toString();
    _productQuantityTextController.selection = TextSelection.fromPosition(TextPosition(offset: _productQuantityTextController.text.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextTag(isEditing ? "Edit Gambar Produk" : "Gambar Produk", isEditing),
        const SizedBox(height: 8),
        Center(child: _ProductImage()),
        const SizedBox(height: 16),
        _buildTextTag(isEditing ? "Edit Nama Produk" : "Nama Produk", isEditing),
        TextFormField(
          controller: _productNameTextController,
          autofocus: false,
          autocorrect: false,
          maxLines: 1,
          maxLength: 1000,
          onChanged: (value) => pageController.selectedProductName = value,
          validator: (value) => pageController.validateTitle(),
          decoration: InputDecoration(
            counterText: "", // to hide the counter
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isEditing ? Colors.orange : Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildTextTag(isEditing ? "Edit Jumlah Produk" : "Jumlah Produk", isEditing),
        TextFormField(
          controller: _productQuantityTextController,
          autofocus: false,
          autocorrect: false,
          maxLines: 1,
          keyboardType: TextInputType.number,
          onChanged: (value) => pageController.updateSelectedProductQuantity(value),
          decoration: InputDecoration(
            counterText: "", // to hide the counter
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isEditing ? Colors.orange : Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: () => _mainButtonClicked(pageController, context, formKey, isEditing),
            child: Text(isEditing ? "Edit Produk" : "Simpan Produk"),
            style: ElevatedButton.styleFrom(primary: isEditing ? Colors.orange : Colors.blue),
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
        const SizedBox(height: 16),
        AvailableProductList(
          onEditClicked: (productId) => _onEditButtonHandler(productId, scrollController, pageController),
          onDeleteClicked: (productID) => _onDeleteButtonHandler(productID, pageController, context, availableProductListController),
        ),
      ],
    );
  }

  Widget _buildTextTag(String text, bool isEditing) {
    return Text(
      text,
      style: TextStyle(
        color: isEditing ? Colors.orange : Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _onEditButtonHandler(String productId, ScrollController scrollController, ProductsPageController pageController) {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );

    pageController.performEditingAction(productId);
  }

  void _onDeleteButtonHandler(
    String productId,
    ProductsPageController pageController,
    BuildContext context,
    AvailableProductListController availableProductListController,
  ) async {
    final hasConnectivity = await pageController.hasConnectivity();
    if (!hasConnectivity) {
      showErrorSnackBar(context, content: "Tidak ada koneksi internet.");
      return;
    }

    try {
      await pageController.deleteProductFromServer(productId);
      showSnackBarInfo(context, content: "Produk Berhasil Dihapus!");
      availableProductListController.removeAnItemFromList(productId);
    } catch (error) {
      showErrorSnackBar(context, content: error.toString());
    }
  }

  void _mainButtonClicked(ProductsPageController pageController, BuildContext context, GlobalKey<FormState> form, bool isEditing) async {
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
      if (isEditing) {
        await pageController.editProductInServer();
        showSnackBarInfo(context, content: "Produk Berhasil DiEdit!");
      } else {
        await pageController.uploadProductToServer();
        showSnackBarInfo(context, content: "Produk Berhasil Disimpan!");
      }
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
    if (pageController.isEditing && pageController.productImageFile != null) {
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
    } else if (pageController.isEditing) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaY: 4, sigmaX: 4),
            child: CachedNetworkImage(
              imageUrl: pageController.editedImageURL,
              fadeInCurve: Curves.easeIn,
              fadeInDuration: const Duration(milliseconds: 300),
              fit: BoxFit.fill,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          CachedNetworkImage(
            imageUrl: pageController.editedImageURL,
            fadeInCurve: Curves.easeIn,
            fadeInDuration: const Duration(milliseconds: 300),
          ),
        ],
      );
    } else if (pageController.productImageFile == null) {
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
