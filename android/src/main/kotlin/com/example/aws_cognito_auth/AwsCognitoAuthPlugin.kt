package com.example.aws_cognito_auth

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

import android.content.Context
import android.app.Activity

import com.amplifyframework.core.Amplify
import com.amplifyframework.auth.options.AuthSignUpOptions
import com.amplifyframework.auth.AuthUserAttributeKey
import com.amplifyframework.auth.result.AuthSignUpResult
import com.amplifyframework.auth.result.AuthSignInResult;
import com.amplifyframework.auth.cognito.AWSCognitoAuthPlugin
import com.amplifyframework.auth.result.AuthResetPasswordResult;

/** AmplifyConfigurePlugin */
public class AwsCognitoAuthPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context
  private lateinit var activity : Activity

  override fun onAttachedToActivity(activityPluginBinding : ActivityPluginBinding) {
    activity = activityPluginBinding.getActivity()
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(activityPluginBinding : ActivityPluginBinding) {
  }

  override fun onDetachedFromActivity() {
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val context = flutterPluginBinding.getApplicationContext()

    Amplify.addPlugin(AWSCognitoAuthPlugin())
    Amplify.configure(context)

    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "aws_cognito_auth")
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val context = registrar.context()

      Amplify.addPlugin(AWSCognitoAuthPlugin())
      Amplify.configure(context)

      val channel = MethodChannel(registrar.messenger(), "aws_cognito_auth")
      channel.setMethodCallHandler(AwsCognitoAuthPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "signUp" -> signUp(call.argument<String>("username") ?: "", call.argument<String>("password") ?: "", call.argument<String>("email") ?: "", call.argument<String>("name") ?: "", result)
      "confirmSignUp" -> confirmSignUp(call.argument<String>("username") ?: "", call.argument<String>("code") ?: "", result)
      "resendSignUpCode" -> resendSignUpCode(call.argument<String>("username") ?: "", result)
      "signIn" -> signIn(call.argument<String>("username") ?: "", call.argument<String>("password") ?: "", result)
      "signOut" -> signOut(result)
      "resetPassword" -> resetPassword(call.argument<String>("username") ?: "", result)
      "confirmResetPassword" -> confirmResetPassword(call.argument<String>("password") ?: "",call.argument<String>("code") ?: "", result)
      "updatePassword" -> updatePassword(call.argument<String>("password") ?: "", call.argument<String>("newPassword") ?: "", result)

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  fun signUp(username : String, password : String, email : String, name : String, flutterResult: Result) {
    Amplify.Auth.signUp(
        username,
        password,
        AuthSignUpOptions.builder().userAttribute(AuthUserAttributeKey.email(), email).userAttribute(AuthUserAttributeKey.name(), name).build(),
        {
          result -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.success(convertSignUpResult(result))
            }
          )
        },
        {
          error -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.error(error.message, error.cause.toString(), error)
            }
          )
        }
    )
  }

  fun convertSignUpResult(result: AuthSignUpResult) : HashMap<String,Any> {
    val map = HashMap<String,Any>()
    map.put("isSignUpComplete", result.isSignUpComplete())
    return map
  }

  fun convertSignInResult(result: AuthSignInResult) : HashMap<String,Any> {
    val map = HashMap<String,Any>()
    map.put("isSignInComplete", result.isSignInComplete())
    return map
  }

  fun convertResetPasswordResult(result: AuthResetPasswordResult) : HashMap<String,Any> {
    val map = HashMap<String,Any>()
    map.put("isPasswordReset", result.isPasswordReset())
    return map
  }

  fun confirmSignUp(username : String, code : String, flutterResult : Result) {
    Amplify.Auth.confirmSignUp(
        username,
        code,
        {
          result -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.success(convertSignUpResult(result))
            }
          )
        },
        {
          error -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.error(error.message, error.cause.toString(), error)
            }
          )
        }
    )
  }

  fun resendSignUpCode(username : String, flutterResult : Result) {
    Amplify.Auth.resendSignUpCode(
        username,
        {
          result -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.success(convertSignUpResult(result))
            }
          )
        },
        {
          error -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.error(error.message, error.cause.toString(), error)
            }
          )
        }
    )
  }

  fun signIn(username : String, password : String, flutterResult : Result) {
    Amplify.Auth.signIn(
        username,
        password,
        {
          result -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.success(convertSignInResult(result))
            }
          )
        },
        {
          error -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.error(error.message, error.cause.toString(), error)
            }
          )
        }
    )
  }

  fun signOut(flutterResult : Result) {
    Amplify.Auth.signOut(
        {
          activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.success(true)
            }
          )
        },
        {
          error -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.error(error.message, error.cause.toString(), error)
            }
          )
        }
    )
  }

  fun resetPassword(username : String, flutterResult : Result) {
    Amplify.Auth.resetPassword(
        username,
        {
          result -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.success(convertResetPasswordResult(result))
            }
          )
        },
        {
          error -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.error(error.message, error.cause.toString(), error)
            }
          )
        }
    )
  }

  fun confirmResetPassword(password : String, code : String, flutterResult : Result) {
    Amplify.Auth.confirmResetPassword(
        password,
        code,
        {
          activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.success(true)
            }
          )
        },
        {
          error -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.error(error.message, error.cause.toString(), error)
            }
          )
        }
    )
  }

  fun updatePassword(password : String, newPassword : String, flutterResult : Result) {
    Amplify.Auth.updatePassword(
        password,
        newPassword,
        {
          activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.success(true)
            }
          )
        },
        {
          error -> activity.runOnUiThread(
            java.lang.Runnable {
              flutterResult.error(error.message, error.cause.toString(), error)
            }
          )
        }
    )
  }
}