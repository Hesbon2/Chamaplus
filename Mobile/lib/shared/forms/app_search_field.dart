import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// Search-oriented text field with a clear affordance.
///
/// Typically used above lists; can still participate in [AppForm] validation.
class AppSearchField extends StatefulWidget {
  /// Creates a search field.
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search…',
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return AppTextField(
      controller: _controller,
      label: widget.label,
      hint: widget.hint,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: hasText
          ? IconButton(
              tooltip: 'Clear',
              onPressed: widget.enabled && !widget.readOnly
                  ? () {
                      _controller.clear();
                      widget.onChanged?.call('');
                      widget.onClear?.call();
                    }
                  : null,
              icon: const Icon(Icons.close),
            )
          : null,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}
