package com.example.aws_cognito_auth

import androidx.annotation.NonNull;
import android.util.Log
import java.lang.Runnable

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
import com.amplifyframework.auth.AuthUserAttribute;
import com.amplifyframework.auth.AuthUserAttributeKey
import com.amplifyframework.auth.result.AuthSignUpResult
import com.amplifyframework.auth.result.AuthSignInResult;
import com.amplifyframework.auth.cognito.AWSCognitoAuthPlugin
import com.amplifyframework.auth.result.AuthResetPasswordResult;

import com.amazonaws.mobile.client.AWSMobileClient;
import com.amazonaws.mobile.client.Callback;

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
      val channel = MethodChannel(registrar.messenger(), "aws_cognito_auth")
      channel.setMethodCallHandler(AwsCognitoAuthPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> initialize(result)
      "signUp" -> signUp(call.arguments as HashMap<String, Any>, result)
      "confirmSignUp" -> confirmSignUp(call.argument<String>("username") ?: "", call.argument<String>("code") ?: "", result)
      "resendSignUpCode" -> resendSignUpCode(call.argument<String>("username") ?: "", result)
      "signIn" -> signIn(call.argument<String>("username") ?: "", call.argument<String>("password") ?: "", result)
      "signOut" -> signOut(result)
      "resetPassword" -> resetPassword(call.argument<String>("username") ?: "", result)
      "confirmResetPassword" -> confirmResetPassword(call.argument<String>("password") ?: "",call.argument<String>("code") ?: "", result)
      "updatePassword" -> updatePassword(call.argument<String>("password") ?: "", call.argument<String>("newPassword") ?: "", result)
      "getUserAttributes" -> getUserAttributes(result)
      "isSignedIn" -> isSignedIn(result)

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  fun initialize(flutterResult: Result) {
    Amplify.addPlugin(AWSCognitoAuthPlugin())
    flutterResult.success(true);
  }

  fun signUp(parameters: HashMap<String, Any>, flutterResult: Result) {

    val attributes = parameters.getValue("attributes") as HashMap<String, Any>
    val custom = parameters.getValue("custom") as HashMap<String, Any>

    val username = attributes.getValue("username") as String
    val password = attributes.getValue("password") as String

    val attributesList = mutableListOf<AuthUserAttribute>()

    if (attributes.containsKey("email")) attributesList.add(AuthUserAttribute(AuthUserAttributeKey.email(), attributes.getValue("email") as String))
    if (attributes.containsKey("name")) attributesList.add(AuthUserAttribute(AuthUserAttributeKey.name(), attributes.getValue("name") as String))
    if (attributes.containsKey("givenName")) attributesList.add(AuthUserAttribute(AuthUserAttributeKey.givenName(), attributes.getValue("givenName") as String))
    if (attributes.containsKey("familyName")) attributesList.add(AuthUserAttribute(AuthUserAttributeKey.familyName(), attributes.getValue("familyName") as String))
    if (attributes.containsKey("phoneNumber")) attributesList.add(AuthUserAttribute(AuthUserAttributeKey.phoneNumber(), attributes.getValue("phoneNumber") as String))

    custom.forEach {
      key, value -> attributesList.add(AuthUserAttribute(AuthUserAttributeKey.custom(key), value as String))
    }

    Amplify.Auth.signUp(
        username,
        password,
        AuthSignUpOptions.builder().userAttributes(attributesList).build(),
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
        })
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

  fun getUserAttributes(flutterResult : Result) {
    try {
      val mobileClient = Amplify.Auth.getPlugin("awsCognitoAuthPlugin").escapeHatch as AWSMobileClient?
      mobileClient!!.getUserAttributes(object : Callback<Map<String,String>> {

          override fun onResult(result: Map<String,String>) {
            activity.runOnUiThread(Runnable {
              flutterResult.success(result)
            })
          }

          override fun onError(e: Exception) {
            activity.runOnUiThread(Runnable {
              flutterResult.error("Could not get userAttributes", null, e)
            })
          }
      })
    } catch (e: Exception) {
      flutterResult.error("Could not get userAttributes", null, e)
    }
  }

  fun isSignedIn(flutterResult : Result) {
    val mobileClient = Amplify.Auth.getPlugin("awsCognitoAuthPlugin").escapeHatch as AWSMobileClient?

    flutterResult.success(mobileClient!!.isSignedIn())
  }
}