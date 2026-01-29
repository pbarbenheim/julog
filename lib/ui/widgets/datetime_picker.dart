import 'package:flutter/material.dart';

class DateTimePickerFormField extends FormField<DateTime> {
  DateTimePickerFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    ValueChanged<DateTime>? onChanged,
    String labelText = '',
    required DateTime firstDate,
    required DateTime lastDate,
  }) : super(
         builder: (FormFieldState<DateTime> state) {
           Future<void> pickDateTime(BuildContext context) async {
             final currentValue = state.value ?? DateTime.now();

             final date = await showDatePicker(
               context: context,
               initialDate: currentValue,
               firstDate: firstDate,
               lastDate: lastDate,
             );

             if (date == null) return;
             if (!context.mounted) return;

             final time = await showTimePicker(
               context: context,
               initialTime: TimeOfDay.fromDateTime(currentValue),
             );

             if (time == null) return;

             final newDateTime = DateTime(
               date.year,
               date.month,
               date.day,
               time.hour,
               time.minute,
             );

             state.didChange(newDateTime);
             onChanged?.call(newDateTime);
           }

           final value = state.value;

           return InkWell(
             onTap: () => pickDateTime(state.context),
             child: InputDecorator(
               decoration: InputDecoration(
                 labelText: labelText,
                 border: const OutlineInputBorder(),
                 errorText: state.errorText,
               ),
               child: Text(
                 value == null
                     ? 'Bitte auswählen'
                     : '${MaterialLocalizations.of(state.context).formatFullDate(value)} – ${TimeOfDay.fromDateTime(value).format(state.context)}',
               ),
             ),
           );
         },
       );
}
