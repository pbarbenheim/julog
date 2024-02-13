import 'package:flutter/material.dart';

class JulogLogo extends StatelessWidget {
  final double? size;
  const JulogLogo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage("assets/icon/icon.png"),
      semanticLabel: "Julog App-Logo",
      fit: BoxFit.scaleDown,
      filterQuality: FilterQuality.medium,
    );
  }
}
