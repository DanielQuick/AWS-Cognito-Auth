import 'package:flutter/material.dart';
import 'package:aws_cognito_auth/aws_cognito_auth.dart';

void main() => runApp(MyApp());

enum AuthState {
  uninitialized,
  initialized
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var _authState = AuthState.uninitialized;
  var _userState = UserState.unknown;
  var _signInState = SignInState.unknown;
  var _confirmationState = SignUpConfirmationState.unknown;
  var _forgotPasswordState = ForgotPasswordState.unknown;
  var _debugLog = "";
  

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: getBody(context)
      ),
    );
  }

  Widget getBody(BuildContext context) {
    switch(_authState) {
      case AuthState.uninitialized:
        return InitializeSection(
          onInitialize: (state) {
            setState(() {
              _userState = state;
              _authState = AuthState.initialized;
            });
          },
          onError: (error) {
            setState(() {
              _debugLog = error;
            });
          },
        );
      case AuthState.initialized:
        return ListView(
          children: <Widget>[
            ExpansionTile(
              title: Text("Debug"),
              initiallyExpanded: true,
              children: <Widget>[
                DebugSection(
                  authState: _authState.toString(),
                  userState: _userState.toString(),
                  confirmationState: _confirmationState.toString(),
                  debugLog: _debugLog,
                  signInState: _signInState.toString(),
                  forgotPasswordState: _forgotPasswordState.toString(),
                )
              ],
            ),
            ExpansionTile(
              title: Text("Sign Up"),
              children: <Widget>[
                SignUpSection(
                  onResult: (result) {
                    setState(() {
                      _confirmationState = result.signUpConfirmationState;
                    });
                  },
                  onLog: (log) {
                    setState(() {
                      _debugLog = log;
                    });
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Confirm Sign Up"),
              children: <Widget>[
                ConfirmSignUpSection(
                  onResult: (result) {
                    setState(() {
                      _confirmationState = result.signUpConfirmationState;
                    });
                  },
                  onLog: (log) {
                    setState(() {
                      _debugLog = log;
                    });
                  },
                )
              ],
            ),
            ExpansionTile(
              title: Text("Resend Sign Up Code"),
              children: <Widget>[
                ResendSignUpCodeSection(
                  onResult: (result) {
                    setState(() {
                      _confirmationState = result.signUpConfirmationState;
                    });
                  },
                  onLog: (log) {
                    setState(() {
                      _debugLog = log;
                    });
                  },
                )
              ],
            ),
            ExpansionTile(
              title: Text("Sign In"),
              children: <Widget>[
                SignInSection(
                  onResult: (result) {
                    setState(() {
                      _signInState = result.signInState;
                    });
                  },
                  onLog: (log) {
                    setState(() {
                      _debugLog = log;
                    });
                  },
                )
              ],
            ),
            ExpansionTile(
              title: Text("Sign Out"),
              children: <Widget>[
                SignOutSection(
                  onResult: () {
                    setState(() {
                      _signInState = SignInState.unknown;
                      _userState = UserState.signedOut;
                    });
                  },
                  onLog: (log) {
                    setState(() {
                      _debugLog = log;
                    });
                  },
                )
              ],
            ),
            ExpansionTile(
              title: Text("Forgot Password"),
              children: <Widget>[
                ForgotPasswordSection(
                  onResult: (result) {
                    setState(() {
                      _forgotPasswordState = result.forgotPasswordState;
                    });
                  },
                  onLog: (log) {
                    setState(() {
                      _debugLog = log;
                    });
                  },
                )
              ],
            ),
            ExpansionTile(
              title: Text("Confirm Forgot Password"),
              children: <Widget>[
                ConfirmForgotPasswordSection(
                  onResult: (result) {
                    setState(() {
                      _forgotPasswordState = result.forgotPasswordState;
                    });
                  },
                  onLog: (log) {
                    setState(() {
                      _debugLog = log;
                    });
                  },
                )
              ],
            ),
            ExpansionTile(
              title: Text("Change Password"),
              children: <Widget>[
                ChangePasswordSection(
                  onResult: () {
                    
                  },
                  onLog: (log) {
                    setState(() {
                      _debugLog = log;
                    });
                  },
                )
              ],
            )
          ],
        );
      default:
        return Text("Uhoh! Something went wrong!");
    }
  }
}

class DebugSection extends StatelessWidget {
  final String authState;
  final String userState;
  final String confirmationState;
  final String debugLog;
  final String signInState;
  final String forgotPasswordState;

  const DebugSection(
    {
      @required this.authState,
      @required this.userState,
      @required this.confirmationState,
      @required this.debugLog,
      @required this.signInState,
      @required this.forgotPasswordState,
      Key key
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
      child: Column(
        children: <Widget>[
          Text(
            authState,
            textAlign: TextAlign.center,
          ),
          Text(
            userState,
            textAlign: TextAlign.center,
          ),
          Text(
            signInState,
            textAlign: TextAlign.center,
          ),
          Text(
            confirmationState,
            textAlign: TextAlign.center,
          ),
          Text(
            forgotPasswordState,
            textAlign: TextAlign.center,
          ),
          Text(
            debugLog,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class InitializeSection extends StatelessWidget {
  final Function(String) onError;
  final Function(UserState) onInitialize;

  const InitializeSection(
    {
      @required this.onInitialize,
      @required this.onError,
      Key key
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text("Initialize"),
        onPressed: () {
          AwsCognitoAuth.initialize(
            onResult: (result) {
              print(result);
              onInitialize(result);
            },
            onError: (error) {
              onError(error);
            }
          );
        },
      ),
    );
  }
}

class SignUpSection extends StatefulWidget {
  final Function(AuthSignUpResult) onResult;
  final Function(String) onLog;

  SignUpSection(
    {
      @required this.onResult,
      @required this.onLog,
      Key key
    }
  ) : super(key: key);

  _SignUpSectionState createState() => _SignUpSectionState();
}

class _SignUpSectionState extends State<SignUpSection> {
  var _formKey = GlobalKey<FormState>();
  var _username = "";
  var _password = "";
  List<String> _attributeNames = new List(50);
  List<String> _attributeValues = new List(50);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
      height: 200,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if(index == 0) {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Username'
                                  ),
                                  onSaved: (String value) {
                                    _username = value;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 32,
                              ),
                              Expanded(
                                child: TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password'
                                  ),
                                  onSaved: (String value) {
                                    _password = value;
                                  },
                                ),
                              )
                            ],
                          );
                        } else {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Attribute Name'
                                  ),
                                  onSaved: (String value) {
                                    _attributeNames[index] = value;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 32,
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Attribute Value'
                                  ),
                                  onSaved: (String value) {
                                    _attributeValues[index] = value;
                                  },
                                ),
                              )
                            ],
                          );
                        }
                      },
                      itemCount: 50,
                    )
                  )
                ),
              ],
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: RaisedButton(
                child: Text("Sign Up"),
                onPressed: () {
                  _formKey.currentState.save();

                  Map attributes = new Map();
                  for(var i = 0; i < _attributeNames.length; i++) {
                    var name = _attributeNames[i];
                    var value = _attributeValues[i];
                    if(name != null && name.isNotEmpty && value != null && value.isNotEmpty) {
                      attributes[name] = value;
                    }
                  }
                  
                  AwsCognitoAuth.signUp(
                    username: _username,
                    password: _password,
                    userAttributes: attributes,
                    onResult: (AuthSignUpResult result) {
                      widget.onResult(result);
                      widget.onLog(result.signUpConfirmationState.toString() + " / " + 
                                      result.codeDeliveryDetails.attributeName + " / " + 
                                      result.codeDeliveryDetails.deliveryMedium.toString() + " / " +
                                      result.codeDeliveryDetails.destination);
                    },
                    onError: (AuthSignUpError result) {
                      widget.onLog(result.error.toString());
                    }
                  );
                },
              )
            ),
          )
        ],
      )
    );
  }
}

