import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_auth/models/httpException.dart';
import 'package:user_auth/providers/auth.dart';
import 'package:user_auth/screens/user_details_screen.dart';
import './login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _hidePassword = true;
  bool _checked = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  //AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An error occured'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Okay'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).signup(
          _authData['username'], _authData['email'], _authData['password']);

      Navigator.of(context).pushReplacementNamed(UserDetailsScreen.routeName);
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Email-ID already exists';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'Could not authenticate you. Please try again Later';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    iconSize: 20.0,
                    padding: EdgeInsets.only(top: 60),
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Image(
                    width: 310.0,
                    image: AssetImage("assets/shape.png"),
                  )
                ],
              ),
            ),
            Container(
              height: 40.0,
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Positioned(
                    top: -140,
                    child: Image(
                      image: AssetImage("assets/logo.png"),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: ListView(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200],
                        blurRadius: 2.0,
                        offset: Offset(0, 5.0))
                  ]),
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Create Account",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: "UserName*",
                                    labelStyle: TextStyle(fontSize: 14.0),
                                    suffixIcon: Icon(
                                      Icons.person,
                                      size: 17.0,
                                    )),
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Invalid username';
                                  }
                                  return null;
                                  //return null;
                                },
                                onSaved: (value) {
                                  _authData['username'] = value;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: "Email*",
                                    labelStyle: TextStyle(fontSize: 14.0),
                                    suffixIcon: Icon(
                                      Icons.mail,
                                      size: 17.0,
                                    )),
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Invalid email!';
                                  }
                                  return null;
                                  //return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value;
                                },
                              ),
                              TextFormField(
                                obscureText: _hidePassword,
                                decoration: InputDecoration(
                                    labelText: "Password*",
                                    labelStyle: TextStyle(fontSize: 14.0),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _hidePassword = !_hidePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 17.0,
                                      ),
                                    )),
                                controller: _passwordController,
                                validator: (value) {
                                  if (value.isEmpty || value.length < 5) {
                                    return 'Password is too short!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['password'] = value;
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _checked = !_checked;
                                        });
                                      },
                                      child: Checkbox(
                                        value: _checked,
                                        onChanged: null,
                                      ),
                                    ),
                                    Text(
                                      "I Read and agree to ",
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[400]),
                                    ),
                                    Text(
                                      "Terms & Conditions",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isLoading)
                        CircularProgressIndicator()
                      else
                        Container(
                          margin: EdgeInsets.only(top: 20.0),
                          width: 200.0,
                          child: RaisedButton(
                            child: Text(
                              "Register",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            padding: EdgeInsets.all(20.0),
                            onPressed: _submit,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text(
                          "Or Register using social Media",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            iconSize: 18.0,
                            color: Color(0XFF3B5998),
                            onPressed: () {},
                            icon: FaIcon(FontAwesomeIcons.facebookF),
                          ),
                          IconButton(
                            iconSize: 18.0,
                            color: Color(0XFF00ACEE),
                            onPressed: () {},
                            icon: FaIcon(FontAwesomeIcons.twitter),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Already have an account?",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 5.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, LoginScreen.routeName);
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
