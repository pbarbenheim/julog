import 'package:flutter/material.dart';

import 'list_detail/list_item.dart';
import 'list_detail/screen.dart';

class PlaceholderTestWidget extends StatelessWidget {
  const PlaceholderTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListDetailLayout(
      items: const [
        ListItem(title: Text('Item 1')),
        ListItem(title: Text('Item 2')),
        ListItem(title: Text('Item 3')),
      ],
      detailBuilder: (context, index) {
        return Center(child: Text('Detail for Item ${index + 1}'));
      },
    );
  }
}
