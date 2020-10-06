import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AwsCognitoAuth {
  static const MethodChannel _channel = const MethodChannel('aws_cognito_auth');

  static Future<void> initialize({Function(dynamic) onError}) async {
    try {
      await _channel.invokeMethod("initialize");
      print("successfully added AWSCognitoAuthPlugin to Amplify");
    } catch (e) {
      if (onError != null) onError(e);
    }
  }

  static Future<void> signUp(String username, String password,
      {String email,
      String name,
      String givenName,
      String familyName,
      String phoneNumber,
      Map<String, dynamic> attributes,
      Function(AuthSignUpResult) onResult,
      Function(AuthSignUpError) onError}) async {
    Map<String, dynamic> parameters = {
      "username": username.trim().toLowerCase(),
      "password": password.trim(),
    };
    if (email != null) {
      parameters["email"] = email.trim().toLowerCase();
    }
    if (name != null) {
      parameters["name"] = name;
    }
    if (givenName != null) {
      parameters["givenName"] = givenName;
    }
    if (familyName != null) {
      parameters["familyName"] = familyName;
    }
    if (phoneNumber != null) {
      parameters["phoneNumber"] = phoneNumber;
    }

    print("attributes");
    print(parameters);
    print("custom");
    print(attributes);

    print("HERE ARE THE PARAMETERS");
    print(parameters);

    try {
      var result = await _channel.invokeMapMethod<String, dynamic>(
          "signUp", {"attributes": parameters, "custom": attributes});

      if (onResult != null) {
        onResult(
            AuthSignUpResult(isSignUpComplete: result["isSignUpComplete"]));
      }
    } catch (e) {
      print(e);
      if (onError != null) {
        onError(AuthSignUpError.parse(e));
      }
    }
  }

  static Future<void> confirmSignUp(String username, String code,
      {Function(AuthSignUpResult) onResult,
      Function(AuthConfirmSignUpError) onError}) async {
    try {
      var result = await _channel.invokeMapMethod<String, dynamic>(
        "confirmSignUp",
        {
          "username": username.trim().toLowerCase(),
          "code": code.trim(),
        },
      );
      if (onResult != null) {
        onResult(
          AuthSignUpResult(
            isSignUpComplete: result["isSignUpComplete"],
          ),
        );
      }
    } catch (e) {
      print(e);
      if (onError != null) {
        onError(AuthConfirmSignUpError.parse(e));
      }
    }
  }

  static Future<void> resendSignUpCode(String username,
      {Function(AuthSignUpResult) onResult, Function onError}) async {
    try {
      var result = await _channel.invokeMethod<bool>(
        "resendSignUpCode",
        {
          "username": username.trim().toLowerCase(),
        },
      );
      if (onResult != null) {
        onResult(
          AuthSignUpResult(
            isSignUpComplete: result,
          ),
        );
      }
    } catch (e) {
      print(e);
      if (onError != null) {
        onError();
      }
    }
  }

  static Future<void> signIn(
    String username,
    String password, {
    Function(AuthSignInResult) onResult,
    Function(AuthSignInError) onError,
  }) async {
    try {
      var result = await _channel.invokeMapMethod<String, dynamic>("signIn", {
        "username": username.trim().toLowerCase(),
        "password": password.trim(),
      });
      if (onResult != null) {
        onResult(
            AuthSignInResult(isSignInComplete: result["isSignInComplete"]));
      }
    } catch (e) {
      print(e);
      if (onError != null) {
        onError(AuthSignInError.parse(e));
      }
    }
  }

  static Future<void> signOut({Function onResult, Function onError}) async {
    try {
      await _channel.invokeMethod("signOut");
      if (onResult != null) onResult();
    } catch (e) {
      if (onError != null)
        onError();
      else
        print(e);
    }
  }

  static Future<void> resetPassword(String username,
      {Function(AuthResetPasswordResult) onResult,
      Function(AuthResetPasswordError) onError}) async {
    try {
      var result =
          await _channel.invokeMapMethod<String, dynamic>("resetPassword", {
        "username": username.trim().toLowerCase(),
      });
      if (onResult != null) {
        onResult(AuthResetPasswordResult(
            isPasswordReset: result["isPasswordReset"]));
      }
    } catch (e) {
      if (onError != null) {
        onError(AuthResetPasswordError.parse(e));
      }
    }
  }

  static Future<void> confirmResetPassword(String password, String code,
      {Function onResult,
      Function(AuthConfirmResetPasswordError) onError}) async {
    try {
      var _ = await _channel.invokeMethod("confirmResetPassword", {
        "password": password.trim(),
        "code": code.trim(),
      });
      if (onResult != null) {
        onResult();
      }
    } catch (e) {
      print(e);
      if (onError != null) {
        onError(AuthConfirmResetPasswordError.parse(e));
      }
    }
  }

  static Future<void> updatePassword(String password, String newPassword,
      {Function onResult, Function onError}) async {
    try {
      var _ =
          await _channel.invokeMapMethod<String, dynamic>("updatePassword", {
        "password": password.trim(),
        "newPassword": newPassword.trim(),
      });
      if (onResult != null) {
        onResult();
      }
    } catch (e) {
      print(e);
      if (onError != null) {
        onError();
      }
    }
  }

  static Future<Map<String, String>> getUserAttributes(
      {Function(Error) onError}) async {
    try {
      final result =
          await _channel.invokeMapMethod<String, String>("getUserAttributes");
      return result;
    } catch (e) {
      if (onError != null)
        onError(e);
      else
        print(e);
      return null;
    }
  }

  static Future<bool> isSignedIn() async {
    try {
      var result = await _channel.invokeMethod("isSignedIn");
      return result;
    } catch (e) {
      return false;
    }
  }
}

