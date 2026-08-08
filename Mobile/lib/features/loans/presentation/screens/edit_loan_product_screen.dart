import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../domain/entities/loan.dart';
import '../controllers/loan_controllers.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_product_form.dart';

/// Edit an existing loan product (chairperson).
class EditLoanProductScreen extends ConsumerStatefulWidget {
  const EditLoanProductScreen({
    super.key,
    required this.chamaId,
    required this.productId,
  });

  final String chamaId;
  final String productId;

  @override
  ConsumerState<EditLoanProductScreen> createState() =>
      _EditLoanProductScreenState();
}

class _EditLoanProductScreenState extends ConsumerState<EditLoanProductScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit(LoanProductInput input) async {
    try {
      final product =
          await ref.read(manageLoanProductControllerProvider.notifier).update(
                chamaId: widget.chamaId,
                productId: widget.productId,
                input: input,
              );
      if (!mounted) return;
      if (product == null) {
        final err = ref.read(manageLoanProductControllerProvider).errorMessage;
        AppSnackbar.error(
          context,
          (err == null || err.isEmpty)
              ? 'Could not update loan product.'
              : err.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
        return;
      }

      final args = (chamaId: widget.chamaId, productId: widget.productId);
      ref.invalidate(loanProductsControllerProvider(widget.chamaId));
      ref.invalidate(loanProductDetailsProvider(args));
      ref.invalidate(activeLoanProductsProvider(widget.chamaId));
      AppSnackbar.success(context, 'Loan product updated.');
      context.go(
        RoutePaths.loanProductDetails(widget.chamaId, widget.productId),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (chamaId: widget.chamaId, productId: widget.productId);
    final detailsState = ref.watch(loanProductDetailsProvider(args));
    final detailsController =
        ref.read(loanProductDetailsProvider(args).notifier);
    final manageState = ref.watch(manageLoanProductControllerProvider);

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
      appBar: AppBar(title: const Text('Edit loan product')),
      body: SafeArea(
        child: ApiStateBuilder<LoanProduct>(
          state: detailsState,
          onRefresh: detailsController.refresh,
          onRetry: detailsController.retry,
          builder: (context, product) {
            return LoanProductForm(
              key: ValueKey(product.updatedAt ?? product.id),
              formKey: _formKey,
              initial: product,
              isSubmitting: manageState.isSubmitting,
              submitLabel: 'Save changes',
              onSubmit: _submit,
            );
          },
        ),
      ),
    );
  }
}