class ConfirmSignUpSection extends StatefulWidget {
  final Function(AuthSignUpResult) onResult;
  final Function(String) onLog;

  ConfirmSignUpSection(
    {
      @required this.onResult,
      @required this.onLog,
      Key key
    }
  ) : super(key: key);

  _ConfirmSignUpSectionState createState() => _ConfirmSignUpSectionState();
}

class _ConfirmSignUpSectionState extends State<ConfirmSignUpSection> {
  var _formKey = GlobalKey<FormState>();
  var _username = "";
  var _confirmationCode = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Username'
                      ),
                      onSaved: (String value) {
                        _username = value;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 32,
                  ),
                  Expanded(
                    child: TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Code'
                      ),
                      onSaved: (String value) {
                        _confirmationCode = value;
                      },
                    ),
                  )
                ],
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: RaisedButton(
                child: Text("Confirm Sign Up"),
                onPressed: () {
                  _formKey.currentState.save();

                  AwsCognitoAuth.confirmSignUp(
                    username: _username,
                    confirmationCode: _confirmationCode,
                    onResult: (result) {
                      widget.onResult(result);
                      widget.onLog(result.signUpConfirmationState.toString() + " / " + 
                                      result.codeDeliveryDetails.attributeName + " / " + 
                                      result.codeDeliveryDetails.deliveryMedium.toString() + " / " +
                                      result.codeDeliveryDetails.destination);
                    },
                    onError: (error) {
                      widget.onLog(error.error.toString());
                    }
                  );
                },
              )
            ),
          )
        ],
      ),
    );
  }
}

