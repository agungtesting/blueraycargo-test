import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, {String? title, required String content, int durationInSeconds = 4}) {
  showFlash(
    context: context,
    duration: Duration(seconds: durationInSeconds),
    builder: (context, controller) {
      return Flash.bar(
        key: const Key("ErrorSnackBar"),
        controller: controller,
        backgroundGradient: LinearGradient(
          colors: [Colors.red, Theme.of(context).colorScheme.error],
        ),
        position: FlashPosition.bottom,
        horizontalDismissDirection: HorizontalDismissDirection.startToEnd,
        margin: const EdgeInsets.all(8),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.slowMiddle,
        child: FlashBar(
          title: (title != null) ? Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)) : null,
          content: Text(content, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      );
    },
  );
}
