import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';
import 'util.dart';

class EintragItem extends Item {
  final int id;
  final DateTime beginn;
  final String thema;
  final Eintrag Function() getEintrag;
  EintragItem({
    super.key,
    required this.id,
    required this.beginn,
    required this.thema,
    required this.getEintrag,
  }) : super(
          title: thema,
          getSubtitle: (context) =>
              Intl(Localizations.localeOf(context).toLanguageTag())
                  .date('dd.MM.yy')
                  .format(beginn),
        );

  @override
  Widget build(BuildContext context) {
    final e = getEintrag();
    final List<Widget> betreuer = e.betreuer
        .map(
          (e) => ListTile(
            title: Text(e.name),
            onTap: () {
              BetreuerRoute(e.id).go(context);
            },
          ),
        )
        .toList();
    final List<Widget> jugendliche = e.jugendliche
        .map(
          (e) => ListTile(
            title: Text(e.$2),
            subtitle: e.$3 != null ? Text(e.$3!) : null,
            onTap: () {
              JugendlicheRoute(e.$1).go(context);
            },
          ),
        )
        .toList();
    final List<Widget> signatures = e.signaturen
        .map<Widget>(
          (e) => SignaturTile(signatur: e),
        )
        .toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              const Text("ID:"),
              Text(e.id.toString()),
            ],
          ),
          Row(
            children: [
              const Text("Beginn: "),
              DateTimeValue(
                dateTime: e.beginn,
                withTime: true,
              )
            ],
          ),
          Row(
            children: [
              const Text("Ende: "),
              DateTimeValue(
                dateTime: e.ende,
                withTime: true,
              )
            ],
          ),
          Row(
            children: [
              const Text("Kategorie:"),
              Text(e.kategorie?.name ?? "-"),
            ],
          ),
          Row(
            children: [
              const Text("Thema:"),
              Text(e.thema ?? "-"),
            ],
          ),
          Row(
            children: [
              const Text("Ort:"),
              Text(e.ort ?? "-"),
            ],
          ),
          Row(
            children: [
              const Text("Raum:"),
              Text(e.raum ?? "-"),
            ],
          ),
          Row(
            children: [
              const Text("Dienstverlauf:"),
              Text(e.dienstverlauf ?? "-"),
            ],
          ),
          Row(
            children: [
              const Text("Besonderheiten:"),
              Text(e.besonderheiten ?? "-"),
            ],
          ),
          ...betreuer,
          ...jugendliche,
          ...signatures,
          const Padding(padding: EdgeInsets.only(top: 20)),
          TextButton.icon(
            onPressed: () {
              SignEintragRoute(id).go(context);
            },
            icon: const Icon(Symbols.signature),
            label: const Text("Unterschreiben"),
          )
        ],
      ),
    );
  }
}

class SignaturTile extends StatelessWidget {
  final Signatur signatur;
  const SignaturTile({super.key, required this.signatur});

  Widget _getTile(BuildContext context, bool? verified) {
    final (name, comment, _) = Repository.userIdToComponents(signatur.userId);
    return ListTile(
      title: Text("gez. $name, $comment"),
      subtitle: DateTimeValue(
        dateTime: signatur.signedAt,
        withTime: true,
        prefix: "am ",
      ),
      leading: verified == null
          ? const Icon(Icons.question_mark)
          : (verified
              ? Icon(Icons.check, color: Colors.green[900])
              : Icon(Icons.error, color: Colors.red[900])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: signatur.verify(),
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _getTile(context, snapshot.data!);
        }
        return _getTile(context, null);
      },
    );
  }
}

class AddDienstbuchEintragForm extends ConsumerStatefulWidget {
  const AddDienstbuchEintragForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddDienstbuchEintragFormState();
}

