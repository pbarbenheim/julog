import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:julog/repository/util/geschlecht.dart';

import '../../pubspec.g.dart';
import 'logo.dart';

void showJulogAbout({
  required BuildContext context,
  Offset? anchorPoint,
}) {
  return showAboutDialog(
    context: context,
    anchorPoint: anchorPoint,
    applicationName: "Julog",
    applicationVersion: Pubspec.version,
    applicationLegalese: "© Paul Barbenheim 2024",
    applicationIcon: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 80),
      child: const JulogLogo(),
    ),
  );
}

class GeschlechtDropDown extends StatelessWidget {
  final Geschlecht? value;
  final ValueChanged<Geschlecht?> onChanged;
  const GeschlechtDropDown({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Geschlecht>(
      items: const [
        DropdownMenuItem(
          value: Geschlecht.maennlich,
          child: Text("Männlich"),
        ),
        DropdownMenuItem(
          value: Geschlecht.weiblich,
          child: Text("Weiblich"),
        ),
        DropdownMenuItem(
          value: Geschlecht.divers,
          child: Text("Divers"),
        ),
      ],
      onChanged: onChanged,
      value: value,
      decoration: const InputDecoration(
        labelText: "Geschlecht",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null) {
          return "Es muss ein Geschlecht ausgewählt werden.";
        }
        return null;
      },
    );
  }
}

class DateTimeField extends StatefulWidget {
  final String? labelText;
  final Widget? label;
  final ValueChanged<DateTime?> onChanged;
  final FormFieldValidator<DateTime?>? validator;

  DateTimeField({
    super.key,
    this.label,
    this.labelText,
    required this.onChanged,
    this.validator,
  }) {
    assert(labelText == null || label == null);
  }

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: "tt.mm.jj hh:mm",
        hintStyle: TextStyle(fontFamily: "monospace"),
        border: OutlineInputBorder(),
        labelText: widget.labelText,
        label: widget.label,
      ),
      onChanged: (value) => widget.onChanged(_getDateTime(value)),
      validator: widget.validator != null
          ? (v) => widget.validator!(_getDateTime(v))
          : null,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d:\. ]*')),
        TextInputFormatter.withFunction(
          (oldValue, newValue) {
            final n = newValue.text;
            final o = oldValue.text;
            if (newValue.selection.extentOffset == n.length) {
              final String formatted;
              if (_numbersOnly(o).length == _numbersOnly(n).length &&
                  o.length != n.length) {
                final t = _numbersOnly(n);
                formatted = _format(t.substring(0, t.length - 1));
              } else {
                formatted = _format(n);
              }
              return newValue.copyWith(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            } else {
              final String numbers;
              if (_numbersOnly(o).length > _numbersOnly(n).length) {
                final i = newValue.selection.extentOffset;
                final (j, t) = _numbersOnlyWithCursor(i, n);
                numbers = t.replaceRange(j, j, '0');
              } else {
                final i = newValue.selection.extentOffset;
                final (j, t) = _numbersOnlyWithCursor(i, n);
                numbers = t.replaceRange(j, j + 1, '');
                final (c, formatted) = _formatWithCursor(numbers, j);
                return newValue.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: c));
              }
              return newValue.copyWith(
                text: _format(numbers),
              );
            }
          },
        )
      ],
    );
  }

  DateTime? _getDateTime(String? input) {
    if (input == null) {
      return null;
    }
    input = _numbersOnly(input);
    if (input.length != 10) {
      return null;
    }
    try {
      final days = int.parse(input.substring(0, 2));
      final month = int.parse(input.substring(2, 4));
      final year = 2000 + int.parse(input.substring(4, 6));
      final hours = int.parse(input.substring(6, 8));
      final minutes = int.parse(input.substring(8, 10));

      return DateTime(year, month, days, hours, minutes);
    } catch (e) {
      return null;
    }
  }

  (int, String) _numbersOnlyWithCursor(int cursor, String text) {
    final regex = RegExp(r'[0-9]');
    int newCursor = 0;
    StringBuffer buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (regex.hasMatch(text[i])) {
        buffer.write(text[i]);
        if (i < cursor) {
          newCursor++;
        }
      }
    }

    return (newCursor, buffer.toString());
  }

  String _numbersOnly(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _format(String text) {
    text = _numbersOnly(text);
    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    StringBuffer buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      // Füge Formatierung hinzu
      if (i == 1) buffer.write('.'); // Tag
      if (i == 3) buffer.write('.'); // Monat
      if (i == 5) buffer.write(' '); // Trennzeichen zwischen Datum und Uhrzeit
      if (i == 7) buffer.write(':'); // Stunden und Minuten
    }
    return buffer.toString();
  }

  (int, String) _formatWithCursor(String text, int cursor) {
    int newCursor = 0;
    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    StringBuffer buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i < cursor) {
        newCursor++;
      }

      // Füge Formatierung hinzu
      if (i == 1) {
        buffer.write('.');
        if (i < cursor) {
          newCursor++;
        }
      }
      if (i == 3) {
        buffer.write('.');
        if (i < cursor) {
          newCursor++;
        }
      }
      if (i == 5) {
        buffer.write(' ');
        if (i < cursor) {
          newCursor++;
        }
      }
      if (i == 7) {
        buffer.write(':');
        if (i < cursor) {
          newCursor++;
        }
      }
    }
    return (newCursor, buffer.toString());
  }
}

class DateTimeValue extends StatelessWidget {
  final DateTime dateTime;
  final bool withTime;
  final String? prefix;
  final String? suffix;
  const DateTimeValue({
    super.key,
    required this.dateTime,
    this.withTime = true,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Text((prefix ?? "") +
        Intl(Localizations.localeOf(context).toLanguageTag())
            .date(withTime ? "dd.MM.yy HH:mm" : "dd.MM.yy")
            .format(dateTime) +
        (suffix ?? ""));
  }
}
