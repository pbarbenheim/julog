import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff0e6681),
      surfaceTint: Color(0xff0e6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffbbe9ff),
      onPrimaryContainer: Color(0xff004d63),
      secondary: Color(0xff4c616b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcfe6f2),
      onSecondaryContainer: Color(0xff354a53),
      tertiary: Color(0xff5c5b7d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe2dfff),
      onTertiaryContainer: Color(0xff444364),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fafd),
      onSurface: Color(0xff171c1f),
      onSurfaceVariant: Color(0xff40484c),
      outline: Color(0xff70787d),
      outlineVariant: Color(0xffc0c8cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8ad0ee),
      primaryFixed: Color(0xffbbe9ff),
      onPrimaryFixed: Color(0xff001f29),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff004d63),
      secondaryFixed: Color(0xffcfe6f2),
      onSecondaryFixed: Color(0xff081e27),
      secondaryFixedDim: Color(0xffb4cad5),
      onSecondaryFixedVariant: Color(0xff354a53),
      tertiaryFixed: Color(0xffe2dfff),
      onTertiaryFixed: Color(0xff191837),
      tertiaryFixedDim: Color(0xffc5c3ea),
      onTertiaryFixedVariant: Color(0xff444364),
      surfaceDim: Color(0xffd6dbde),
      surfaceBright: Color(0xfff5fafd),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffeaeef2),
      surfaceContainerHigh: Color(0xffe4e9ec),
      surfaceContainerHighest: Color(0xffdee3e6),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003b4d),
      surfaceTint: Color(0xff0e6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff287590),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff243942),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5b707a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff343353),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6b6a8d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafd),
      onSurface: Color(0xff0d1214),
      onSurfaceVariant: Color(0xff2f373b),
      outline: Color(0xff4c5458),
      outlineVariant: Color(0xff666e73),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8ad0ee),
      primaryFixed: Color(0xff287590),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff005c76),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5b707a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff435861),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6b6a8d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff525173),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c7ca),
      surfaceBright: Color(0xfff5fafd),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffe4e9ec),
      surfaceContainerHigh: Color(0xffd9dde1),
      surfaceContainerHighest: Color(0xffcdd2d6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00313f),
      surfaceTint: Color(0xff0e6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff005066),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1a2f38),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff374c56),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff292948),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff474667),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafd),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252d31),
      outlineVariant: Color(0xff424a4e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8ad0ee),
      primaryFixed: Color(0xff005066),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003848),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff374c56),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff21353e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff474667),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff302f4f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb5b9bd),
      surfaceBright: Color(0xfff5fafd),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffedf1f5),
      surfaceContainer: Color(0xffdee3e6),
      surfaceContainerHigh: Color(0xffd0d5d8),
      surfaceContainerHighest: Color(0xffc2c7ca),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8ad0ee),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff003545),
      primaryContainer: Color(0xff004d63),
      onPrimaryContainer: Color(0xffbbe9ff),
      secondary: Color(0xffb4cad5),
      onSecondary: Color(0xff1e333c),
      secondaryContainer: Color(0xff354a53),
      onSecondaryContainer: Color(0xffcfe6f2),
      tertiary: Color(0xffc5c3ea),
      onTertiary: Color(0xff2e2d4d),
      tertiaryContainer: Color(0xff444364),
      onTertiaryContainer: Color(0xffe2dfff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffdee3e6),
      onSurfaceVariant: Color(0xffc0c8cc),
      outline: Color(0xff8a9296),
      outlineVariant: Color(0xff40484c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e6),
      inversePrimary: Color(0xff0e6681),
      primaryFixed: Color(0xffbbe9ff),
      onPrimaryFixed: Color(0xff001f29),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff004d63),
      secondaryFixed: Color(0xffcfe6f2),
      onSecondaryFixed: Color(0xff081e27),
      secondaryFixedDim: Color(0xffb4cad5),
      onSecondaryFixedVariant: Color(0xff354a53),
      tertiaryFixed: Color(0xffe2dfff),
      onTertiaryFixed: Color(0xff191837),
      tertiaryFixedDim: Color(0xffc5c3ea),
      onTertiaryFixedVariant: Color(0xff444364),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff353a3d),
      surfaceContainerLowest: Color(0xff0a0f11),
      surfaceContainerLow: Color(0xff171c1f),
      surfaceContainer: Color(0xff1b2023),
      surfaceContainerHigh: Color(0xff262b2d),
      surfaceContainerHighest: Color(0xff303638),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffabe5ff),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff002a37),
      primaryContainer: Color(0xff529ab6),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc9e0eb),
      onSecondary: Color(0xff132831),
      secondaryContainer: Color(0xff7e949f),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffdbd9ff),
      onTertiary: Color(0xff232241),
      tertiaryContainer: Color(0xff8f8db2),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd6dde2),
      outline: Color(0xffabb3b8),
      outlineVariant: Color(0xff899196),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e6),
      inversePrimary: Color(0xff004e64),
      primaryFixed: Color(0xffbbe9ff),
      onPrimaryFixed: Color(0xff00131b),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff003b4d),
      secondaryFixed: Color(0xffcfe6f2),
      onSecondaryFixed: Color(0xff00131b),
      secondaryFixedDim: Color(0xffb4cad5),
      onSecondaryFixedVariant: Color(0xff243942),
      tertiaryFixed: Color(0xffe2dfff),
      onTertiaryFixed: Color(0xff0e0d2c),
      tertiaryFixedDim: Color(0xffc5c3ea),
      onTertiaryFixedVariant: Color(0xff343353),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff404548),
      surfaceContainerLowest: Color(0xff04080a),
      surfaceContainerLow: Color(0xff191e21),
      surfaceContainer: Color(0xff23292b),
      surfaceContainerHigh: Color(0xff2e3336),
      surfaceContainerHighest: Color(0xff393e41),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffddf3ff),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff86ccea),
      onPrimaryContainer: Color(0xff000d14),
      secondary: Color(0xffddf3ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffb0c6d1),
      onSecondaryContainer: Color(0xff000d14),
      tertiary: Color(0xfff1eeff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc1bfe6),
      onTertiaryContainer: Color(0xff080726),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe9f1f6),
      outlineVariant: Color(0xffbcc4c9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e6),
      inversePrimary: Color(0xff004e64),
      primaryFixed: Color(0xffbbe9ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff00131b),
      secondaryFixed: Color(0xffcfe6f2),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb4cad5),
      onSecondaryFixedVariant: Color(0xff00131b),
      tertiaryFixed: Color(0xffe2dfff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffc5c3ea),
      onTertiaryFixedVariant: Color(0xff0e0d2c),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff4c5154),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b2023),
      surfaceContainer: Color(0xff2c3134),
      surfaceContainerHigh: Color(0xff373c3f),
      surfaceContainerHighest: Color(0xff42474a),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surfaceDim,
    canvasColor: colorScheme.surface,
  );

  /// LogoColor
  static const logoColor = ExtendedColor(
    seed: Color(0xfff39b2e),
    value: Color(0xfff39b2e),
    light: ColorFamily(
      color: Color(0xff855317),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbd),
      onColorContainer: Color(0xff683c00),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff855317),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbd),
      onColorContainer: Color(0xff683c00),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff855317),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbd),
      onColorContainer: Color(0xff683c00),
    ),
    dark: ColorFamily(
      color: Color(0xfffbb974),
      onColor: Color(0xff492900),
      colorContainer: Color(0xff683c00),
      onColorContainer: Color(0xffffdcbd),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xfffbb974),
      onColor: Color(0xff492900),
      colorContainer: Color(0xff683c00),
      onColorContainer: Color(0xffffdcbd),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xfffbb974),
      onColor: Color(0xff492900),
      colorContainer: Color(0xff683c00),
      onColorContainer: Color(0xffffdcbd),
    ),
  );

  /// FireRed
  static const fireRed = ExtendedColor(
    seed: Color(0xffac1d13),
    value: Color(0xffae113d),
    light: ColorFamily(
      color: Color(0xff8f4952),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdadc),
      onColorContainer: Color(0xff72333b),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff8f4952),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdadc),
      onColorContainer: Color(0xff72333b),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff8f4952),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdadc),
      onColorContainer: Color(0xff72333b),
    ),
    dark: ColorFamily(
      color: Color(0xffffb2b9),
      onColor: Color(0xff561d26),
      colorContainer: Color(0xff72333b),
      onColorContainer: Color(0xffffdadc),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb2b9),
      onColor: Color(0xff561d26),
      colorContainer: Color(0xff72333b),
      onColorContainer: Color(0xffffdadc),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb2b9),
      onColor: Color(0xff561d26),
      colorContainer: Color(0xff72333b),
      onColorContainer: Color(0xffffdadc),
    ),
  );

  List<ExtendedColor> get extendedColors => [logoColor, fireRed];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
