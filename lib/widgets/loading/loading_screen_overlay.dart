import 'package:flutter/material.dart';

class LoadingScreenOverlay extends StatelessWidget {
  final String text;

  const LoadingScreenOverlay({this.text = "Mohon Tunggu", Key? key}) : super(key: key);

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      height: (MediaQuery.of(context).size.width * 0.6) / 3,
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 0.9), // the black backdrop
      width: double.infinity,
      child: Center(
        child: _buildLoadingIndicator(context),
      ),
    );
  }
}
