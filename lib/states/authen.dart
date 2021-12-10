import 'dart:async';

import 'package:bestproj/states/show_noti.dart';
import 'package:bestproj/widgets/show_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authen extends StatefulWidget {
  const Authen({Key? key}) : super(key: key);

  @override
  _AuthenState createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  FlutterLocalNotificationsPlugin flutterLocalNotPlugin =
      FlutterLocalNotificationsPlugin();

  InitializationSettings? initiallizationSettings;

  AndroidInitializationSettings? androidInitializations;
  IOSInitializationSettings? iosInitializationSettings;

  String? title, message;
  double? lat, lng;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    setUpMessaging();
    setUpLocalNotification();
    findLocation();
  }

  Future<void> findLocation() async {
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((event) {
      lat = event.latitude;
      lng = event.longitude;
      print([lat, lng]);
    });
  }

  Future<void> setUpLocalNotification() async {
    androidInitializations = const AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNoti,
    );

    initiallizationSettings = InitializationSettings(
      android: androidInitializations,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotPlugin.initialize(
      initiallizationSettings!,
      onSelectNotification: onSelectNoti,
    );
  }

  Future onDidReceiveLocalNoti(
      int id, String? title, String? body, String? payload) async {
    return CupertinoAlertDialog(
      title: Text(title!),
      content: Text(body!),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {},
          child: const Text('OK'),
        ),
      ],
    );
  }

  Future<void> onSelectNoti(String? string) async {
    if (string != null) {
      print('strign ==> $string');
      sentToShowNoti(title, message);
    }
  }

  Future<void> processCreateLocalNoti() async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'channelId',
      'channelName',
      priority: Priority.high,
      importance: Importance.max,
      ticker: 'test',
    );

    IOSNotificationDetails iosNotificationDetails =
        const IOSNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotPlugin
        .show(0, title, message, notificationDetails)
        .then((value) => print('Noti show'))
        .catchError((value) {
      print('error on LocalNoti ==> ${value.message}');
    });
  }

  Future<void> setUpMessaging() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    print('token ==>> $token');

    // For BackGround Service
    await FirebaseMessaging.onMessageOpenedApp.listen((event) {
      title = event.notification!.title;
      message = event.notification!.body;
      print('message backGround ==> [$title, $message]');
      processCreateLocalNoti();
      // sentToShowNoti(title, message);
    });

    // For OnGround service
    await FirebaseMessaging.onMessage.listen((event) {
      title = event.notification!.title;
      message = event.notification!.body;
      print('message OnGround ==> [$title, $message]');
      processCreateLocalNoti();
      // sentToShowNoti(title, message);
    });
  }

  void sentToShowNoti(String? title, String? message) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowNoti(title: title!, message: message!),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              newLogo(constraints),
              SignInButton(Buttons.Google,
                  onPressed: () => processGoogleAuthen()),
              SignInButton(Buttons.FacebookNew, onPressed: () {}),
            ],
          );
        }),
      ),
    );
  }

  Future<void> processGoogleAuthen() async {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    await FirebaseAuth.instance
        .signInWithCredential(oAuthCredential)
        .then((value) {
      print('Google Sign Success');
      Navigator.pushNamedAndRemoveUntil(context, '/payment', (route) => false);
    }).catchError((value) {
      print('Error Google SignIn ==>>> ${value.message}');
    });
  }

  SizedBox newLogo(BoxConstraints constraints) {
    return SizedBox(
      width: constraints.maxWidth * 0.6,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: ShowImage(),
      ),
    );
  }
}
