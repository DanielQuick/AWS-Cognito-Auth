import Flutter
import UIKit
import Amplify
import AmplifyPlugins

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
            case "signOut":
                signOut(call: call, result: result)
                break
            case "forgotPassword":
                forgotPassword(call: call, result: result)
                break
            case "confirmForgotPassword":
                confirmForgotPassword(call: call, result: result)
                break
            case "isSignedIn":
                isSignedIn(call: call, result: result)
                break
            case "changePassword":
                changePassword(call: call, result: result)
                break
            case "getUsername":
                getUsername(call: call, result: result)
                break;
            case "getUserAttributes":
                getUserAttributes(call: call, result: result);
                break;
            default:
                result(nil);
        }
    }

    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            DispatchQueue.main.async {
                result(true)
            }
        } catch {
            DispatchQueue.main.async {
                result(FlutterError(code: "Failed to add cognito plugin",
                            message: "",
                            details: error.toString()))
            }
        }
    }

    func convertSignUpResult(_ result: AuthSignUpResult) -> [String:Any] {
        var dict = [String:Any]()
        dict["isSignUpComplete"] = result.isSignUpComplete
        return dict
    }

    func convertSignInResult(_ result: AuthSignInResult) -> [String:Any] {
        var dict = [String:Any]()
        dict["isSignInComplete"] = result.isSignInComplete
        return dict
    }

    func convertResetPasswordResult(_ result: AuthResetPasswordResult) -> [String:Any] {
        var dict = [String:Any]()
        dict["isPasswordReset"] = result.isPasswordReset
        return dict
    }

    func signUp(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            var password = ""

            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }

            if let arg = arguments["password"], let val = arg as? String {
                password = val
            }

            let userAttributes = [AuthUserAttribute]()

            if let arg = arguments["email"], let val = arg as? String {
                userAttributes.add(AuthUserAttribute(.email, value: val))
            }
            if let arg = arguments["name"], let val = arg as? String {
                userAttributes.add(AuthUserAttribute(.email, value: val))
            }
            if let arg = arguments["givenName"], let val = arg as? String {
                userAttributes.add(AuthUserAttribute(.email, value: val))
            }
            if let arg = arguments["familyName"], let val = arg as? String {
                userAttributes.add(AuthUserAttribute(.email, value: val))
            }

            let options = AuthSignUpRequest.Options(userAttributes: userAttributes)

            Amplify.Auth.signUp(username: username, password: password, options: options) { result in
                switch result {
                    case .success(let signUpResult):
                        DispatchQueue.main.async {
                            result(convertSignUpResult(signUpResult))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            result(FlutterError(code: "Failed to sign up",
                                        message: "",
                                        details: error.toString()))
                        }
                }
            }
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

            Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
                switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            result(convertSignUpResult(signUpResult))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            result(FlutterError(code: "Failed to confirm sign up",
                                        message: "",
                                        details: error.toString()))
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

            Amplify.Auth.resendSignUpCode(for: username) { result in
                switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            result(convertSignUpResult(signUpResult))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            result(FlutterError(code: "Failed to resend sign up code",
                                        message: "",
                                        details: error.toString()))
                        }
                }
            }
        }
    }

    func signIn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            var password = ""
            
            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }
            if let arg = arguments["password"], let val = arg as? String {
                password = val
            }

            Amplify.Auth.signIn(username: username, password: password) { result in
                switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            result(convertSignInResult(signUpResult))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            result(FlutterError(code: "Failed to sign in",
                                        message: "",
                                        details: error.toString()))
                        }
                }
            }
        }
    }

    func signOut(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Amplify.Auth.signOut() { result in
            switch result {
                case .success:
                    DispatchQueue.main.async {
                        result(true)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        result(FlutterError(code: "Failed to sign out",
                                    message: "",
                                    details: error.toString()))
                    }
            }
        }
    }

    func resetPassword(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            
            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }

            Amplify.Auth.resetPassword(for: username) { result in
                do {
                    let resetResult = try result.get()
                    DispatchQueue.main.async {
                        result(convertResetPasswordResult(resetResult))
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "Failed to reset password",
                                message: "",
                                details: error.toString()))
                    }
                }
            }
        }
    }

    func confirmResetPassword(call: FlutterMethodCall, result: @escaping FlutterResult) {
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

            Amplify.Auth.confirmResetPassword(
                for: username,
                with: newPassword,
                confirmationCode: confirmationCode) { result in
                    switch result {
                        case .success:
                            DispatchQueue.main.async {
                                result(true)
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                result(FlutterError(code: "Failed to confirm reset password",
                                        message: "",
                                        details: error.toString()))
                            }
                    }
            }
        }
    }

    func isSignedIn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Amplify.Auth.fetchAuthSession { result in
            switch result {
                case .success(let session):
                    DispatchQueue.main.async {
                        result(session.isSignedIn)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        result(FlutterError(code: "Failed to fetch auth session",
                            message: "",
                            details: error.toString()))
                    }
            }
        }
    }

    func updatePassword(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var password = ""
            var newPassword = ""
            
            if let arg = arguments["password"], let val = arg as? String {
                password = val
            }
            if let arg = arguments["newPassword"], let val = arg as? String {
                newPassword = val
            }

            Amplify.Auth.update(oldPassword: oldPassword, to: newPassword) { result in
                switch result {
                    case .success:
                        DispatchQueue.main.async {
                            result(true)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            result(FlutterError(code: "Failed to update password",
                                    message: "",
                                    details: error.toString()))
                        }
                }
            }
        }
    }

    func getUserAttributes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Amplify.Auth.fetchUserAttributes() { result in
            switch result {
                case .success(let attributes):
                    DispatchQueue.main.async {
                        result(convertAttributesArray(attributes))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        result(FlutterError(code: "Failed to fetch user attributes",
                                message: "",
                                details: error.toString()))
                    }
            }
        }
    }

    func convertAttributesArray(_ attributes: [AuthUserAttribute ]) -> [String:String] {
        var dict = [String:String]()
        for attribute in attributes {
            dict[attribute.key.toString()] = attribute.value
        }
        return dict
    }
}
