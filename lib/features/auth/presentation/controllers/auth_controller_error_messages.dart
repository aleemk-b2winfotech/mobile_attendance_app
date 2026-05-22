part of 'auth_controller.dart';

extension AuthControllerErrorMessages on AuthController {
  bool _isConnectivityIssue(Object error) {
    return error is DioException &&
        <DioExceptionType>{
          DioExceptionType.connectionTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.connectionError,
        }.contains(error.type);
  }

  String? _toLoginErrorMessage(Object error) {
    final googleMessage = _toGoogleSignInErrorMessage(error);
    if (googleMessage != null || _isGoogleSignInCancellation(error)) {
      return googleMessage;
    }

    var message = _repository.toReadableError(error);
    if (message == 'Something went wrong' && error is Exception) {
      final fallback = error.toString().replaceFirst('Exception: ', '').trim();
      if (fallback.isNotEmpty) {
        message = fallback;
      }
    }
    return message;
  }

  String? _toGoogleSignInErrorMessage(Object error) {
    if (error is! PlatformException) return null;

    final code = error.code.trim().toLowerCase();
    final combinedText = _combineGoogleErrorText(error);

    if (code == GoogleSignIn.kNetworkError) {
      return 'Google sign-in needs an internet connection. Please try again.';
    }

    if (_looksLikeCompanyAccountRestriction(combinedText)) {
      return 'Please sign in with your company Google account. Personal or non-company accounts are not allowed.';
    }

    if (code == GoogleSignIn.kSignInFailedError ||
        code == GoogleSignIn.kSignInRequiredError) {
      if (_looksLikeGoogleDeveloperConfigError(combinedText)) {
        return 'Google sign-in is not configured for this app build. Please check the Android package name and signing certificate in Google Cloud.';
      }

      return 'Google sign-in could not be completed. Please try again.';
    }

    return null;
  }

  bool _isGoogleSignInCancellation(Object error) {
    return error is PlatformException &&
        error.code.trim().toLowerCase() == GoogleSignIn.kSignInCanceledError;
  }

  String _combineGoogleErrorText(PlatformException error) {
    return <Object?>[error.code, error.message, error.details]
        .where((part) => part != null && part.toString().trim().isNotEmpty)
        .map((part) => part.toString().toLowerCase())
        .join(' ');
  }

  bool _looksLikeCompanyAccountRestriction(String errorText) {
    const restrictionHints = <String>[
      'invalid account',
      'account not allowed',
      'not allowed to sign in',
      'only accounts from',
      'hosted domain',
      'hosted_domain',
      'organizational account',
      'organisation account',
      'organization account',
      'workspace account',
      'managed account',
      'restricted to accounts',
      'restricted by your admin',
      'restricted by an administrator',
      'domain users only',
      'not in your organization',
      'not part of this organization',
    ];

    return restrictionHints.any(errorText.contains);
  }

  bool _looksLikeGoogleDeveloperConfigError(String errorText) {
    const configHints = <String>[
      'developer_error',
      'api exception: 10',
      'apiexception: 10',
      '10:',
    ];

    return configHints.any(errorText.contains);
  }
}
