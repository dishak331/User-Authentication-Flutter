import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/auth_screen.dart';
import './screens/register_screen.dart';
import './screens/login_screen.dart';
import './screens/user_details_screen.dart';
import './providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fruitley',
        theme: ThemeData(
            primaryColor: Colors.orange,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: AuthScreen(),
        routes: {
          LoginScreen.routeName: (ctx) => LoginScreen(),
          RegisterScreen.routeName: (ctx) => RegisterScreen(),
          UserDetailsScreen.routeName: (ctx) => UserDetailsScreen()
        },
      ),
    );
  }
}
