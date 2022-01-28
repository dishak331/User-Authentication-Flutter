import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/httpException.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String userId;
  String username;
  String email;
  //String password;
  User({this.userId, this.username, this.email});
}

class Auth with ChangeNotifier {
  String _token; // expired after 1hr
  DateTime _expiryDate;
  String
      _userId; // not final beaucse these might change in future like signup with a new acc
  Timer _authTimer;
  bool get isAuth {
    return token != null;
  }

  List<User> _userdetails = [];

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  // Future<void> fetchUserDetails() async {
  //   // final url = Uri.parse(
  //   //     'https://user-auth-be661-default-rtdb.firebaseio.com/userDetails/$_userId/?auth=$_token');
  //   // try {
  //   //   final response = await http.get(url);
  //   //   final extractedData = json.decode(response.body) as Map<String, dynamic>;
  //   //   if (extractedData == null) {
  //   //     return;
  //   //   }
  //   //   final List<User> loadedDetails = [];
  //   //   extractedData.forEach((prodId, prodData) {
  //   //     loadedDetails.add(
  //   //         User(username: prodData['username'], email: prodData['email']));
  //   //   });
  //   //   _userdetails = loadedDetails;
  //     return _items.firstWhere((prod) => prod.id == id);
  //     notifyListeners();
  //   } catch (error) {
  //     throw error;
  //   }
  // }

  User fetchUserDetails() {
    return _userdetails.firstWhere((prod) => prod.userId == _userId);
  }

  Future<void> addUserDetails(User ud) async {
    final url = Uri.parse(
        'https://user-auth-be661-default-rtdb.firebaseio.com/userDetails/$_userId/?auth=$_token');
    try {
      await http.post(
        url,
        body: json.encode({
          'username': ud.username,
          'email': ud.email
          //'isFavorite': product.isFavorite,
        }),
      );
      notifyListeners();
    } catch (error) {
      //print(error);
      throw error;
    }
  }

  Future<void> _authenticate(String email, String password, String urlSegment,
      [String username = '']) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBsJzu92A3oWvs4Gbkq6zLStx7CODopKZA');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      //print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      if (urlSegment == 'signUp') {
        User newUser = User(userId: _userId, username: username, email: email);
        // addUserDetails(newUser);
        _userdetails.add(newUser);
        // print(_userdetails);
        notifyListeners();

        //userDetails(_userId);
      } else {
        fetchUserDetails();

        notifyListeners();
      }
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));

      notifyListeners();
      //working with shared preferences involves working with async and futures
      final prefs = await SharedPreferences.getInstance();
      //for complex storing we can do json.encode which will always store a map
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String username, String email, String password) async {
    return _authenticate(email, password, 'signUp', username);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
