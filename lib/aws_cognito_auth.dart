import 'dart:async';
import 'package:auth_ui/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

enum UserCodeDeliveryMedium { sms, email, unknown }

enum UserState {
  signedIn,
  signedOut,
  signedOutFederatedTokensInvalid,
  signedOutUserPoolsTokenInvalid,
  guest,
  unknown
}

enum UserStateAndroid {
  SIGNED_IN,
  SIGNED_OUT,
  SIGNED_OUT_FEDERATED_TOKENS_INVALID,
  SIGNED_OUT_USER_POOLS_TOKENS_INVALID,
  GUEST,
  UNKNOWN
}

enum SignInState {
  smsMFA,
  passwordVerifier,
  customChallenge,
  deviceSRPAuth,
  devicePasswordVerifier,
  adminNoSRPAuth,
  newPasswordRequired,
  signedIn,
  unknown
}
enum SignInStateAndroid {
  test,
  test2,
  test3,
  test4,
  test5,
  test6,
  test7,
  DONE,
  unknown
}

enum SignInError {
  usernameMissing,
  userNotFound,
  userNotConfirmed,
  incorrectUsernameOrPassword,
  userAlreadySignedIn,
  unknown
}

enum ForgotPasswordState {
  done,
  confirmationCodeSent,
  unknown,
}

enum ConfirmSignUpError {
  usernameLength,
  confirmationCodeLength,
  usernameNotFound,
  invalidVerificationCode,
  emailUsed,
  unknown
}

enum ResendSignUpCodeError {
  usernameLength,
  usernameNotFound,
  userConfirmed,
  unknown
}

class AuthSignInResult {
  SignInState signInState;
  Map parameters;
  UserCodeDeliveryDetails codeDetails = new UserCodeDeliveryDetails();
}

class AuthSignInError {
  SignInError error;
  String rawError;
  String rawMessage;
}

class AuthResendSignUpCodeError {
  ResendSignUpCodeError error;
  String rawError;
  String rawMessage;
}

class AuthConfirmSignUpError {
  ConfirmSignUpError error;
  String rawError;
  String rawMessage;
}

class UserCodeDeliveryDetails {
  String destination;
  String attributeName;
  UserCodeDeliveryMedium deliveryMedium;
}

class AuthSignUpResult {
  SignUpConfirmationState signUpConfirmationState;
  UserCodeDeliveryDetails codeDeliveryDetails = new UserCodeDeliveryDetails();
}

enum SignUpConfirmationState { confirmed, unconfirmed, unknown }

enum SignUpError {
  passwordLength,
  usernameLength,
  passwordUppercase,
  passwordLowercase,
  passwordNumeric,
  passwordSymbol,
  attributeRequired,
  emailInvalid,
  userExists,
  unknown
}

enum ForgotPasswordError {
  usernameLength,
  userNotFound,
  notVerified,
  unknown,
}

enum ConfirmForgotPasswordError {
  usernameLength,
  passwordLength,
  passwordUppercase,
  passwordLowercase,
  passwordNumeric,
  passwordSymbol,
  confirmationCodeLength,
  userNotFound,
  invalidCode,
  unknown
}

class AuthForgotPasswordError {
  ForgotPasswordError error;
  String rawError;
  String rawMessage;
}

enum ChangePasswordError {
  notSignedIn,
  incorrectPassword,
  passwordLength,
  passwordUppercase,
  passwordLowercase,
  passwordNumeric,
  passwordSymbol,
  unknown
}

class AuthChangePasswordError {
  ChangePasswordError error;
  String rawError;
  String rawMessage;
}

class AuthConfirmForgotPasswordError {
  ConfirmForgotPasswordError error;
  String rawError;
  String rawMessage;
}

class AuthForgotPasswordResult {
  ForgotPasswordState forgotPasswordState;
  UserCodeDeliveryDetails codeDeliveryDetails = new UserCodeDeliveryDetails();
}

class AuthSignUpError {
  SignUpError error;
  String rawError;
  String rawMessage;
}

