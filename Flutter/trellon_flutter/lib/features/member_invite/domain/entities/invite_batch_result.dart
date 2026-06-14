class InviteBatchResult {
  final int successCount;
  final int failureCount;

  const InviteBatchResult({
    required this.successCount,
    required this.failureCount,
  });

  bool get allSucceeded => failureCount == 0;
  int get totalCount => successCount + failureCount;
}
