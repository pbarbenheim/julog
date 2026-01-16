import 'package:flutter/material.dart';

import '../list_detail/list_item.dart';
import '../list_detail/screen.dart';

class BetreuerScreen extends StatelessWidget {
  const BetreuerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListDetailLayout(
      items: const [ListItem(title: Text('test'))],
      detailBuilder: (context, index) {
        return const Placeholder();
      },
    );
  }
}