class AwsCognitoAuthController implements AuthController {
  @override
  initialize({Function(bool) onInitialize}) {
    AwsCognitoAuth.initialize(onResult: (userState) {
      if (userState == UserState.signedIn) {
        onInitialize(true);
      } else {
        onInitialize(false);
      }
    }, onError: (error) {
      onInitialize(false);
    });
  }

  @override
  signUp(
      {String username,
      String password,
      Map attributes,
      Function onSuccess,
      Function(String) onError}) {
    Map userAttributes = parseAttributes(attributes);

    AwsCognitoAuth.signUp(
      username: username,
      password: password,
      userAttributes: userAttributes,
      onResult: (signUpResult) {
        if (onSuccess != null) {
          onSuccess();
        }
      },
      onError: (signUpError) {
        if (onError != null) {
          onError(signUpError.error.toString());
        }
      },
    );
  }

  Map parseAttributes(Map attributes) {
    Map map = {};
    for (String key in attributes.keys) {
      String value = attributes[key];
      if (value == null) continue;

      if (key == "first_name") {
        map.putIfAbsent("given_name", () => attributes[key]);
      } else if (key == "last_name") {
        map.putIfAbsent("family_name", () => attributes[key]);
      } else {
        map.putIfAbsent(key, () => attributes[key]);
      }
    }
    return map;
  }

  @override
  signIn(
      {String username,
      String password,
      Function onSuccess,
      Function(String) onError}) {
    AwsCognitoAuth.signIn(
        username: username,
        password: password,
        onResult: (result) {
          onSuccess();
        },
        onError: (error) {
          onError(error.error.toString());
        });
  }

  @override
  forgotPassword(
      {String username, Function onSuccess, Function(String) onError}) {
    AwsCognitoAuth.forgotPassword(
      username: username,
      onResult: (result) {
        onSuccess();
      },
      onError: (error) {
        onError(error.error.toString());
      },
    );
  }

  @override
  forgotPasswordConfirm(
      {String username,
      String verificationCode,
      String password,
      Function onSuccess,
      Function(String) onError}) {
    AwsCognitoAuth.confirmForgotPassword(
        username: username,
        confirmationCode: verificationCode,
        newPassword: password,
        onResult: (result) {
          onSuccess();
        },
        onError: (error) {
          onError(error.error.toString());
        });
  }

  @override
  changePassword({
    String currentPassword,
    String proposedPassword,
    Function onSuccess,
    Function(String) onError,
  }) {
    AwsCognitoAuth.changePassword(
        currentPassword: currentPassword,
        proposedPassword: proposedPassword,
        onResult: () {
          onSuccess();
        },
        onError: (error) {
          onError(error.error.toString());
        });
  }

  @override
  resendVerification({
    String username,
    Function onResult,
    Function(String) onError,
  }) {
    AwsCognitoAuth.resendSignUpCode(
      username: username,
      onResult: (result) {
        onResult();
      },
      onError: (error) {
        onError(error.error.toString());
      },
    );
  }
}

class AwsCognitoAuth {
  static const MethodChannel _channel = const MethodChannel('aws_cognito_auth');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static TOne stringToEnum<TOne, TTwo>(
      List<TOne> values, List<TTwo> secondaryValues, String str) {
    int index = values.indexWhere((e) => describeEnum(e) == str);
    if (index == -1 && secondaryValues != null) {
      index = secondaryValues.indexWhere((e) => describeEnum(e) == str);
    }
    if (index == -1) {
      index = values.indexWhere((e) => describeEnum(e) == "unknown");
    }
    TOne ret = values[index];
    return ret;
  }

  // initialize (userState, error)
  static Future<void> initialize(
      {Function(UserState) onResult, Function(String) onError}) async {
    Map results = await _channel.invokeMapMethod("initialize");
    if (results.containsKey("result")) {
      print(results);
      UserState userState = stringToEnum<UserState, UserStateAndroid>(
          UserState.values, UserStateAndroid.values, results["result"]);
      onResult(userState);
    } else if (results.containsKey("error")) {
      onError(results["error"]);
    }
  }

  // user state listener (userState)
  static void addUserStateListener({@required Function(Map) onChanged}) {}

