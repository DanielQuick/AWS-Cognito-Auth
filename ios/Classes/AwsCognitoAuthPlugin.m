#import "AwsCognitoAuthPlugin.h"
#import <aws_cognito_auth/aws_cognito_auth-Swift.h>

@implementation AwsCognitoAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwsCognitoAuthPlugin registerWithRegistrar:registrar];
}
@end
