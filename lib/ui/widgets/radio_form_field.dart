import 'package:flutter/material.dart';

class RadioFormFieldOption<T> {
  const RadioFormFieldOption({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final T value;
}

class RadioFormField<T> extends FormField<T> {
  RadioFormField({
    super.key,
    required List<RadioFormFieldOption<T>> options,
    super.initialValue,
    super.onSaved,
    super.validator,
    ValueChanged<T?>? onChanged,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    super.enabled,
    InputDecoration decoration = const InputDecoration(),
    double gap = 0,
    EdgeInsetsGeometry? contentPadding,
    bool dense = false,
  }) : assert(options.isNotEmpty, 'options cannot be empty'),
       super(
         builder: (field) {
           return _builder(
             field,
             decoration,
             options,
             gap,
             contentPadding,
             dense,
             enabled,
             onChanged,
           );
         },
       );

  static Widget _builder<T>(
    FormFieldState<T> field,
    InputDecoration decoration,
    List<RadioFormFieldOption<T>> options,
    double gap,
    EdgeInsetsGeometry? contentPadding,
    bool dense,
    bool enabled,
    ValueChanged<T?>? onChanged,
  ) {
    {
      final theme = Theme.of(field.context);
      final effectiveDecoration = decoration
          .applyDefaults(theme.inputDecorationTheme)
          .copyWith(
            errorText: field.errorText,
            contentPadding:
                contentPadding ?? decoration.contentPadding ?? EdgeInsets.zero,
          );

      void handleChanged(T? value) {
        if (!enabled) return;
        field.didChange(value);
        onChanged?.call(value);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InputDecorator(
          decoration: effectiveDecoration,
          isEmpty: field.value == null,
          child: RadioGroup(
            groupValue: field.value,
            onChanged: handleChanged,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: options.map((option) {
                return Padding(
                  padding: EdgeInsets.only(bottom: gap),
                  child: RadioListTile<T>(
                    title: Text(option.label),
                    subtitle: option.subtitle != null
                        ? Text(option.subtitle!)
                        : null,
                    value: option.value,
                    dense: false,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
  }
}