  // get sign in state
  static Future<bool> isSignedIn() async {
    return await _channel.invokeMethod("isSignedIn", {});
  }

  // sign up (result, error)
  static void signUp(
      {@required String username,
      @required String password,
      @required Map userAttributes,
      @required Function(AuthSignUpResult) onResult,
      Function(AuthSignUpError) onError}) async {
    if (username == null) username = "";
    if (password == null) password = "";

    username = username.trim().toLowerCase();
    password = password.trim();

    Map results = await _channel.invokeMethod("signUp", {
      "username": username,
      "password": password,
      "userAttributes": userAttributes,
    });

    print(results);

    if (results.containsKey("result")) {
      String destination = results["result"]["destination"];
      String attributeName = results["result"]["attributeName"];
      UserCodeDeliveryMedium deliveryMedium =
          stringToEnum<UserCodeDeliveryMedium, UserCodeDeliveryMedium>(
              UserCodeDeliveryMedium.values,
              null,
              results["result"]["deliveryMedium"]);
      SignUpConfirmationState confirmationState =
          stringToEnum<SignUpConfirmationState, SignUpConfirmationState>(
              SignUpConfirmationState.values,
              null,
              results["result"]["confirmationState"]);

      AuthSignUpResult result = new AuthSignUpResult();
      result.codeDeliveryDetails.destination = destination;
      result.codeDeliveryDetails.attributeName = attributeName;
      result.codeDeliveryDetails.deliveryMedium = deliveryMedium;
      result.signUpConfirmationState = confirmationState;

      onResult(result);
    } else if (results.containsKey("error")) {
      String fullMessage = results["error"];

      String rawError;
      String rawMessage;

      if (Platform.isIOS) {
        rawError = fullMessage.substring(0, fullMessage.indexOf("("));
        rawMessage = fullMessage.substring(
            fullMessage.indexOf("\"") + 1, fullMessage.lastIndexOf("\""));
      } else if (Platform.isAndroid) {
        rawError = fullMessage.substring(
            fullMessage.indexOf("Error Code: ") + 12,
            fullMessage.indexOf("Request ID") - 2);
        rawMessage = fullMessage.substring(fullMessage.indexOf("ion:") + 5,
            fullMessage.lastIndexOf(". (Service"));
      }

      SignUpError error = SignUpError.unknown;

      if (rawError == "invalidParameter") {
        if (rawMessage.contains("password") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 6")) {
          error = SignUpError.passwordLength;
        } else if (rawMessage.contains("username") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 1")) {
          error = SignUpError.usernameLength;
        } else if (rawMessage.contains("The attribute is required")) {
          error = SignUpError.attributeRequired;
        } else if (rawMessage.contains("Invalid email address format")) {
          error = SignUpError.emailInvalid;
        }
      } else if (rawError == "invalidPassword") {
        if (rawMessage.contains("Password not long enough")) {
          error = SignUpError.passwordLength;
        } else if (rawMessage
            .contains("Password must have uppercase characters")) {
          error = SignUpError.passwordUppercase;
        } else if (rawMessage
            .contains("Password must have lowercase characters")) {
          error = SignUpError.passwordLowercase;
        } else if (rawMessage
            .contains("Password must have numeric characters")) {
          error = SignUpError.passwordNumeric;
        } else if (rawMessage
            .contains("Password must have symbol characters")) {
          error = SignUpError.passwordSymbol;
        }
      } else if (rawError == "usernameExists") {
        error = SignUpError.userExists;
      }

      AuthSignUpError result = new AuthSignUpError();
      result.rawError = rawError;
      result.rawMessage = rawMessage;
      result.error = error;

      onError(result);
    }
  }

