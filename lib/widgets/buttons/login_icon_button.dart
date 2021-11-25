import 'package:flutter/material.dart';

class LoginIconButton extends StatelessWidget {
  final String imageAssetName;
  final String buttonText;
  final Function buttonClicked;

  const LoginIconButton({
    required this.buttonText,
    required this.imageAssetName,
    required this.buttonClicked,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => buttonClicked(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: const BorderRadius.all(Radius.circular(32)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(child: Image.asset(imageAssetName), height: 25, width: 25),
                ),
              ],
            ),
          ),
          Text(buttonText),
        ],
      ),
    );
  }
}
