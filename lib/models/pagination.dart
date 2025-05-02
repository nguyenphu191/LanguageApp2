class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;
  final String message;

  PaginatedResponse({
    required this.data,
    required this.meta,
    required this.message,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json,
      T Function(Map<String, dynamic> json) fromJsonT) {
    final dataMap = json['data'] as Map<String, dynamic>;

    return PaginatedResponse<T>(
      data: (dataMap['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(dataMap['meta']),
      message: json['message'] ?? '',
    );
  }
}