class _AddDienstbuchEintragFormState
    extends ConsumerState<AddDienstbuchEintragForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _themaController;
  late final TextEditingController _ortController;
  late final TextEditingController _raumController;
  late final TextEditingController _dienstverlaufController;
  late final TextEditingController _besonderheitenController;
  Kategorie? _kategorie;
  final Set<Betreuer> _betreuer = {};
  final Map<int, String> _jugendlicheAnmerkungen = {};
  DateTime? _beginn;
  DateTime? _ende;

  @override
  void initState() {
    _themaController = TextEditingController();
    _ortController = TextEditingController();
    _raumController = TextEditingController();
    _dienstverlaufController = TextEditingController();
    _besonderheitenController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _themaController.dispose();
    _ortController.dispose();
    _raumController.dispose();
    _dienstverlaufController.dispose();
    _besonderheitenController.dispose();
    super.dispose();
  }

  int _saveToDb(Repository repo) {
    return repo.addEintrag(
      beginn: _beginn!,
      ende: _ende!,
      thema: _themaController.text,
      besonderheiten: _besonderheitenController.text,
      dienstverlauf: _dienstverlaufController.text,
      ort: _ortController.text,
      raum: _raumController.text,
      betreuerIds: _betreuer.map((e) => e.id).toList(),
      kategorieId: _kategorie!.id,
      jugendlicheIds:
          _jugendlicheAnmerkungen.entries.map((e) => (e.key, e.value)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider)!;
    final betreuer = repo.getAllBetreuer();
    final kategorien = repo.getAllKategorien();
    final jugendliche = repo.getAllJugendliche();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DateTimeField(
              onChanged: (value) {
                _beginn = value;
              },
              labelText: "Beginn",
              validator: (value) {
                if (value == null) {
                  return "Der Beginn muss angegeben werden";
                }
                if (value.isAfter(DateTime.now())) {
                  return "Der Beginn darf nicht in der Zukunft liegen.";
                }
                return null;
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            DateTimeField(
              onChanged: (value) {
                _ende = value;
              },
              labelText: "Ende",
              validator: (value) {
                if (value == null) {
                  return "Das Ende muss angegeben werden";
                }
                if (value.isAfter(DateTime.now())) {
                  return "Das Ende darf nicht in der Zukunft liegen.";
                }
                return null;
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            TextFormField(
              controller: _themaController,
              decoration: const InputDecoration(
                labelText: "Thema",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Es muss ein Thema angegeben werden";
                }
                return null;
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            TextFormField(
              controller: _ortController,
              decoration: const InputDecoration(
                labelText: "Ort",
                border: OutlineInputBorder(),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            TextFormField(
              controller: _raumController,
              decoration: const InputDecoration(
                labelText: "Raum",
                border: OutlineInputBorder(),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            TextFormField(
              controller: _dienstverlaufController,
              decoration: const InputDecoration(
                labelText: "Dienstverlauf",
                border: OutlineInputBorder(),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            TextFormField(
              controller: _besonderheitenController,
              decoration: const InputDecoration(
                labelText: "Besonderheiten",
                border: OutlineInputBorder(),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            DropdownSearch<Kategorie>(
              items: (filter, loadProps) => kategorien,
              compareFn: (item1, item2) => item1.id == item2.id,
              itemAsString: (item) => item.name,
              filterFn: (item, filter) => item.name.contains(filter),
              validator: (value) {
                if (value == null) {
                  return "Es muss eine Kategorie ausgewählt werden.";
                }
                return null;
              },
              selectedItem: _kategorie,
              onChanged: (value) {
                setState(() {
                  _kategorie = value;
                });
              },
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: "Kategorie",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            DropdownSearch<Betreuer>.multiSelection(
              items: (filter, loadProps) => betreuer,
              compareFn: (item1, item2) => item1.id == item2.id,
              itemAsString: (item) => item.name,
              filterFn: (item, filter) => item.name.contains(filter),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Es muss mindestens ein Betreuer ausgewählt werden.";
                }
                return null;
              },
              selectedItems: _betreuer.toList(),
              onChanged: (value) {
                setState(() {
                  _betreuer.clear();
                  _betreuer.addAll(value);
                });
              },
              popupProps: PopupPropsMultiSelection.menu(
                onItemAdded: (selectedItems, addedItem) {
                  setState(() {
                    _betreuer.add(addedItem);
                  });
                },
                onItemRemoved: (selectedItems, removedItem) {
                  setState(() {
                    _betreuer
                        .removeWhere((element) => element.id == removedItem.id);
                  });
                },
                showSearchBox: true,
                searchDelay: const Duration(milliseconds: 200),
                searchFieldProps: const TextFieldProps(
                  autofocus: true,
                ),
              ),
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: "Betreuer",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            JugendlicheForm(
              jugendliche: jugendliche,
              anmerkungen: _jugendlicheAnmerkungen,
              didChange: () {
                setState(() {});
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final repo = ref.read(repositoryProvider);
                    final id = _saveToDb(repo!);
                    SignEintragRoute(id).go(context);
                  },
                  icon: const Icon(Symbols.signature),
                  label: const Text("Unterschreiben"),
                ),
                TextButton(
                  onPressed: () {
                    final repo = ref.read(repositoryProvider)!;
                    final id = _saveToDb(repo);
                    EintragRoute(id).go(context);
                  },
                  child: const Text("Speichern"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JugendlicheForm extends StatelessWidget {
  final Map<int, String> jugendliche;
  final Map<int, String> anmerkungen;
  final void Function() didChange;
  const JugendlicheForm({
    super.key,
    required this.jugendliche,
    required this.anmerkungen,
    required this.didChange,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Jugendliche",
        border: OutlineInputBorder(),
      ),
      isFocused: false,
      isEmpty: false,
      child: Column(
        children: jugendliche.entries
            .map((e) => ListTile(
                  title: Text(e.value),
                  leading: IconButton(
                      onPressed: () {
                        if (!anmerkungen.containsKey(e.key)) {
                          anmerkungen.addAll({e.key: "anwesend"});
                          didChange();
                          return;
                        }
                        if (anmerkungen[e.key] == "abwesend") {
                          anmerkungen.remove(e.key);
                          didChange();
                          return;
                        }

                        anmerkungen.update(
                            e.key,
                            (value) => value == "anwesend"
                                ? "entschuldigt"
                                : "abwesend");
                        didChange();
                      },
                      icon: Icon(!anmerkungen.containsKey(e.key)
                          ? Icons.question_mark
                          : (anmerkungen[e.key] == "anwesend"
                              ? Icons.check
                              : (anmerkungen[e.key] == "entschuldigt"
                                  ? Icons.circle_outlined
                                  : Icons.close)))),
                ))
            .toList(),
      ),
    );
  }
}