  // confirm sign up (result, error)
  static void confirmSignUp(
      {@required String username,
      @required String confirmationCode,
      @required Function(AuthSignUpResult) onResult,
      Function(AuthConfirmSignUpError) onError}) async {
    Map results = await _channel.invokeMethod("confirmSignUp", {
      "username": username.trim(),
      "confirmationCode": confirmationCode.trim(),
    });

    if (results.containsKey("result")) {
      String destination = results["result"]["destination"];
      String attributeName = results["result"]["attributeName"];
      UserCodeDeliveryMedium deliveryMedium =
          stringToEnum<UserCodeDeliveryMedium, UserCodeDeliveryMedium>(
              UserCodeDeliveryMedium.values,
              null,
              results["result"]["deliveryMedium"]);
      SignUpConfirmationState confirmationState =
          stringToEnum<SignUpConfirmationState, SignUpConfirmationState>(
              SignUpConfirmationState.values,
              null,
              results["result"]["confirmationState"]);

      AuthSignUpResult result = new AuthSignUpResult();
      result.codeDeliveryDetails.destination = destination;
      result.codeDeliveryDetails.attributeName = attributeName;
      result.codeDeliveryDetails.deliveryMedium = deliveryMedium;
      result.signUpConfirmationState = confirmationState;

      onResult(result);
    } else if (results.containsKey("error")) {
      String fullMessage = results["error"];
      String rawError = fullMessage.substring(0, fullMessage.indexOf("("));
      String rawMessage = fullMessage.substring(
          fullMessage.indexOf("\"") + 1, fullMessage.lastIndexOf("\""));

      ConfirmSignUpError error = ConfirmSignUpError.unknown;

      if (rawError == "invalidParameter") {
        if (rawMessage.contains("username") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 1")) {
          error = ConfirmSignUpError.usernameLength;
        } else if (rawMessage.contains("confirmationCode") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 1")) {
          error = ConfirmSignUpError.confirmationCodeLength;
        }
      } else if (rawError == "userNotFound") {
        error = ConfirmSignUpError.usernameNotFound;
      } else if (rawError == "codeMismatch") {
        error = ConfirmSignUpError.invalidVerificationCode;
      } else if (rawError == "aliasExists") {
        error = ConfirmSignUpError.emailUsed;
      }

      AuthConfirmSignUpError result = new AuthConfirmSignUpError();
      result.rawError = rawError;
      result.rawMessage = rawMessage;
      result.error = error;

      onError(result);
    }
  }

  // resend confirmation for sign up (result, error)
  static void resendSignUpCode(
      {@required String username,
      @required Function(AuthSignUpResult) onResult,
      Function(AuthResendSignUpCodeError) onError}) async {
    Map results = await _channel.invokeMethod("resendSignUpCode", {
      "username": username.trim(),
    });

    if (results.containsKey("result")) {
      String destination = results["result"]["destination"];
      String attributeName = results["result"]["attributeName"];
      UserCodeDeliveryMedium deliveryMedium =
          stringToEnum<UserCodeDeliveryMedium, UserCodeDeliveryMedium>(
              UserCodeDeliveryMedium.values,
              null,
              results["result"]["deliveryMedium"]);
      SignUpConfirmationState confirmationState =
          stringToEnum<SignUpConfirmationState, SignUpConfirmationState>(
              SignUpConfirmationState.values,
              null,
              results["result"]["confirmationState"]);

      AuthSignUpResult result = new AuthSignUpResult();
      result.codeDeliveryDetails.destination = destination;
      result.codeDeliveryDetails.attributeName = attributeName;
      result.codeDeliveryDetails.deliveryMedium = deliveryMedium;
      result.signUpConfirmationState = confirmationState;

      onResult(result);
    } else if (results.containsKey("error")) {
      String fullMessage = results["error"];
      String rawError = fullMessage.substring(0, fullMessage.indexOf("("));
      String rawMessage = fullMessage.substring(
          fullMessage.indexOf("\"") + 1, fullMessage.lastIndexOf("\""));

      ResendSignUpCodeError error = ResendSignUpCodeError.unknown;

      if (rawError == "invalidParameter") {
        if (rawMessage.contains("username") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 1")) {
          error = ResendSignUpCodeError.usernameLength;
        } else if (rawMessage.contains("User is already confirmed")) {
          error = ResendSignUpCodeError.userConfirmed;
        }
      } else if (rawError == "userNotFound") {
        error = ResendSignUpCodeError.usernameNotFound;
      }

      AuthResendSignUpCodeError result = new AuthResendSignUpCodeError();
      result.rawError = rawError;
      result.rawMessage = rawMessage;
      result.error = error;

      onError(result);
    }
  }

