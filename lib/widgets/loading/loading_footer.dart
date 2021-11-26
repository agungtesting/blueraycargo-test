import 'package:flutter/material.dart';

class LoadingFooter extends StatelessWidget {
  const LoadingFooter({Key key = const ValueKey("loading footer")}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 60,
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
