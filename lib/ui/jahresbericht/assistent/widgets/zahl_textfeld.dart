import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Liest die Eingabe eines Zahlenfelds: eine ganze Zahl `>= 0`.
///
/// Liefert `(wert: n)` für eine gültige Zahl, `(wert: null)` für eine leere
/// Eingabe, wenn [erlaubtLeer], und `null` für eine ungültige Eingabe (leer
/// ohne [erlaubtLeer], keine Ziffern, zu groß).
({int? wert})? leseZahl(String text, {required bool erlaubtLeer}) {
  final t = text.trim();
  if (t.isEmpty) return erlaubtLeer ? (wert: null) : null;
  if (!RegExp(r'^\d+$').hasMatch(t)) return null;
  final zahl = int.tryParse(t);
  return zahl == null ? null : (wert: zahl);
}

/// Ein Eingabefeld für eine ganze Zahl `>= 0`, das mit einem Wert im Entwurf
/// abgeglichen wird.
///
/// Gültige Eingaben gehen sofort an [onWert]; ungültige werden am Feld mit
/// [fehlerText] gemeldet und nicht übernommen (kein Ziffernfilter, damit
/// nichts still verworfen wird). Ändert sich [wert] von außen (Zurücknehmen,
/// Neuladen), zieht das Feld nach.
class ZahlTextFeld extends StatefulWidget {
  /// Schlüssel des eigentlichen [TextField]s.
  final Key? feldKey;

  /// Aktueller Wert im Entwurf (`null` = nicht angegeben).
  final int? wert;

  /// Wird mit jeder gültigen Eingabe aufgerufen (`null` bei leerem Feld, wenn
  /// [erlaubtLeer]).
  final ValueChanged<int?> onWert;

  /// Leere Eingabe heißt "nicht angegeben" statt Fehler.
  final bool erlaubtLeer;

  final String fehlerText;
  final String? labelText;

  /// Hinweis unter dem Feld, solange es leer (und nicht ungültig) ist.
  final String? leerHinweis;

  /// Hintergrund des Felds, z. B. um einen überschriebenen Wert zu markieren.
  final Color? fuellfarbe;

  const ZahlTextFeld({
    super.key,
    this.feldKey,
    required this.wert,
    required this.onWert,
    required this.erlaubtLeer,
    required this.fehlerText,
    this.labelText,
    this.leerHinweis,
    this.fuellfarbe,
  });

  @override
  State<ZahlTextFeld> createState() => _ZahlTextFeldState();
}

class _ZahlTextFeldState extends State<ZahlTextFeld> {
  late final TextEditingController _controller;
  bool _ungueltig = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.wert?.toString() ?? '');
  }

  @override
  void didUpdateWidget(ZahlTextFeld oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Der Wert hat sich von außen geändert: Feld nachziehen. Eigene gültige
    // Eingaben stimmen schon überein.
    if (oldWidget.wert != widget.wert) {
      final eingabe = leseZahl(
        _controller.text,
        erlaubtLeer: widget.erlaubtLeer,
      );
      if (eingabe == null || eingabe.wert != widget.wert) {
        _controller.text = widget.wert?.toString() ?? '';
        _ungueltig = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _geaendert(String text) {
    final eingabe = leseZahl(text, erlaubtLeer: widget.erlaubtLeer);
    setState(() => _ungueltig = eingabe == null);
    if (eingabe != null) widget.onWert(eingabe.wert);
  }

  @override
  Widget build(BuildContext context) {
    final leer = _controller.text.trim().isEmpty;
    return TextField(
      key: widget.feldKey,
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [LengthLimitingTextInputFormatter(9)],
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        isDense: widget.labelText == null,
        helperText: leer && !_ungueltig ? widget.leerHinweis : null,
        errorText: _ungueltig ? widget.fehlerText : null,
        errorMaxLines: 3,
        filled: widget.fuellfarbe != null,
        fillColor: widget.fuellfarbe,
      ),
      onChanged: _geaendert,
    );
  }
}
