import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRefresh extends RefreshController<String> {
  _FakeRefresh({this.value = 'ok', this.throwError = false});

  String value;
  bool throwError;
  int fetchCount = 0;

  @override
  Future<String> fetchData({bool forceRefresh = false}) async {
    fetchCount++;
    if (throwError) {
      throw const ServerException(message: 'failed');
    }
    return value;
  }

  @override
  bool isEmptyData(String data) => data.isEmpty;
}

class _FakePager extends PaginationController<int> {
  _FakePager({this.failOnPage}) : super(pageSize: 2);

  final int? failOnPage;
  final pages = <int, List<int>>{
    1: [1, 2],
    2: [3, 4],
    3: [5],
  };

  @override
  Future<PageResult<int>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    if (failOnPage == page) {
      throw const ServerException(message: 'page fail');
    }
    final items = pages[page] ?? const <int>[];
    return PageResult(
      items: items,
      hasMore: pages.containsKey(page + 1),
      totalCount: 5,
    );
  }
}

void main() {
  group('ApiState', () {
    test('factories and helpers', () {
      expect(const ApiState<int>.initial().showLoading, isTrue);
      expect(const ApiState<int>.loading().isLoading, isTrue);
      expect(const ApiState.success(1).hasValue, isTrue);
      expect(const ApiState<int>.empty().isEmpty, isTrue);
      expect(ApiState<int>.error(Exception('x')).errorMessage, contains('x'));
      expect(
        const ApiState.refreshing(2).isRefreshing,
        isTrue,
      );
    });

    test('map transforms payload', () {
      final mapped = const ApiState.success(2).map((n) => n * 3);
      expect(mapped.data, 6);
      expect(mapped.isSuccess, isTrue);
    });
  });

  group('RefreshController', () {
    test('load / refresh / retry / empty / error', () async {
      final controller = _FakeRefresh();
      await controller.load();
      expect(controller.state.data, 'ok');
      expect(controller.fetchCount, 1);

      controller.value = 'updated';
      await controller.refresh();
      expect(controller.state.data, 'updated');
      expect(controller.fetchCount, 2);

      controller.value = '';
      await controller.load(forceRefresh: true);
      expect(controller.state.isEmpty, isTrue);

      controller.throwError = true;
      controller.value = 'ok';
      await controller.retry();
      expect(controller.state.isError, isTrue);
      expect(controller.state.errorMessage, 'failed');
    });
  });

  group('PaginationController', () {
    test('load, loadMore, and refresh', () async {
      final controller = _FakePager();
      await controller.load();
      expect(controller.state.data, [1, 2]);
      expect(controller.state.hasMore, isTrue);

      await controller.loadMore();
      expect(controller.state.data, [1, 2, 3, 4]);

      await controller.loadMore();
      expect(controller.state.data, [1, 2, 3, 4, 5]);
      expect(controller.state.hasMore, isFalse);

      await controller.refresh();
      expect(controller.state.data, [1, 2]);
    });

    test('surfaces fetch errors', () async {
      final controller = _FakePager(failOnPage: 1);
      await controller.load();
      expect(controller.state.isError, isTrue);
      expect(controller.state.errorMessage, 'page fail');
    });
  });

  group('ApiStateBuilder', () {
    testWidgets('shows shimmer while loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ApiStateBuilder<String>(
              state: ApiState.loading(),
              builder: _success,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('OK'), findsNothing);
    });

    testWidgets('shows success content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ApiStateBuilder<String>(
              state: ApiState.success('hello'),
              enablePullToRefresh: false,
              builder: _success,
            ),
          ),
        ),
      );

      expect(find.text('OK'), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('shows empty and error with retry', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiStateBuilder<String>(
              state: const ApiState.empty(),
              enablePullToRefresh: false,
              onRetry: () async => retried = true,
              emptyTitle: 'None',
              builder: _success,
            ),
          ),
        ),
      );
      expect(find.text('None'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiStateBuilder<String>(
              state: const ApiState.error(
                ServerException(message: 'Nope'),
                message: 'Nope',
              ),
              enablePullToRefresh: false,
              onRetry: () async {},
              builder: _success,
            ),
          ),
        ),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Nope'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}

Widget _success(BuildContext context, String data) {
  return Column(
    children: [
      const Text('OK'),
      Text(data),
    ],
  );
}
