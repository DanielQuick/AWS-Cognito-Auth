import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_cognito_auth/aws_cognito_auth.dart';

void main() {
  const MethodChannel channel = MethodChannel('aws_cognito_auth');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AwsCognitoAuth.platformVersion, '42');
  });
}
