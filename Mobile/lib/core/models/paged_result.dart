/// Generic paginated list result for repository APIs.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.count,
    this.nextPage,
    this.hasMore = false,
  });

  final List<T> items;
  final int count;
  final int? nextPage;
  final bool hasMore;
}
