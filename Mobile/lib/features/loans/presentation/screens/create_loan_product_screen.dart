import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/loan.dart';
import '../controllers/loan_controllers.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_product_form.dart';

/// Create a loan product (chairperson / treasurer).
class CreateLoanProductScreen extends ConsumerStatefulWidget {
  const CreateLoanProductScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<CreateLoanProductScreen> createState() =>
      _CreateLoanProductScreenState();
}

class _CreateLoanProductScreenState
    extends ConsumerState<CreateLoanProductScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit(LoanProductInput input) async {
    try {
      final product =
          await ref.read(manageLoanProductControllerProvider.notifier).create(
                chamaId: widget.chamaId,
                input: input,
              );
      if (!mounted) return;
      if (product == null) {
        final err = ref.read(manageLoanProductControllerProvider).errorMessage;
        AppSnackbar.error(
          context,
          (err == null || err.isEmpty)
              ? 'Could not create loan product.'
              : err.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
        return;
      }

      ref.invalidate(loanProductsControllerProvider(widget.chamaId));
      ref.invalidate(activeLoanProductsProvider(widget.chamaId));
      AppSnackbar.success(context, 'Loan product created.');
      context.go(RoutePaths.loanProducts(widget.chamaId));
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manageLoanProductControllerProvider);

    ref.listen<ManageLoanProductState>(manageLoanProductControllerProvider,
        (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        AppSnackbar.error(
          context,
          next.errorMessage!.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create loan product')),
      body: SafeArea(
        child: LoanProductForm(
          formKey: _formKey,
          isSubmitting: state.isSubmitting,
          submitLabel: 'Create product',
          onSubmit: _submit,
        ),
      ),
    );
  }
}
