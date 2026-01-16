import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

class JulogLogo extends StatelessWidget {
  const JulogLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const VectorGraphic(
      loader: AssetBytesLoader('assets/logo.svg'),
      width: 64,
      height: 64,
    );
  }
}
