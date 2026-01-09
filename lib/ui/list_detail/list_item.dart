import 'package:flutter/material.dart';

class ListItem {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;

  const ListItem({required this.title, this.subtitle, this.leading});
}
