import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_ui_mapper.dart';
import '../widgets/loan_tiles.dart';

/// Paginated repayment history for a loan application.
class RepaymentHistoryScreen extends ConsumerStatefulWidget {
  const RepaymentHistoryScreen({
    super.key,
    required this.chamaId,
    required this.applicationId,
  });

  final String chamaId;
  final String applicationId;

  @override
  ConsumerState<RepaymentHistoryScreen> createState() =>
      _RepaymentHistoryScreenState();
}

class _RepaymentHistoryScreenState
    extends ConsumerState<RepaymentHistoryScreen> {
  final _scrollController = ScrollController();
  late final InfiniteScrollListener _infiniteScroll;

  @override
  void initState() {
    super.initState();
    _infiniteScroll = InfiniteScrollListener(
      onLoadMore: () {
        final args = (
          chamaId: widget.chamaId,
          applicationId: widget.applicationId,
        );
        return ref
            .read(repaymentHistoryControllerProvider(args).notifier)
            .loadMore();
      },
    );
    _infiniteScroll.attach(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (
      chamaId: widget.chamaId,
      applicationId: widget.applicationId,
    );
    final state = ref.watch(repaymentHistoryControllerProvider(args));
    final controller =
        ref.read(repaymentHistoryControllerProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Repayment history')),
      body: Column(
        children: [
          if (controller.remainingBalance != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: StatCard(
                label: 'Remaining balance',
                value: LoanFormatters.money(controller.remainingBalance!),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
          Expanded(
            child: ApiStateBuilder<List<LoanRepayment>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No repayments yet',
              emptyMessage: 'Repayments will appear here once recorded.',
              emptyIcon: Icons.payments_outlined,
              builder: (context, repayments) {
                return ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount:
                      repayments.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index >= repayments.length) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return LoanRepaymentTile(
                      repayment: repayments[index],
                      remainingBalance: controller.remainingBalance,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