enum ConfirmResetPasswordError {
  passwordLength,
  passwordRequireUppercase,
  passwordRequireLowercase,
  passwordRequireNumeric,
  passwordRequireSymbol,
  invalidCode,
  attempLimitExceeded,
  unknown,
}

// Invalid verification code provided, please try again
// Password must have uppercase characters

class AuthConfirmResetPasswordError {
  final ConfirmResetPasswordError error;
  final String suggestedErrorMessage;

  AuthConfirmResetPasswordError(
      {this.error = ConfirmResetPasswordError.unknown,
      this.suggestedErrorMessage =
          "Something went wrong. Please try again soon."});

  static AuthConfirmResetPasswordError parse(PlatformException e) {
    var error = ConfirmResetPasswordError.unknown;
    String suggestedErrorMessage =
        "Something went wrong. Please try again soon.";

    if (e.message.contains("Password not long enough") ||
        e.message
            .contains("Member must have length greater than or equal to 6")) {
      error = ConfirmResetPasswordError.passwordLength;
      suggestedErrorMessage = "Please enter a longer password";
    } else if (e.message.contains("Password must have uppercase characters")) {
      error = ConfirmResetPasswordError.passwordRequireUppercase;
      suggestedErrorMessage =
          "Your password must contain at least one uppercase character";
    } else if (e.message.contains("Password must have lowercase characters")) {
      error = ConfirmResetPasswordError.passwordRequireLowercase;
      suggestedErrorMessage =
          "Your password must contain at least one lowercase character";
    } else if (e.message.contains("Password must have numeric characters")) {
      error = ConfirmResetPasswordError.passwordRequireNumeric;
      suggestedErrorMessage = "Your password must contain at least one number";
    } else if (e.message.contains("Password must have symbol characters")) {
      error = ConfirmResetPasswordError.passwordRequireSymbol;
      suggestedErrorMessage = "Your password must contain at least one symbol";
    } else if (e.message
        .contains("Attempt limit exceeded, please try after some time")) {
      error = ConfirmResetPasswordError.attempLimitExceeded;
    } else if (e.message
        .contains("Invalid verification code provided, please try again")) {
      error = ConfirmResetPasswordError.invalidCode;
      suggestedErrorMessage = "The verification code entered was incorrect";
    }

    return AuthConfirmResetPasswordError(
      error: error,
      suggestedErrorMessage: suggestedErrorMessage,
    );
  }
}

