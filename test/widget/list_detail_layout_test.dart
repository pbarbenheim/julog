import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:julog/ui/list_detail/list_detail.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

ListDetailLayout _minimal({
  List<Widget>? Function(BuildContext)? listActionsBuilder,
}) {
  return ListDetailLayout(
    items: const [],
    detailBuilder: (_, _) => const SizedBox(),
    showEmptyHint: false,
    listActionsBuilder: listActionsBuilder,
  );
}

void main() {
  group('ListDetailLayout listActionsBuilder', () {
    testWidgets('null: no header row rendered', (tester) async {
      await tester.pumpWidget(_wrap(_minimal(listActionsBuilder: null)));

      expect(find.byKey(const Key('list_header_row')), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('non-null: header row with returned widgets rendered', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _minimal(
            listActionsBuilder: (_) => [
              IconButton(
                key: const Key('export_btn'),
                onPressed: () {},
                icon: const Icon(Icons.download),
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(const Key('export_btn')), findsOneWidget);
    });

    testWidgets('non-null returning null: renders empty row gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_minimal(listActionsBuilder: (_) => null)));

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets(
      'list pane still shows items when listActionsBuilder provided',
      (tester) async {
        const itemTitle = 'Test Item';
        final layout = ListDetailLayout(
          items: const [ListItem(title: Text(itemTitle))],
          detailBuilder: (_, _) => const SizedBox(),
          showEmptyHint: false,
          listActionsBuilder: (_) => [
            IconButton(
              key: const Key('action_btn'),
              onPressed: () {},
              icon: const Icon(Icons.add),
            ),
          ],
        );

        await tester.pumpWidget(_wrap(layout));

        expect(find.text(itemTitle), findsOneWidget);
        expect(find.byKey(const Key('action_btn')), findsOneWidget);
      },
    );
  });
}
