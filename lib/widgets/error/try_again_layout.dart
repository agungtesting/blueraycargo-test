import 'package:flutter/material.dart';
import 'package:test_blueraycargo/utilities/constants/assets_name/images/image_assets_name.dart';
import 'package:test_blueraycargo/widgets/snackbars/snack_bar_error.dart';
import 'package:after_layout/after_layout.dart';

class TryAgainLayout extends StatefulWidget {
  final Function onButtonClicked;
  final String? errorMessage;
  final bool showBackButton;

  const TryAgainLayout({
    required this.onButtonClicked,
    this.showBackButton = false,
    this.errorMessage,
  });

  @override
  _TryAgainLayoutState createState() => _TryAgainLayoutState();
}

class _TryAgainLayoutState extends State<TryAgainLayout> with AfterLayoutMixin<TryAgainLayout> {
  @override
  void afterFirstLayout(BuildContext context) {
    showErrorSnackBar(
      context,
      content: widget.errorMessage ?? "Terjadi kesalahan, coba lagi",
      title: 'Error',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 2.5 / 1,
                child: SizedBox(
                  child: Image.asset(ImageAssetsName.failedToGetData),
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => widget.onButtonClicked(),
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
        if (widget.showBackButton) const Positioned(top: 16, left: 8, child: SafeArea(child: BackButton())),
      ],
    );
  }
}
