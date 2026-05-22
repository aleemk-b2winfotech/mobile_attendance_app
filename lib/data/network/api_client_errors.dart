part of 'api_client.dart';

extension ApiClientErrors on ApiClient {
  String toReadableError(Object error) {
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map<String, dynamic>) {
        final errorBlock = body['error'];
        if (errorBlock is Map<String, dynamic>) {
          final message = errorBlock['message']?.toString().trim();
          if (message != null && message.isNotEmpty) {
            return message;
          }
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please try again.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to server. Please check your internet connection.';
      }
    }

    return 'Something went wrong';
  }
}
