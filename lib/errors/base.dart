class BaseError extends Error {
  String message;
  BaseError(this.message);

  @override
  String toString() {
    return "Error: $message";
  }
}

class SingletonError extends BaseError {
  SingletonError(
      [super.message =
          'Cannot instantiate more than one object of this class']);

  @override
  String toString() {
    return "${super.toString()} [SingletonError]";
  }
}

class AuthError extends BaseError {
  AuthError([super.message = 'Authentication Error has occurred']);
}

class AccountError extends BaseError {
  AccountError([super.message = 'AccountError has occurred']);
}
