import 'package:flutter/material.dart';

import '../../components/action_button.dart';
import '../models/report_export_models.dart';

/// Primary CTA that opens export flows for a report.
class ExportButton extends StatelessWidget {
  const ExportButton({
    super.key,
    required this.onPressed,
    this.label = 'Export',
    this.icon = Icons.share_outlined,
    this.isLoading = false,
    this.expand = false,
    this.variant = ActionButtonVariant.secondary,
    this.format,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool expand;
  final ActionButtonVariant variant;
  final ExportFormat? format;

  @override
  Widget build(BuildContext context) {
    final resolvedLabel =
        format == null ? label : 'Export ${format!.label}';
    return ActionButton(
      label: resolvedLabel,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      expand: expand,
      variant: variant,
    );
  }
}
