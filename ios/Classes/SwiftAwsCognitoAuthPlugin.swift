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
                initialize(call: call, flutterResult: result)
                break
            case "signUp":
                signUp(call: call, flutterResult: result)
                break
            case "confirmSignUp":
                confirmSignUp(call: call, flutterResult: result)
                break
            case "resendSignUpCode":
                resendSignUpCode(call: call, flutterResult: result)
                break
            case "signIn":
                signIn(call: call, flutterResult: result)
                break
            case "signOut":
                signOut(call: call, flutterResult: result)
                break
            case "resetPassword":
                resetPassword(call: call, flutterResult: result)
                break
            case "confirmResetPassword":
                confirmResetPassword(call: call, flutterResult: result)
                break
            case "isSignedIn":
                isSignedIn(call: call, flutterResult: result)
                break
            case "updatePassword":
                updatePassword(call: call, flutterResult: result)
                break
            case "getUserAttributes":
                getUserAttributes(call: call, flutterResult: result);
                break;
            default:
                result(FlutterMethodNotImplemented);
        }
    }

    func initialize(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            DispatchQueue.main.async {
                flutterResult(true)
            }
        } catch {
            DispatchQueue.main.async {
                flutterResult(FlutterError(code: "Failed to add cognito plugin",
                            message: "",
                            details: error))
            }
        }
    }

    func convertSignUpResult(_ result: AuthSignUpResult) -> [String:Any] {
        var dict = [String:Any]()
        dict["isSignUpComplete"] = result.isSignupComplete
        return dict
    }

    func convertSignInResult(_ result: AuthSignInResult) -> [String:Any] {
        var dict = [String:Any]()
        dict["isSignInComplete"] = result.isSignedIn
        return dict
    }

    func convertResetPasswordResult(_ result: AuthResetPasswordResult) -> [String:Any] {
        var dict = [String:Any]()
        dict["isPasswordReset"] = result.isPasswordReset
        return dict
    }

    func signUp(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            var password = ""

            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }

            if let arg = arguments["password"], let val = arg as? String {
                password = val
            }

            var userAttributes = [AuthUserAttribute]()

            if let arg = arguments["email"], let val = arg as? String {
                userAttributes.append(AuthUserAttribute(.email, value: val))
            }
            if let arg = arguments["name"], let val = arg as? String {
                userAttributes.append(AuthUserAttribute(.name, value: val))
            }
            if let arg = arguments["givenName"], let val = arg as? String {
                userAttributes.append(AuthUserAttribute(.givenName, value: val))
            }
            if let arg = arguments["familyName"], let val = arg as? String {
                userAttributes.append(AuthUserAttribute(.familyName, value: val))
            }

            let options = AuthSignUpRequest.Options(userAttributes: userAttributes)

            _ = Amplify.Auth.signUp(username: username, password: password, options: options) { result in
                switch result {
                    case .success(let signUpResult):
                        DispatchQueue.main.async {
                            flutterResult(self.convertSignUpResult(signUpResult))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            flutterResult(FlutterError(code: "Failed to sign up",
                                        message: error.localizedDescription + " " + error.recoverySuggestion,
                                        details: nil))
                        }
                }
            }
        }
    }

    func confirmSignUp(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            var confirmationCode = ""
            
            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }
            
            if let arg = arguments["confirmationCode"], let val = arg as? String {
                confirmationCode = val
            }

            _ = Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
                switch result {
                    case .success(let result):
                        DispatchQueue.main.async {
                            flutterResult(self.convertSignUpResult(result))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            flutterResult(FlutterError(code: "Failed to confirm sign up",
                                        message: error.localizedDescription,
                                        details: nil))
                        }
                }
            }
        }
    }  

    func resendSignUpCode(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            
            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }

            _ = Amplify.Auth.resendSignUpCode(for: username) { result in
                switch result {
                    
                    case .success(_):
                        DispatchQueue.main.async {
                            flutterResult(true)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            flutterResult(FlutterError(code: "Failed to resend sign up code",
                                        message: error.localizedDescription,
                                        details: nil))
                        }
                }
            }
        }
    }

    func signIn(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            var password = ""
            
            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }
            if let arg = arguments["password"], let val = arg as? String {
                password = val
            }

            _ = Amplify.Auth.signIn(username: username, password: password) { result in
                switch result {
                    case .success(let result):
                        DispatchQueue.main.async {
                            flutterResult(self.convertSignInResult(result))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            flutterResult(FlutterError(code: "Failed to sign in",
                                        message: error.localizedDescription,
                                        details: nil))
                        }
                }
            }
        }
    }

    func signOut(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        _ = Amplify.Auth.signOut() { result in
            switch result {
                case .success:
                    DispatchQueue.main.async {
                        flutterResult(true)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        flutterResult(FlutterError(code: "Failed to sign out",
                                    message: error.localizedDescription,
                                    details: nil))
                    }
            }
        }
    }

    func resetPassword(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var username = ""
            
            if let arg = arguments["username"], let val = arg as? String {
                username = val
            }

            _ = Amplify.Auth.resetPassword(for: username) { result in
                do {
                    let resetResult = try result.get()
                    DispatchQueue.main.async {
                        flutterResult(self.convertResetPasswordResult(resetResult))
                    }
                } catch {
                    DispatchQueue.main.async {
                        flutterResult(FlutterError(code: "Failed to reset password",
                                message: error.localizedDescription,
                                details: nil))
                    }
                }
            }
        }
    }

    func confirmResetPassword(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
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

            _ = Amplify.Auth.confirmResetPassword(
                for: username,
                with: newPassword,
                confirmationCode: confirmationCode) { result in
                    switch result {
                        case .success:
                            DispatchQueue.main.async {
                                flutterResult(true)
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                flutterResult(FlutterError(code: "Failed to confirm reset password",
                                        message: error.localizedDescription,
                                        details: nil))
                            }
                    }
            }
        }
    }

    func isSignedIn(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        _ = Amplify.Auth.fetchAuthSession { result in
            switch result {
                case .success(let session):
                    DispatchQueue.main.async {
                        flutterResult(session.isSignedIn)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        flutterResult(FlutterError(code: "Failed to fetch auth session",
                            message: error.localizedDescription,
                            details: nil))
                    }
            }
        }
    }

    func updatePassword(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if let arguments = call.arguments as? NSDictionary {
            var password = ""
            var newPassword = ""
            
            if let arg = arguments["password"], let val = arg as? String {
                password = val
            }
            if let arg = arguments["newPassword"], let val = arg as? String {
                newPassword = val
            }

            _ = Amplify.Auth.update(oldPassword: password, to: newPassword) { result in
                switch result {
                    case .success:
                        DispatchQueue.main.async {
                            flutterResult(true)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            flutterResult(FlutterError(code: "Failed to update password",
                                    message: error.localizedDescription,
                                    details: nil))
                        }
                }
            }
        }
    }

    func getUserAttributes(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        _ = Amplify.Auth.fetchUserAttributes() { result in
            switch result {
                case .success(let attributes):
                    DispatchQueue.main.async {
                        flutterResult(self.convertAttributesArray(attributes))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        flutterResult(FlutterError(code: "Failed to fetch user attributes",
                                message: error.localizedDescription,
                                details: nil))
                    }
            }
        }
    }

    func convertAttributesArray(_ attributes: [AuthUserAttribute ]) -> [String:String] {
        var dict = [String:String]()
        for attribute in attributes {
            dict[attribute.key.rawValue] = attribute.value
        }
        return dict
    }
}