class AuthResetPasswordResult {
  final bool isPasswordReset;

  AuthResetPasswordResult({this.isPasswordReset = false});
}

enum ResetPasswordError {
  missingUsername,
  userNotFound,
  userNotVerified,
  attemptLimitExceeded,
  unknown,
}

class AuthResetPasswordError {
  final ResetPasswordError error;
  final String suggestedErrorMessage;

  AuthResetPasswordError({
    this.error = ResetPasswordError.unknown,
    this.suggestedErrorMessage = "Something went wrong. Please try again soon",
  });

  static AuthResetPasswordError parse(PlatformException e) {
    print(e);

    var error = ResetPasswordError.unknown;
    String suggestedErrorMessage =
        "Something went wrong. Please try again soon.";

    if (e.message.contains(
        "Value at 'username' failed to satisfy constraint: Member must not be null")) {
      error = ResetPasswordError.missingUsername;
      suggestedErrorMessage = "Please enter your email";
    } else if (e.message.contains("Username/client id combination not found")) {
      error = ResetPasswordError.userNotFound;
      suggestedErrorMessage = "No account was found";
    } else if (e.message.contains(
        "Cannot reset password for the user as there is no registered/verified email or phone_number")) {
      error = ResetPasswordError.userNotVerified;
      suggestedErrorMessage =
          "Your account must be verified before you can reset the password";
    } else if (e.message
        .contains("Attempt limit exceeded, please try after some time")) {
      error = ResetPasswordError.attemptLimitExceeded;
    }
    return AuthResetPasswordError(
      error: error,
      suggestedErrorMessage: suggestedErrorMessage,
    );
  }
}

class AuthSignInResult {
  final bool isSignInComplete;

  AuthSignInResult({this.isSignInComplete = false});
}

enum SignInError {
  missingUsername,
  userDoesNotExist,
  incorrectUsernameOrPassword,
  userNotConfirmed,
  unknown,
}

class AuthSignInError {
  final SignInError error;
  final String suggestedErrorMessage;

  AuthSignInError({
    this.error = SignInError.unknown,
    this.suggestedErrorMessage = "Something went wrong. Please try again soon",
  });

  static AuthSignInError parse(PlatformException e) {
    var error = SignInError.unknown;
    String suggestedErrorMessage =
        "Something went wrong. Please try again soon.";
    if (e.message.contains("Missing required parameter USERNAME")) {
      error = SignInError.missingUsername;
      suggestedErrorMessage = "Please enter your email";
    } else if (e.message.contains("User does not exist")) {
      error = SignInError.userDoesNotExist;
      suggestedErrorMessage = "Incorrect email or password";
    } else if (e.message.contains("Incorrect username or password")) {
      error = SignInError.incorrectUsernameOrPassword;
      suggestedErrorMessage = "Incorrect email or password";
    } else if (e.message.contains("User is not confirmed")) {
      error = SignInError.userNotConfirmed;
      suggestedErrorMessage = "This account has not been verified";
    }

    return AuthSignInError(
      error: error,
      suggestedErrorMessage: suggestedErrorMessage,
    );
  }
}

class AuthSignUpResult {
  final bool isSignUpComplete;

  AuthSignUpResult({this.isSignUpComplete = false});
}

enum SignUpError {
  invalidEmail,
  invalidUsername,
  passwordLength,
  usernameLength,
  usernameShouldBeEmail,
  missingAttribute,
  usernameEmailNotMatching,
  passwordRequireUppercase,
  passwordRequireLowercase,
  passwordRequireNumeric,
  passwordRequireSymbol,
  accountExists,
  unknown,
}

