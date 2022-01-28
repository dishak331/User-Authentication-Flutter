import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_auth/models/httpException.dart';
import 'package:user_auth/providers/auth.dart';
import 'package:user_auth/screens/user_details_screen.dart';
import './register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hidepassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  //AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
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
      await Provider.of<Auth>(context, listen: false)
          .login(_authData['email'], _authData['password']);
      Navigator.of(context).pushReplacementNamed(UserDetailsScreen.routeName);
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        errorMessage = 'Too many attempts, try again later';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'User account does not exist, please sign up instead';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid Password';
      } else if (error.toString().contains('USER_DISABLED')) {
        errorMessage = 'User account has been disabled';
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
      //backgroundColor: Color(0xFFF6F5FA),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    iconSize: 20.0,
                    padding: EdgeInsets.only(top: 50.0),
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      //Navigator.of(context).pop();
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
                          offset: Offset(0, 5.0)),
                    ]),
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Hello",
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Sign into your Account",
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
                                      labelText: "Email ID*",
                                      labelStyle: TextStyle(fontSize: 14.0),
                                      suffixIcon: Icon(Icons.mail, size: 17.0)),
                                  keyboardType: TextInputType.emailAddress,
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
                                  obscureText: _hidepassword,
                                  decoration: InputDecoration(
                                      labelText: "Password*",
                                      labelStyle: TextStyle(fontSize: 14.0),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _hidepassword = !_hidepassword;
                                            });
                                          },
                                          icon: Icon(
                                              _hidepassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              size: 17.0))),
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
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      "Forgot Your Password",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[400],
                                          fontSize: 14.0),
                                    ),
                                  ),
                                ),
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
                                "Login",
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
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            "Or Login using social Media",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              iconSize: 18.0,
                              color: Color(0xFF3B5998),
                              onPressed: () {},
                              icon: FaIcon(FontAwesomeIcons.facebookF),
                            ),
                            IconButton(
                              iconSize: 18.0,
                              color: Color(0xFF00ACEE),
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
                        Text(
                          "Don't have an account?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, RegisterScreen.routeName);
                          },
                          child: Text("Register Now",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