class ResendSignUpCodeSection extends StatefulWidget {
  final Function(AuthSignUpResult) onResult;
  final Function(String) onLog;

  ResendSignUpCodeSection(
    {
      @required this.onResult,
      @required this.onLog,
      Key key
    }
  ) : super(key: key);

  _ResendSignUpCodeSectionState createState() => _ResendSignUpCodeSectionState();
}

class _ResendSignUpCodeSectionState extends State<ResendSignUpCodeSection> {
  var _formKey = GlobalKey<FormState>();
  var _username = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username'
                ),
                onSaved: (String value) {
                  _username = value;
                },
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: RaisedButton(
                child: Text("Resend Sign Up Code"),
                onPressed: () {
                  _formKey.currentState.save();

                  AwsCognitoAuth.resendSignUpCode(
                    username: _username,
                    onResult: (result) {
                      widget.onResult(result);
                      widget.onLog(result.signUpConfirmationState.toString() + " / " + 
                                      result.codeDeliveryDetails.attributeName + " / " + 
                                      result.codeDeliveryDetails.deliveryMedium.toString() + " / " +
                                      result.codeDeliveryDetails.destination);
                    },
                    onError: (error) {
                      widget.onLog(error.error.toString());
                    }
                  );
                },
              )
            ),
          )
        ],
      ),
    );
  }
}

class SignInSection extends StatefulWidget {
  final Function(AuthSignInResult) onResult;
  final Function(String) onLog;

  SignInSection(
    {
      @required this.onResult,
      @required this.onLog,
      Key key
    }
  ) : super(key: key);

  _SignInSectionState createState() => _SignInSectionState();
}

class _SignInSectionState extends State<SignInSection> {
  var _formKey = GlobalKey<FormState>();
  var _username = "";
  var _password = "";
  List<String> _attributeNames = new List(50);
  List<String> _attributeValues = new List(50);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
      height: 200,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if(index == 0) {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Username'
                                  ),
                                  onSaved: (String value) {
                                    _username = value;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 32,
                              ),
                              Expanded(
                                child: TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password'
                                  ),
                                  onSaved: (String value) {
                                    _password = value;
                                  },
                                ),
                              )
                            ],
                          );
                        } else {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Validation Name'
                                  ),
                                  onSaved: (String value) {
                                    _attributeNames[index] = value;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 32,
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Validation Value'
                                  ),
                                  onSaved: (String value) {
                                    _attributeValues[index] = value;
                                  },
                                ),
                              )
                            ],
                          );
                        }
                      },
                      itemCount: 50,
                    )
                  )
                ),
              ],
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: RaisedButton(
                child: Text("Sign In"),
                onPressed: () {
                  _formKey.currentState.save();

                  Map attributes = new Map();
                  for(var i = 0; i < _attributeNames.length; i++) {
                    var name = _attributeNames[i];
                    var value = _attributeValues[i];
                    if(name != null && name.isNotEmpty && value != null && value.isNotEmpty) {
                      attributes[name] = value;
                    }
                  }
                  
                  AwsCognitoAuth.signIn(
                    username: _username,
                    password: _password,
                    validationData: attributes,
                    onResult: (AuthSignInResult result) {
                      widget.onResult(result);
                      widget.onLog(result.signInState.toString() + " / " + 
                                      result.codeDetails.attributeName + " / " + 
                                      result.codeDetails.deliveryMedium.toString() + " / " +
                                      result.codeDetails.destination);
                    },
                    onError: (AuthSignInError result) {
                      widget.onLog(result.error.toString());
                      print(result.rawError);
                      print(result.rawMessage);
                    }
                  );
                },
              )
            ),
          )
        ],
      )
    );
  }
}

class SignOutSection extends StatefulWidget {
  final VoidCallback onResult;
  final Function(String) onLog;

  SignOutSection(
    {
      @required this.onResult,
      @required this.onLog,
      Key key
    }
  ) : super(key: key);

  _SignOutSectionState createState() => _SignOutSectionState();
}

