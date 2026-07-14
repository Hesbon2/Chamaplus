import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Material 3 form shell with optional auto-validation.
///
/// Wrap field widgets as [children]. Use [formKey] with [AppSubmitButton]
/// or call [FormState.validate] / [FormState.save] externally.
class AppForm extends StatelessWidget {
  /// Creates a themed form container.
  const AppForm({
    super.key,
    required this.child,
    this.formKey,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onChanged,
    this.padding,
  });

  /// Root form content, typically a [Column] of fields / [FormSection]s.
  final Widget child;

  /// Optional key used to validate and submit the form.
  final GlobalKey<FormState>? formKey;

  /// Controls when validators run automatically.
  final AutovalidateMode autovalidateMode;

  /// Called whenever any form field value changes.
  final VoidCallback? onChanged;

  /// Optional outer padding around the form body.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      child: child,
    );

    if (padding == null) return form;

    return Padding(padding: padding!, child: form);
  }
}

/// Groups related fields under a titled block within an [AppForm].
class FormSection extends StatelessWidget {
  /// Creates a labeled form section.
  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.spacing = AppSpacing.md,
  });

  /// Section heading.
  final String title;

  /// Optional supporting text under the heading.
  final String? subtitle;

  /// Fields rendered inside the section.
  final List<Widget> children;

  /// Vertical gap between child fields.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(subtitle!, style: theme.textTheme.bodyMedium),
        ],
        SizedBox(height: spacing),
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
