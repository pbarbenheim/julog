import 'package:flutter/material.dart';

class DienstbuchLogo extends StatelessWidget {
  final double? size;
  const DienstbuchLogo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage("assets/icon/icon.png"),
      semanticLabel: "Dienstbuch App-Logo",
      fit: BoxFit.scaleDown,
      filterQuality: FilterQuality.medium,
    );
  }
}
