import 'package:flutter/material.dart';
import 'package:test_blueraycargo/utilities/constants/assets_name/images/image_assets_name.dart';

class EmptyProductResult extends StatelessWidget {
  final String textMessage;

  EmptyProductResult({required this.textMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              ImageAssetsName.emptyPicture,
              height: MediaQuery.of(context).size.width * 0.25,
              width: MediaQuery.of(context).size.width * 0.25,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              textMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
