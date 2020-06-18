import 'dart:async';
import 'package:flutter/services.dart';

class AwsCognitoAuth {
  static const MethodChannel _channel = const MethodChannel('aws_cognito_auth');

  static Future<AuthSignUpResult> signUp(String username, String password, String email) async {
    var result = await _channel.invokeMapMethod<String, dynamic>("signUp", {
      "username": username,
      "password": password,
      "email": email,
    });

    return AuthSignUpResult(isSignUpComplete: result["isSignUpComplete"]);
  }
}

class AuthSignUpResult {
  final bool isSignUpComplete;

  AuthSignUpResult({this.isSignUpComplete = false});
}