  // sign in (result, error)
  static void signIn(
      {@required String username,
      @required String password,
      Map validationData,
      @required Function(AuthSignInResult) onResult,
      Function(AuthSignInError) onError}) async {
    if (username == null) username = "";
    if (password == null) password = "";

    username = username.trim().toLowerCase();
    password = password.trim();

    Map results = await _channel.invokeMethod("signIn", {
      "username": username,
      "password": password,
      "validationData": validationData
    });

    print(results);

    if (results.containsKey("result")) {
      String destination = results["result"]["destination"];
      Map parameters = results["result"]["parameters"];
      String attributeName = results["result"]["attributeName"];
      UserCodeDeliveryMedium deliveryMedium =
          stringToEnum<UserCodeDeliveryMedium, UserCodeDeliveryMedium>(
              UserCodeDeliveryMedium.values,
              null,
              results["result"]["deliveryMedium"]);
      SignInState signInState = stringToEnum<SignInState, SignInStateAndroid>(
          SignInState.values,
          SignInStateAndroid.values,
          results["result"]["signInState"]);

      AuthSignInResult result = new AuthSignInResult();
      result.codeDetails.destination = destination;
      result.codeDetails.attributeName = attributeName;
      result.codeDetails.deliveryMedium = deliveryMedium;
      result.signInState = signInState;
      result.parameters = parameters;

      onResult(result);
    } else if (results.containsKey("error")) {
      String fullMessage = results["error"];

      String rawError;
      String rawMessage;
      if (Platform.isIOS) {
        rawError = fullMessage.substring(0, fullMessage.indexOf("("));
        rawMessage = fullMessage.substring(
            fullMessage.indexOf("\"") + 1, fullMessage.lastIndexOf("\""));
      } else if (Platform.isAndroid) {
        rawError = fullMessage.substring(
            fullMessage.indexOf("Error Code: ") + 12,
            fullMessage.indexOf("Request ID") - 2);
        rawMessage = fullMessage.substring(fullMessage.indexOf("ion:") + 5,
            fullMessage.lastIndexOf(". (Service"));
      }

      SignInError error = SignInError.unknown;

      if (rawError == "invalidParameter") {
        if (rawMessage.contains("Missing required parameter USERNAME")) {
          error = SignInError.usernameMissing;
        }
      } else if (rawError == "userNotFound" ||
          rawError == "UserNotFoundException") {
        error = SignInError.userNotFound;
      } else if (rawError == "userNotConfirmed") {
        error = SignInError.userNotConfirmed;
      } else if (rawError == "notAuthorized" || rawError == "NotAuthorizedException") {
        error = SignInError.incorrectUsernameOrPassword;
      } else if (rawError == "invalidState") {
        if (rawMessage.contains("There is already a user which is signed in")) {
          error = SignInError.userAlreadySignedIn;
        }
      }

      AuthSignInError result = new AuthSignInError();
      result.rawError = rawError;
      result.rawMessage = rawMessage;
      result.error = error;

      onError(result);
    }
  }

  // confirm sign in (result, error)
  static void confirmSignIn(
      {@required Function(Map) onResult, @required Function(Map) onError}) {}

  // sign out [global optional] (error)
  static void signOut({
    @required VoidCallback onResult,
    Function(String) onError,
    bool globally = false,
    bool invalidateTokens = true,
  }) async {
    Map results = await _channel.invokeMethod("signOut", {
      "globally": globally,
      "invalidateTokens": invalidateTokens,
    });

    if (results.containsKey("result")) {
      onResult();
    } else if (results.containsKey("error")) {
      onError(results["error"]);
    }
  }

