class CommonResponse<T> {
  final T data;
  final String message;

  CommonResponse({
    required this.data,
    required this.message,
  });

  factory CommonResponse.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return CommonResponse<T>(
      data: fromJsonT(json['data']),
      message: json['message'],
    );
  }
}
