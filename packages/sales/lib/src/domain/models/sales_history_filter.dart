import 'package:equatable/equatable.dart';

/// Admin sales history query parameters.
class SalesHistoryFilter extends Equatable {
  const SalesHistoryFilter({
    this.fromDate,
    this.toDate,
    this.userId,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final String? userId;

  static const empty = SalesHistoryFilter();

  bool get hasActiveFilters =>
      fromDate != null || toDate != null || userId != null;

  SalesHistoryFilter copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearUserId = false,
  }) {
    return SalesHistoryFilter(
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      userId: clearUserId ? null : (userId ?? this.userId),
    );
  }

  @override
  List<Object?> get props => [fromDate, toDate, userId];
}
