import 'package:julog/repository/repository.dart';
import 'package:julog/ui/frame.dart';
import 'package:julog/ui/routes.dart';
import 'package:julog/ui/util.dart';
import 'package:julog/pdf/pdf.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class DienstbuchScreen extends ConsumerWidget {
  final int? id;
  const DienstbuchScreen({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref
        .watch(repositoryProvider.select((value) => value!.getAllEintrage()))
        .entries
        .map(
          (e) => EintragItem(
            id: e.key,
            beginn: e.value.$1,
            kategorie: e.value.$2,
            getEintrag: () => ref.read(repositoryProvider)!.getEintrag(e.key),
          ),
        )
        .toList();
    EintragItem? selectedItem;
    try {
      selectedItem = items.firstWhere((element) => element.id == id);
    } catch (e) {
      // Nothing to catch
    }

    return ListDetail(
      items: items,
      onChanged: (value) {
        EintragRoute(value.id).go(context);
      },
      listHeader: "Dienstbuch-Einträge",
      destination: Destination.julog,
      selectedItem: selectedItem,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          const AddDienstbuchEintragRoute().go(context);
        },
        child: const Icon(Icons.add),
      ),
      itemActions: [
        //if (selectedItem != null)
        IconButton(
          onPressed: () {
            showAdaptiveDialog(
              context: context,
              builder: (context) => Dialog.fullscreen(
                child: PdfPreview(
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  initialPageFormat: PdfPageFormat.a4,
                  //Change that
                  canDebug: true,
                  build: (format) =>
                      selectedItem!.getEintrag().buildPdf(format),
                ),
              ),
            );
          },
          icon: const Icon(Icons.picture_as_pdf),
        ),
      ],
    );
  }
}

class EintragItem extends Item {
  final int id;
  final DateTime beginn;
  final String kategorie;
  final Eintrag Function() getEintrag;
  EintragItem({
    super.key,
    required this.id,
    required this.beginn,
    required this.kategorie,
    required this.getEintrag,
  }) : super(title: kategorie, subtitle: beginn.toString());

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
              const Text("Beginn:"),
              Text(e.beginn.toString()),
            ],
          ),
          Row(
            children: [
              const Text("Ende:"),
              Text(e.ende.toString()),
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

  Widget _getTile(bool? verified) {
    final (name, comment, _) = Repository.userIdToComponents(signatur.userId);
    return ListTile(
      title: Text("gez. $name, $comment"),
      subtitle: Text(signatur.signedAt.toString()),
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
          return _getTile(snapshot.data!);
        }
        return _getTile(null);
      },
    );
  }
}

class AddDienstbuchEintragScreen extends StatelessWidget {
  const AddDienstbuchEintragScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return JulogScaffold(
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: AddDienstbuchEintragForm(),
        ),
      ),
      destination: Destination.julog,
      appBar: AppBar(
        title: const Text("Eintrag hinzufügen"),
      ),
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
              items: kategorien,
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
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Kategorie",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            DropdownSearch<Betreuer>.multiSelection(
              items: betreuer,
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
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
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

class SignEintragScreen extends ConsumerWidget {
  final int id;
  const SignEintragScreen({super.key, required this.id});

  Future<String?> _getPassword(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final result = await showAdaptiveDialog<String?>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Text(
                "Gebe dein Passwort zum Signieren an.",
                softWrap: true,
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  label: Text("Passwort"),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                onSubmitted: (value) {
                  Navigator.pop(context, value);
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 6)),
              TextButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text("Weiter"))
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider)!;
    final eintrag = repo.getEintrag(id);
    final userIds = repo
        .getSigningUserIds()
        .where((element) =>
            !eintrag.signaturen.map((e) => e.userId).contains(element))
        .map((element) {
      final e = Repository.userIdToComponents(element);
      return ListTile(
        title: Text(e.$2 == "" ? "${e.$1}, ${e.$2}" : e.$1),
        onTap: () async {
          final password = await _getPassword(context);
          if (password == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Du musst ein Password eingeben!")));
            }
            return;
          }

          /*try {*/
          await eintrag.sign(element, password);
          if (context.mounted) {
            EintragRoute(id).go(context);
          }
          /* } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Signieren nicht erfolgreich.")));
                }
                return;
              }*/
        },
      );
    }).toList();

    return JulogScaffold(
      destination: Destination.julog,
      appBar: AppBar(
        title: const Text("Eintrag unterschreiben"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ListView(
            children: userIds,
          ),
        ),
      ),
    );
  }
}
