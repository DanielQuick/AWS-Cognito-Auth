import Flutter
import UIKit
import AWSMobileClient

public class SwiftAwsCognitoAuthPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "aws_cognito_auth", binaryMessenger: registrar.messenger())
    let instance = SwiftAwsCognitoAuthPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch call.method {

    case "initialize":
      initialize(call: call, result: result)
      break
    case "signUp":
      signUp(call: call, result: result)
      break
     case "confirmSignUp":
       confirmSignUp(call: call, result: result)
       break
     case "resendSignUpCode":
       resendSignUpCode(call: call, result: result)
       break
     case "signIn":
       signIn(call: call, result: result)
       break
    // case "confirmSignIn":
    //   confirmSignIn(call: call, result: result);
    //   break;
     case "signOut":
       signOut(call: call, result: result)
       break
     case "forgotPassword":
       forgotPassword(call: call, result: result)
       break
     case "confirmForgotPassword":
       confirmForgotPassword(call: call, result: result)
       break
    // case "addUserStateListener":
    //   addUserStateListener(call: call, result: result);
    //   break;
     case "isSignedIn":
       isSignedIn(call: call, result: result)
       break
     case "changePassword":
       changePassword(call: call, result: result)
       break
    case "getUsername":
        getUsername(call: call, result: result)
       break;
    // case "getAttributes":
    //   getAttributes(call: call, result: result);
    //   break;
    // case "setAttributes":
    //   setAttributes(call: call, result: result);
    //   break;
      
    default:
      result(nil);
    }
  }

  func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
    AWSMobileClient.sharedInstance().initialize { (userState, error) in
      if let userState = userState {
        result(["result": userState.rawValue]);
      } else if let error = error {
        result(["error": error.localizedDescription])
      }
    }
  }

  func signUp(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let arguments = call.arguments as? NSDictionary {
      var username = ""
      var password = ""
      var userAttributes = NSDictionary()

      if let arg = arguments["username"], let val = arg as? String {
        username = val
      }

      if let arg = arguments["password"], let val = arg as? String {
        password = val
      }
        
      if let arg = arguments["userAttributes"], let val = arg as? NSDictionary {
        userAttributes = val
      }

      AWSMobileClient.sharedInstance().signUp(username: username,
                                          password: password,
                                          userAttributes: userAttributes as! Dictionary<String,String>) { (signUpResult, error) in
        if let signUpResult = signUpResult {
            
            var destination = ""
            var attributeName = ""
            var deliveryMedium = "unknown"
            
            if let codeDeliveryDetails = signUpResult.codeDeliveryDetails {
                deliveryMedium = String(describing: codeDeliveryDetails.deliveryMedium)
                if let val = codeDeliveryDetails.destination {
                    destination = val
                }
                if let val = codeDeliveryDetails.attributeName {
                    attributeName = val
                }
            }

          var returnValue : [String:NSDictionary] = [
            "result": [
              "confirmationState": String(describing: signUpResult.signUpConfirmationState),
              "deliveryMedium": deliveryMedium,
              "destination": destination,
              "attributeName": attributeName
            ]
          ]
          
            result(returnValue);
        } else if let error = error {
             if let error = error as? AWSMobileClientError {
                var errorInfo = String(describing: error)
                
                var returnValue : [String:Any] = [
                    "error": errorInfo
                ]
                
                result(returnValue);
             } else {
                var returnValue : [String:Any] = [
                    "error": error.localizedDescription
                ]
                
                result(returnValue);
            }
        }
      }
    } else {
      var returnValue : [String:Any] = [
        "error": "No arguments provided",
      ]
      result(returnValue)
    }
  }

   func confirmSignUp(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            var confirmationCode = ""
            
            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }
            
            if let arg = arguments["confirmationCode"], let val = arg as? String {
                confirmationCode = val
            }
            
             AWSMobileClient.sharedInstance().confirmSignUp(username: username, confirmationCode: confirmationCode) { (signUpResult, error) in
               if let signUpResult = signUpResult {
                
                var destination = ""
                var attributeName = ""
                var deliveryMedium = "unknown"
                
                if let codeDeliveryDetails = signUpResult.codeDeliveryDetails {
                    deliveryMedium = String(describing: codeDeliveryDetails.deliveryMedium)
                    if let val = codeDeliveryDetails.destination {
                        destination = val
                    }
                    if let val = codeDeliveryDetails.attributeName {
                        attributeName = val
                    }
                }
                var returnValue : [String:NSDictionary] = [
                    "result": [
                        "confirmationState": String(describing: signUpResult.signUpConfirmationState),
                        "deliveryMedium": deliveryMedium,
                        "destination": destination,
                        "attributeName": attributeName
                    ]
                ]
                
                result(returnValue);
               } else if let error = error {
                if let error = error as? AWSMobileClientError {
                    var errorInfo = String(describing: error)
                    
                    var returnValue : [String:Any] = [
                        "error": errorInfo
                    ]
                    
                    result(returnValue);
                } else {
                    var returnValue : [String:Any] = [
                        "error": error.localizedDescription
                    ]
                    
                    result(returnValue);
                }
               }
             }
        }
   }

   func resendSignUpCode(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let arguments = call.arguments as? NSDictionary {
        var username = ""
        
        if let arg = arguments["username"], let val = arg as? String {
            username = val
        }
        AWSMobileClient.sharedInstance().resendSignUpCode(username: username, completionHandler: { (resendSignUpCodeResult, error) in
           if let signUpResult = resendSignUpCodeResult {
                var destination = ""
                var attributeName = ""
                var deliveryMedium = "unknown"
            
                if let codeDeliveryDetails = signUpResult.codeDeliveryDetails {
                    deliveryMedium = String(describing: codeDeliveryDetails.deliveryMedium)
                    if let val = codeDeliveryDetails.destination {
                        destination = val
                    }
                    if let val = codeDeliveryDetails.attributeName {
                        attributeName = val
                    }
                }
                var returnValue : [String:NSDictionary] = [
                    "result": [
                        "confirmationState": String(describing: signUpResult.signUpConfirmationState),
                        "deliveryMedium": deliveryMedium,
                        "destination": destination,
                        "attributeName": attributeName
                    ]
                ]
            
                result(returnValue);
           } else if let error = error {
            if let error = error as? AWSMobileClientError {
                var errorInfo = String(describing: error)
                
                var returnValue : [String:Any] = [
                    "error": errorInfo
                ]
                
                result(returnValue);
            } else {
                var returnValue : [String:Any] = [
                    "error": error.localizedDescription
                ]
                
                result(returnValue);
            }
           }
         })
    }
   }

   func signIn(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let arguments = call.arguments as? NSDictionary {
        var username = ""
        var password = ""
        var validationData = NSDictionary()
        
        if let arg = arguments["username"], let val = arg as? String {
            username = val
        }
        if let arg = arguments["password"], let val = arg as? String {
            password = val
        }
        if let arg = arguments["validationData"], let val = arg as? NSDictionary {
            validationData = val
        }
        
        AWSMobileClient.sharedInstance().signIn(username: username, password: password, validationData: validationData as! Dictionary<String,String>) { (signInResult, error) in
           if let error = error  {
            if let error = error as? AWSMobileClientError {
                var errorInfo = String(describing: error)
                
                var returnValue : [String:Any] = [
                    "error": errorInfo
                ]
                
                result(returnValue);
            } else {
                var returnValue : [String:Any] = [
                    "error": error.localizedDescription
                ]
                
                result(returnValue);
            }
           } else if let signInResult = signInResult {
                var destination = ""
                var attributeName = ""
                var deliveryMedium = "unknown"
            
                if let codeDeliveryDetails = signInResult.codeDetails {
                    deliveryMedium = String(describing: codeDeliveryDetails.deliveryMedium)
                    if let val = codeDeliveryDetails.destination {
                        destination = val
                    }
                    if let val = codeDeliveryDetails.attributeName {
                        attributeName = val
                    }
                }
                var returnValue : [String:NSDictionary] = [
                    "result": [
                        "signInState": String(describing: signInResult.signInState),
                        "parameters": signInResult.parameters,
                        "deliveryMedium": deliveryMedium,
                        "destination": destination,
                        "attributeName": attributeName
                    ]
                ]
            
                result(returnValue);
           }
         }
    }
   }

  // func confirmSignIn(call: FlutterMethodCall, result: @escaping FlutterResult) {
  //   AWSMobileClient.sharedInstance().confirmSignIn(challengeResponse: "code_here") { (signInResult, error) in
  //     if let error = error  {
  //       print("\(error.localizedDescription)")
  //     } else if let signInResult = signInResult {
  //       switch (signInResult.signInState) {
  //       case .signedIn:
  //         print("User is signed in.")
  //       default:
  //         print("\(signInResult.signInState.rawValue)")
  //       }
  //     }
  //   }
  // }

   func signOut(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let arguments = call.arguments as? NSDictionary {
        var globally = false
        var invalidateTokens = true
        
        if let arg = arguments["globally"], let val = arg as? Bool {
            globally = val
        }
        if let arg = arguments["invalidateTokens"], let val = arg as? Bool {
            invalidateTokens = val
        }
        
        let options = SignOutOptions(signOutGlobally: globally, invalidateTokens: invalidateTokens)
        
        AWSMobileClient.sharedInstance().signOut(options: options) { (error) in
//            if let error = error {
//                if let error = error as? AWSMobileClientError {
//                    var errorInfo = String(describing: error)
//
//                    var returnValue : [String:Any] = [
//                        "error": errorInfo
//                    ]
//
//                    result(returnValue);
//                } else {
//                    var returnValue : [String:Any] = [
//                        "error": error.localizedDescription
//                    ]
//
//                    result(returnValue);
//                }
//            } else {
//                var returnValue : [String:NSDictionary] = [
//                    "result": [:]
//                ]
//
//                result(returnValue);
//            }
        }
        
        var returnValue : [String:NSDictionary] = [
            "result": [:]
        ]
        
        result(returnValue);
    }
    
   }

   func forgotPassword(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let arguments = call.arguments as? NSDictionary {
        var username = ""
        
        if let arg = arguments["username"], let val = arg as? String {
            username = val
        }
     AWSMobileClient.sharedInstance().forgotPassword(username: username) { (forgotPasswordResult, error) in
       if let forgotPasswordResult = forgotPasswordResult {
        var destination = ""
        var attributeName = ""
        var deliveryMedium = "unknown"
        
        if let codeDeliveryDetails = forgotPasswordResult.codeDeliveryDetails {
            deliveryMedium = String(describing: codeDeliveryDetails.deliveryMedium)
            if let val = codeDeliveryDetails.destination {
                destination = val
            }
            if let val = codeDeliveryDetails.attributeName {
                attributeName = val
            }
        }
        var returnValue : [String:NSDictionary] = [
            "result": [
                "forgotPasswordState": String(describing: forgotPasswordResult.forgotPasswordState),
                "deliveryMedium": deliveryMedium,
                "destination": destination,
                "attributeName": attributeName
            ]
        ]
        
        result(returnValue);
       } else if let error = error {
        if let error = error as? AWSMobileClientError {
            var errorInfo = String(describing: error)
            
            var returnValue : [String:Any] = [
                "error": errorInfo
            ]
            
            result(returnValue);
        } else {
            var returnValue : [String:Any] = [
                "error": error.localizedDescription
            ]
            
            result(returnValue);
        }
       }
     }
    }
   }

   func confirmForgotPassword(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let arguments = call.arguments as? NSDictionary {
        var username = ""
        var newPassword = ""
        var confirmationCode = ""
        
        if let arg = arguments["username"], let val = arg as? String {
            username = val
        }
        if let arg = arguments["newPassword"], let val = arg as? String {
            newPassword = val
        }
        if let arg = arguments["confirmationCode"], let val = arg as? String {
            confirmationCode = val
        }
     AWSMobileClient.sharedInstance().confirmForgotPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode) { (forgotPasswordResult, error) in
       if let forgotPasswordResult = forgotPasswordResult {
        var destination = ""
        var attributeName = ""
        var deliveryMedium = "unknown"
        
        if let codeDeliveryDetails = forgotPasswordResult.codeDeliveryDetails {
            deliveryMedium = String(describing: codeDeliveryDetails.deliveryMedium)
            if let val = codeDeliveryDetails.destination {
                destination = val
            }
            if let val = codeDeliveryDetails.attributeName {
                attributeName = val
            }
        }
        var returnValue : [String:NSDictionary] = [
            "result": [
                "forgotPasswordState": String(describing: forgotPasswordResult.forgotPasswordState),
                "deliveryMedium": deliveryMedium,
                "destination": destination,
                "attributeName": attributeName
            ]
        ]
        
        result(returnValue);
       } else if let error = error {
        if let error = error as? AWSMobileClientError {
            var errorInfo = String(describing: error)
            
            var returnValue : [String:Any] = [
                "error": errorInfo
            ]
            
            result(returnValue);
        } else {
            var returnValue : [String:Any] = [
                "error": error.localizedDescription
            ]
            
            result(returnValue);
        }
       }
     }
    }
   }

  // func addUserStateListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
  //   AWSMobileClient.sharedInstance().addUserStateListener(self) { (userState, info) in
  //     switch (userState) {
  //     case .guest:
  //       print("user is in guest mode.")
  //     case .signedOut:
  //       print("user signed out")
  //     case .signedIn:
  //       print("user is signed in.")
  //     case .signedOutUserPoolsTokenInvalid:
  //       print("need to login again.")
  //     case .signedOutFederatedTokensInvalid:
  //       print("user logged in via federation, but currently needs new tokens")
  //     default:
  //       print("unsupported")
  //     }
  //   }
  // }

   func isSignedIn(call: FlutterMethodCall, result: @escaping FlutterResult) {
     result(AWSMobileClient.sharedInstance().isSignedIn)
   }

   func changePassword(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let arguments = call.arguments as? NSDictionary {
        var currentPassword = ""
        var proposedPassword = ""
        
        if let arg = arguments["currentPassword"], let val = arg as? String {
            currentPassword = val
        }
        if let arg = arguments["proposedPassword"], let val = arg as? String {
            proposedPassword = val
        }
        
        AWSMobileClient.sharedInstance().changePassword(currentPassword: currentPassword, proposedPassword: proposedPassword) { (error) in
            if let error = error {
                if let error = error as? AWSMobileClientError {
                    var errorInfo = String(describing: error)
                    
                    var returnValue : [String:Any] = [
                        "error": errorInfo
                    ]
                    
                    result(returnValue);
                } else {
                    var returnValue : [String:Any] = [
                        "error": error.localizedDescription
                    ]
                    
                    result(returnValue);
                }
            } else {
                var returnValue : [String:Any] = [
                    "result": "true"
                ]
                
                result(returnValue);
            }
        }
    }
   }

   func getUsername(call: FlutterMethodCall, result: @escaping FlutterResult) {
     result(AWSMobileClient.sharedInstance().username)
   }

  // func getAttributes(call: FlutterMethodCall, result: @escaping FlutterResult) {

  // }

  // func setAttributes(call: FlutterMethodCall, result: @escaping FlutterResult) {

  // }

}
