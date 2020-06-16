package com.example.aws_cognito_auth

import android.app.Activity
import com.amazonaws.mobile.client.AWSMobileClient
import com.amazonaws.mobile.client.Callback
import com.amazonaws.mobile.client.UserStateDetails
import com.amazonaws.mobile.client.results.SignInResult
import com.amazonaws.mobile.client.results.SignUpResult
import com.amazonaws.mobile.client.results.ForgotPasswordResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class AwsCognitoAuthPlugin: MethodCallHandler {
  var activity: Activity

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "aws_cognito_auth")
      channel.setMethodCallHandler(AwsCognitoAuthPlugin(registrar.activity()))
    }
  }

  constructor(activity: Activity) {
    this.activity = activity
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method) {
      "initialize" -> initialize(call, result)
      "signUp" -> signUp(call, result)
      "signIn" -> signIn(call, result)
      "signOut" -> signOut(call, result)
      "resendSignUpCode" -> resendSignUpConfirmation(call, result)
      "forgotPassword" -> forgotPassword(call, result)
      "confirmForgotPassword" -> confirmForgotPassword(call, result)
      "isSignedIn" -> isSignedIn(call, result)
      "changePassword" -> changePassword(call, result)
      "getUsername" -> getUsername(call, result)
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initialize(call: MethodCall, result: Result) {
    AWSMobileClient.getInstance().initialize(activity, object: Callback<UserStateDetails> {
      override fun onResult(userStateDetails: UserStateDetails) {
        val userState = userStateDetails.getUserState().toString()
        val map = HashMap<String,String>()
        map.put("result", userState)
        activity.runOnUiThread(java.lang.Runnable {
          result.success(map)
        })
      }

      override fun onError(e: Exception) {
        val map = HashMap<String,String>()
        map.put("error", e.toString())
        activity.runOnUiThread(java.lang.Runnable {
          result.success(map)
        })
      }
    })
  }

  private fun signUp(call: MethodCall, result: Result) {
    val arguments = call.arguments as HashMap<String,Any>;
    var username = ""
    var password = ""
    var userAttributes = HashMap<String,String>()

    if(arguments.containsKey("username")) {
      username = arguments["username"] as String
    }
    if(arguments.containsKey("password")) {
      password = arguments["password"] as String
    }
    if(arguments.containsKey("userAttributes")) {
      userAttributes = arguments["userAttributes"] as HashMap<String, String>
    }

    AWSMobileClient.getInstance().signUp(username, password, userAttributes, null, object: Callback<SignUpResult> {
      override fun onResult(signUpResult: SignUpResult) {
        var destination = ""
        var attributeName = ""
        var deliveryMedium = ""

        if(signUpResult.getUserCodeDeliveryDetails() != null) {
          val deliveryDetails = signUpResult.getUserCodeDeliveryDetails()

          val dest = deliveryDetails.getDestination()
          val attr = deliveryDetails.getAttributeName()
          var deliv = deliveryDetails.getDeliveryMedium()
          if(dest != null) {
            destination = dest
          }
          if(attr != null) {
            attributeName = attr
          }
          if(deliv != null) {
            deliveryMedium = deliv
          }
        }

        val innerMap = HashMap<String,String>()
        innerMap.put("deliveryMedium", deliveryMedium)
        innerMap.put("attributeName", attributeName)
        innerMap.put("destination", destination)
        val map = HashMap<String,HashMap<String,String>>()
        map.put("result", innerMap)
        activity.runOnUiThread(java.lang.Runnable {
          result.success(map)
        })
      }

      override fun onError(e: Exception) {
        val map = HashMap<String,String>()
        map.put("error", e.toString())
        activity.runOnUiThread(java.lang.Runnable {
          result.success(map)
        })
      }
    })
  }

  private fun signIn(call: MethodCall, flutterResult: Result) {
    val arguments = call.arguments as HashMap<String,Any>;
    var username = ""
    var password = ""
    if(arguments.containsKey("username")) {
      username = arguments["username"] as String
    }
    if(arguments.containsKey("password")) {
      password = arguments["password"] as String
    }

    AWSMobileClient.getInstance().signIn(username, password, null, object: Callback<SignInResult> {
      override fun onResult(result: SignInResult?) {
        var destination = ""
        var attributeName = ""
        var deliveryMedium = "unknown"
        var signInState = "unknown"

        if(result != null) {
          var codeDetails = result!!.codeDetails
          if(codeDetails != null) {
            destination = codeDetails!!.destination
            attributeName = codeDetails!!.destination
            deliveryMedium = codeDetails!!.deliveryMedium
          }
          signInState = result!!.signInState.toString()
        }

        val resultMap = HashMap<String,HashMap<String,String>>()
        val map = HashMap<String,String>()

        map.put("signInState", signInState)
        map.put("destination", destination)
        map.put("deliveryMedium", deliveryMedium)
        map.put("attributeName", attributeName)

        resultMap.put("result", map)
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(resultMap)
        })
      }

      override fun onError(e: java.lang.Exception?) {
        val map = HashMap<String,String>()
        map.put("error", e.toString())
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(map)
        })
      }
    })
  }

  private fun signOut(call: MethodCall, result: Result) {
    AWSMobileClient.getInstance().signOut()

    val map = HashMap<String,String>()
    map.put("result", "")
    activity.runOnUiThread(java.lang.Runnable {
      result.success(map)
    })
  }

  private fun resendSignUpConfirmation(call: MethodCall, flutterResult: Result) {
    val arguments = call.arguments as HashMap<String,Any>;
    var username = ""
    if(arguments.containsKey("username")) {
      username = arguments["username"] as String
    }

    AWSMobileClient.getInstance().resendSignUp(username, object: Callback<SignUpResult> {
      override fun onResult(result: SignUpResult) {
        var destination = ""
        var attributeName = ""
        var deliveryMedium = "unknown"
        var confirmationState = ""

        if(result != null) {
          if(result.getUserCodeDeliveryDetails() != null) {
            val deliveryDetails = result.getUserCodeDeliveryDetails()

            val dest = deliveryDetails.getDestination()
            val attr = deliveryDetails.getAttributeName()
            var deliv = deliveryDetails.getDeliveryMedium()
            if(dest != null) {
              destination = dest
            }
            if(attr != null) {
              attributeName = attr
            }
            if(deliv != null) {
              deliveryMedium = deliv
            }
          }
          confirmationState = result.getConfirmationState().toString()
        }

        val resultMap = HashMap<String,HashMap<String,String>>()
        val map = HashMap<String,String>()

        map.put("destination", destination)
        map.put("deliveryMedium", deliveryMedium)
        map.put("attributeName", attributeName)
        map.put("confirmationState", confirmationState)

        resultMap.put("result", map)
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(resultMap)
        })
      }

      override fun onError(e: java.lang.Exception?) {
        val map = HashMap<String,String>()
        map.put("error", e.toString())
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(map)
        })
      }
    })
  }

  private fun forgotPassword(call: MethodCall, flutterResult: Result) {
    val arguments = call.arguments as HashMap<String,Any>;
    var username = ""
    if(arguments.containsKey("username")) {
      username = arguments["username"] as String
    }

    AWSMobileClient.getInstance().forgotPassword(username, object: Callback<ForgotPasswordResult> {
      override fun onResult(result: ForgotPasswordResult) {
        var destination = ""
        var attributeName = ""
        var deliveryMedium = "unknown"
        var forgotPasswordState = ""

        if(result != null) {
          var codeDetails = result!!.getParameters()
          if(codeDetails != null) {
            destination = codeDetails!!.destination
            attributeName = codeDetails!!.destination
            deliveryMedium = codeDetails!!.deliveryMedium
          }
          forgotPasswordState = result!!.getState().toString()
        }

        val resultMap = HashMap<String,HashMap<String,String>>()
        val map = HashMap<String,String>()

        map.put("destination", destination)
        map.put("deliveryMedium", deliveryMedium)
        map.put("attributeName", attributeName)
        map.put("forgotPasswordState", forgotPasswordState)

        resultMap.put("result", map)
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(resultMap)
        })
      }

      override fun onError(e: java.lang.Exception?) {
        val map = HashMap<String,String>()
        map.put("error", e.toString())
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(map)
        })
      }
    })
  }

  private fun confirmForgotPassword(call: MethodCall, flutterResult: Result) {
    val arguments = call.arguments as HashMap<String,Any>;
    var newPassword = ""
    var confirmationCode = ""
    if(arguments.containsKey("newPassword")) {
      newPassword = arguments["newPassword"] as String
    }
    if(arguments.containsKey("confirmationCode")) {
      confirmationCode = arguments["confirmationCode"] as String
    }

    AWSMobileClient.getInstance().confirmForgotPassword(newPassword, confirmationCode, object: Callback<ForgotPasswordResult> {
      override fun onResult(result: ForgotPasswordResult) {
        var destination = ""
        var attributeName = ""
        var deliveryMedium = "unknown"
        var forgotPasswordState = ""

        if(result != null) {
          var codeDetails = result!!.getParameters()
          if(codeDetails != null) {
            destination = codeDetails!!.destination
            attributeName = codeDetails!!.destination
            deliveryMedium = codeDetails!!.deliveryMedium
          }
          forgotPasswordState = result!!.getState().toString()
        }

        val resultMap = HashMap<String,HashMap<String,String>>()
        val map = HashMap<String,String>()

        map.put("destination", destination)
        map.put("deliveryMedium", deliveryMedium)
        map.put("attributeName", attributeName)
        map.put("forgotPasswordState", forgotPasswordState)

        resultMap.put("result", map)
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(resultMap)
        })
      }

      override fun onError(e: java.lang.Exception?) {
        val map = HashMap<String,String>()
        map.put("error", e.toString())
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(map)
        })
      }
    })
  }

  private fun isSignedIn(call: MethodCall, flutterResult: Result) {
    flutterResult.success(AWSMobileClient.getInstance().isSignedIn)
  }

  private fun changePassword(call: MethodCall, flutterResult: Result) {
    val arguments = call.arguments as HashMap<String,Any>;
    var currentPassword = ""
    var proposedPassword = ""
    if(arguments.containsKey("currentPassword")) {
      currentPassword = arguments["currentPassword"] as String
    }
    if(arguments.containsKey("proposedPassword")) {
      proposedPassword = arguments["proposedPassword"] as String
    }

    AWSMobileClient.getInstance().changePassword(currentPassword, proposedPassword, object : Callback<Void> {
      override fun onResult(signInResult: Void?) {
        val map = HashMap<String,String>()
        map.put("result", "true")
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(map)
        })
      }

      override fun onError(e: Exception) {
        val map = HashMap<String,String>()
        map.put("error", e.toString())
        activity.runOnUiThread(java.lang.Runnable {
          flutterResult.success(map)
        })
      }
    })
  }

  private fun getUsername(call: MethodCall, flutterResult: Result) {
    flutterResult.success(AWSMobileClient.getInstance().username)
  }
}