enum ConfirmSignUpError {
  invalidCode,
  invalidUsername,
  unknown,
}

class AuthConfirmSignUpError {
  final ConfirmSignUpError error;
  final String suggestedErrorMessage;

  AuthConfirmSignUpError({
    this.error = ConfirmSignUpError.unknown,
    this.suggestedErrorMessage = "Something went wrong. Please try again soon.",
  });

  static AuthConfirmSignUpError parse(PlatformException e) {
    var error = ConfirmSignUpError.unknown;
    String suggestedErrorMessage =
        "Something went wrong. Please try again soon.";
    if (e.message.contains("Invalid verification code provided")) {
      error = ConfirmSignUpError.invalidCode;
      suggestedErrorMessage = "The verification code entered was incorrect";
    } else if (e.message.contains(
        "Value at 'username' failed to satisfy constraint: Member must satisfy regular expression pattern")) {
      error = ConfirmSignUpError.invalidUsername;
    }

    return AuthConfirmSignUpError(
      error: error,
      suggestedErrorMessage: suggestedErrorMessage,
    );
  }
}

class AuthSignUpError {
  final SignUpError error;
  final String suggestedErrorMessage;

  AuthSignUpError({
    this.error = SignUpError.unknown,
    this.suggestedErrorMessage = "Something went wrong. Please try again soon.",
  });

  static AuthSignUpError parse(PlatformException e) {
    var error = SignUpError.unknown;
    String suggestedErrorMessage =
        "Something went wrong. Please try again soon.";
    if (e.message.contains("Invalid email address format")) {
      error = SignUpError.invalidEmail;
      suggestedErrorMessage = "Please enter a valid email";
    } else if (e.message.contains("Username should be an email")) {
      error = SignUpError.usernameShouldBeEmail;
      suggestedErrorMessage = "Please enter a valid email";
    } else if (e.message.contains("Password not long enough") ||
        e.message
            .contains("Member must have length greater than or equal to 6")) {
      error = SignUpError.passwordLength;
      suggestedErrorMessage = "Please enter a longer password";
    } else if (e.message.contains(
        "Value at 'username' failed to satisfy constraint: Member must have length greater than or equal to 1")) {
      error = SignUpError.usernameLength;
      suggestedErrorMessage = "Please enter your email";
    } else if (e.message.contains("The attribute is required")) {
      error = SignUpError.missingAttribute;
    } else if (e.message
        .contains("User email should be empty or same as username")) {
      error = SignUpError.usernameEmailNotMatching;
    } else if (e.message.contains("Password must have uppercase characters")) {
      error = SignUpError.passwordRequireUppercase;
      suggestedErrorMessage =
          "Your password must contain at least one uppercase character";
    } else if (e.message.contains("Password must have lowercase characters")) {
      error = SignUpError.passwordRequireLowercase;
      suggestedErrorMessage =
          "Your password must contain at least one lowercase character";
    } else if (e.message.contains("Password must have numeric characters")) {
      error = SignUpError.passwordRequireNumeric;
      suggestedErrorMessage = "Your password must contain at least one number";
    } else if (e.message.contains("Password must have symbol characters")) {
      error = SignUpError.passwordRequireSymbol;
      suggestedErrorMessage = "Your password must contain at least one symbol";
    } else if (e.message
        .contains("Value at 'username' failed to satisfy constraint")) {
      error = SignUpError.invalidUsername;
      suggestedErrorMessage = "Please enter a valid username";
    } else if (e.message
        .contains("An account with the given email already exists")) {
      error = SignUpError.accountExists;
      suggestedErrorMessage = "An account already exists with that email";
    }

    return AuthSignUpError(
        error: error, suggestedErrorMessage: suggestedErrorMessage);
  }
}