class _SignOutSectionState extends State<SignOutSection> {
  bool _globally = false;
  bool _invalidateTokens = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: CheckboxListTile(
                  title: Text("Globally"),
                  value: _globally,
                  onChanged: (value) {
                    setState(() {
                      _globally = value;
                    });
                  },
                ),
              ),
              Flexible(
                child: CheckboxListTile(
                  title: Text("Invalidate Tokens"),
                  value: _invalidateTokens,
                  onChanged: (value) {
                    setState(() {
                      _invalidateTokens = value;
                    });
                  },
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Center(
              child: RaisedButton(
                child: Text("Sign Out"),
                onPressed: () {
                  AwsCognitoAuth.signOut(
                    onResult: () {
                      widget.onResult();
                    },
                    onError: (error) {
                      widget.onLog(error);
                    },
                    globally: _globally,
                    invalidateTokens: _invalidateTokens,
                  );
                },
              )
            ),
          )
        ],
      )
    );
  }
}

class ForgotPasswordSection extends StatefulWidget {
  final Function(AuthForgotPasswordResult) onResult;
  final Function(String) onLog;

  ForgotPasswordSection(
    {
      @required this.onResult,
      @required this.onLog,
      Key key
    }
  ) : super(key: key);

  _ForgotPasswordSectionState createState() => _ForgotPasswordSectionState();
}

class _ForgotPasswordSectionState extends State<ForgotPasswordSection> {
  var _formKey = GlobalKey<FormState>();
  var _username = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username'
                ),
                onSaved: (String value) {
                  _username = value;
                },
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: RaisedButton(
                child: Text("Forgot Password"),
                onPressed: () {
                  _formKey.currentState.save();

                  AwsCognitoAuth.forgotPassword(
                    username: _username,
                    onResult: (result) {
                      widget.onResult(result);
                      widget.onLog(result.forgotPasswordState.toString() + " / " + 
                                      result.codeDeliveryDetails.attributeName + " / " + 
                                      result.codeDeliveryDetails.deliveryMedium.toString() + " / " +
                                      result.codeDeliveryDetails.destination);
                    },
                    onError: (error) {
                      widget.onLog(error.error.toString());
                    }
                  );
                },
              )
            ),
          )
        ],
      ),
    );
  }
}

class ConfirmForgotPasswordSection extends StatefulWidget {
  final Function(AuthForgotPasswordResult) onResult;
  final Function(String) onLog;

  ConfirmForgotPasswordSection(
    {
      @required this.onResult,
      @required this.onLog,
      Key key
    }
  ) : super(key: key);

  _ConfirmForgotPasswordSectionState createState() => _ConfirmForgotPasswordSectionState();
}

class _ConfirmForgotPasswordSectionState extends State<ConfirmForgotPasswordSection> {
  var _formKey = GlobalKey<FormState>();
  var _username = "";
  var _newPassword = "";
  var _confirmationCode = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username'
                  ),
                  onSaved: (String value) {
                    _username = value;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password'
                  ),
                  onSaved: (String value) {
                    _newPassword = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirmation Code'
                  ),
                  onSaved: (String value) {
                    _confirmationCode = value;
                  },
                ),
              ],
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: RaisedButton(
                child: Text("Forgot Password"),
                onPressed: () {
                  _formKey.currentState.save();

                  AwsCognitoAuth.confirmForgotPassword(
                    username: _username,
                    newPassword: _newPassword,
                    confirmationCode: _confirmationCode,
                    onResult: (result) {
                      widget.onResult(result);
                      widget.onLog(result.forgotPasswordState.toString() + " / " + 
                                      result.codeDeliveryDetails.attributeName + " / " + 
                                      result.codeDeliveryDetails.deliveryMedium.toString() + " / " +
                                      result.codeDeliveryDetails.destination);
                    },
                    onError: (error) {
                      widget.onLog(error.error.toString());
                    }
                  );
                },
              )
            ),
          )
        ],
      ),
    );
  }
}

class ChangePasswordSection extends StatefulWidget {
  final VoidCallback onResult;
  final Function(String) onLog;

  ChangePasswordSection(
    {
      @required this.onResult,
      @required this.onLog,
      Key key
    }
  ) : super(key: key);

  _ChangePasswordSectionState createState() => _ChangePasswordSectionState();
}

class _ChangePasswordSectionState extends State<ChangePasswordSection> {
  var _formKey = GlobalKey<FormState>();
  var _currentPassword = "";
  var _proposedPassword = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Current Password'
                  ),
                  onSaved: (String value) {
                    _currentPassword = value;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Proposed Password'
                  ),
                  onSaved: (String value) {
                    _proposedPassword = value;
                  },
                ),
              ],
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: RaisedButton(
                child: Text("Change Password"),
                onPressed: () {
                  _formKey.currentState.save();

                  AwsCognitoAuth.changePassword(
                    currentPassword: _currentPassword,
                    proposedPassword: _proposedPassword,
                    onResult: () {
                      widget.onLog("Password Changed");
                    },
                    onError: (error) {
                      widget.onLog(error.error.toString());
                    }
                  );
                },
              )
            ),
          )
        ],
      ),
    );
  }
}