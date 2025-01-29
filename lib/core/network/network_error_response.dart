class NetworkErrorResponse implements Exception {
  final Map<String, dynamic>? errorResponseJsonMap;
  final String errorMessage;

  NetworkErrorResponse(this.errorResponseJsonMap, this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}