  // forgot password (result, error)
  static void forgotPassword(
      {@required String username,
      @required Function(AuthForgotPasswordResult) onResult,
      Function(AuthForgotPasswordError) onError}) async {
    Map results = await _channel.invokeMethod("forgotPassword", {
      "username": username.trim().toLowerCase(),
    });

    if (results.containsKey("result")) {
      String destination = results["result"]["destination"];
      String attributeName = results["result"]["attributeName"];
      UserCodeDeliveryMedium deliveryMedium =
          stringToEnum<UserCodeDeliveryMedium, UserCodeDeliveryMedium>(
              UserCodeDeliveryMedium.values,
              null,
              results["result"]["deliveryMedium"]);
      ForgotPasswordState forgotPasswordState =
          stringToEnum<ForgotPasswordState, ForgotPasswordState>(
              ForgotPasswordState.values,
              null,
              results["result"]["forgotPasswordState"]);

      AuthForgotPasswordResult result = new AuthForgotPasswordResult();
      result.codeDeliveryDetails.destination = destination;
      result.codeDeliveryDetails.attributeName = attributeName;
      result.codeDeliveryDetails.deliveryMedium = deliveryMedium;
      result.forgotPasswordState = forgotPasswordState;

      onResult(result);
    } else if (results.containsKey("error")) {
      String fullMessage = results["error"];
      String rawError = fullMessage.substring(0, fullMessage.indexOf("("));
      String rawMessage = fullMessage.substring(
          fullMessage.indexOf("\"") + 1, fullMessage.lastIndexOf("\""));

      ForgotPasswordError error = ForgotPasswordError.unknown;

      if (rawError == "invalidParameter") {
        if (rawMessage.contains(
            "failed to satisfy constraint: Member must have length greater than or equal to 1")) {
          error = ForgotPasswordError.usernameLength;
        } else if (rawMessage.contains(
            "Cannot reset password for the user as there is no registered")) {
          error = ForgotPasswordError.notVerified;
        }
      } else if (rawError == "userNotFound") {
        error = ForgotPasswordError.userNotFound;
      }

      AuthForgotPasswordError result = new AuthForgotPasswordError();
      result.rawError = rawError;
      result.rawMessage = rawMessage;
      result.error = error;

      onError(result);
    }
  }

  // confirm forgot password (result, error)
  static void confirmForgotPassword(
      {@required String username,
      @required String newPassword,
      @required String confirmationCode,
      @required Function(AuthForgotPasswordResult) onResult,
      Function(AuthConfirmForgotPasswordError) onError}) async {
    Map results = await _channel.invokeMethod("confirmForgotPassword", {
      "username": username.trim().toLowerCase(),
      "newPassword": newPassword.trim(),
      "confirmationCode": confirmationCode.trim()
    });

    if (results.containsKey("result")) {
      String destination = results["result"]["destination"];
      String attributeName = results["result"]["attributeName"];
      UserCodeDeliveryMedium deliveryMedium =
          stringToEnum<UserCodeDeliveryMedium, UserCodeDeliveryMedium>(
              UserCodeDeliveryMedium.values,
              null,
              results["result"]["deliveryMedium"]);
      ForgotPasswordState forgotPasswordState =
          stringToEnum<ForgotPasswordState, ForgotPasswordState>(
              ForgotPasswordState.values,
              null,
              results["result"]["forgotPasswordState"]);

      AuthForgotPasswordResult result = new AuthForgotPasswordResult();
      result.codeDeliveryDetails.destination = destination;
      result.codeDeliveryDetails.attributeName = attributeName;
      result.codeDeliveryDetails.deliveryMedium = deliveryMedium;
      result.forgotPasswordState = forgotPasswordState;

      onResult(result);
    } else if (results.containsKey("error")) {
      String fullMessage = results["error"];
      String rawError = fullMessage.substring(0, fullMessage.indexOf("("));
      String rawMessage = fullMessage.substring(
          fullMessage.indexOf("\"") + 1, fullMessage.lastIndexOf("\""));

      ConfirmForgotPasswordError error = ConfirmForgotPasswordError.unknown;

      if (rawError == "invalidParameter") {
        if (rawMessage.contains("username") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 1")) {
          error = ConfirmForgotPasswordError.usernameLength;
        } else if (rawMessage.contains("password") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 6")) {
          error = ConfirmForgotPasswordError.passwordLength;
        } else if (rawMessage.contains("confirmationCode") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 1")) {
          error = ConfirmForgotPasswordError.confirmationCodeLength;
        }
      } else if (rawError == "userNotFound") {
        error = ConfirmForgotPasswordError.userNotFound;
      } else if (rawError == "expiredCode" || rawError == "codeMismatch") {
        error = ConfirmForgotPasswordError.invalidCode;
      } else if (rawError == "invalidPassword") {
        if (rawMessage.contains("Password not long enough")) {
          error = ConfirmForgotPasswordError.passwordLength;
        } else if (rawMessage
            .contains("Password must have uppercase characters")) {
          error = ConfirmForgotPasswordError.passwordUppercase;
        } else if (rawMessage
            .contains("Password must have lowercase characters")) {
          error = ConfirmForgotPasswordError.passwordLowercase;
        } else if (rawMessage
            .contains("Password must have numeric characters")) {
          error = ConfirmForgotPasswordError.passwordNumeric;
        } else if (rawMessage
            .contains("Password must have symbol characters")) {
          error = ConfirmForgotPasswordError.passwordSymbol;
        }
      }

      AuthConfirmForgotPasswordError result =
          new AuthConfirmForgotPasswordError();
      result.rawError = rawError;
      result.rawMessage = rawMessage;
      result.error = error;

      onError(result);
    }
  }

