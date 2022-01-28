import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class UserDetailsScreen extends StatefulWidget {
  static const routeName = '/user-details';

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  String _currentAddress;
  Position _currentPosition;

  @override
  Widget build(BuildContext context) {
    final loadedDetails = Provider.of<Auth>(
      context,
      listen: false,
    ).fetchUserDetails();
    return Scaffold(
        //backgroundColor: Colors.orange,

        body: Column(children: <Widget>[
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
          child: ListView(children: <Widget>[
        Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.grey[200],
                  blurRadius: 2.0,
                  offset: Offset(0, 5.0)),
            ]),
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Column(children: <Widget>[
              Text(
                "Hello ${loadedDetails.username}!",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Text(
                "Your Details are",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'Email Address',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            '${loadedDetails.email}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (_currentAddress != null)
                      Text(_currentAddress,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold)),
                    FlatButton(
                      child: Text("Get location",
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      onPressed: () {
                        _getCurrentLocation();
                      },
                      color: Colors.orange,
                    ),
                    SizedBox(height: 15),
                  ]))
            ]))
      ]))
    ]));
  }

  //   Text(
  //     'Hello ${loadedDetails.username}!',
  //     style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  //   ),
  //   SizedBox(
  //     height: 20,
  //   ),
  //   Text(
  //     'Email address: ${loadedDetails.email}',
  //   ),
  //   SizedBox(
  //     height: 20,
  //   ),
  //   if (_currentAddress != null) Text(_currentAddress),
  //   FlatButton(
  //     child: Text("Get location", style: TextStyle(color: Colors.white)),
  //     onPressed: () {
  //       _getCurrentLocation();
  //     },
  //     color: Colors.orange,
  //   ),
  // ],

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
}