  // change password (result, error)
  static void changePassword(
      {@required String currentPassword,
      @required String proposedPassword,
      @required VoidCallback onResult,
      Function(AuthChangePasswordError) onError}) async {
    Map results = await _channel.invokeMethod("changePassword", {
      "currentPassword": currentPassword.trim(),
      "proposedPassword": proposedPassword.trim(),
    });

    if (results.containsKey("result")) {
      onResult();
    } else if (results.containsKey("error")) {
      String fullMessage = results["error"];
      String rawError = fullMessage.substring(0, fullMessage.indexOf("("));
      String rawMessage = fullMessage.substring(
          fullMessage.indexOf("\"") + 1, fullMessage.lastIndexOf("\""));

      ChangePasswordError error = ChangePasswordError.unknown;

      if (rawError == "invalidParameter") {
        if (rawMessage.contains("previousPassword") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 6")) {
          error = ChangePasswordError.incorrectPassword;
        } else if (rawMessage.contains("proposedPassword") &&
            rawMessage.contains(
                "failed to satisfy constraint: Member must have length greater than or equal to 6")) {
          error = ChangePasswordError.passwordLength;
        }
      } else if (rawError == "notSignedIn") {
        error = ChangePasswordError.notSignedIn;
      } else if (rawError == "notAuthorized") {
        error = ChangePasswordError.incorrectPassword;
      } else if (rawError == "invalidPassword") {
        if (rawMessage.contains("Password not long enough")) {
          error = ChangePasswordError.passwordLength;
        } else if (rawMessage
            .contains("Password must have uppercase characters")) {
          error = ChangePasswordError.passwordUppercase;
        } else if (rawMessage
            .contains("Password must have lowercase characters")) {
          error = ChangePasswordError.passwordLowercase;
        } else if (rawMessage
            .contains("Password must have numeric characters")) {
          error = ChangePasswordError.passwordNumeric;
        } else if (rawMessage
            .contains("Password must have symbol characters")) {
          error = ChangePasswordError.passwordSymbol;
        }
      }

      AuthChangePasswordError result = new AuthChangePasswordError();
      result.rawError = rawError;
      result.rawMessage = rawMessage;
      result.error = error;

      onError(result);
    }
  }

  // get username
  static Future<String> getUsername() async {
    var result = await _channel.invokeMethod<String>("getUsername");

    return result;
  }

  // get attribute
  static void getAttribute(
      {@required Function(Map) onResult, @required Function(Map) onError}) {}

  // set attribute
  static void setAttribute(
      {@required Function(Map) onResult, @required Function(Map) onError}) {}

  // get attributes
  static void getAttributes(
      {@required Function(Map) onResult, @required Function(Map) onError}) {}

  // set attributes
  static void setAttributes(
      {@required Function(Map) onResult, @required Function(Map) onError}) {}
}
