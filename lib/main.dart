import 'package:bestproj/states/authen.dart';
import 'package:bestproj/states/payment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> map = {
  '/payment': (BuildContext context) => const PayMent(),
  '/authen': (BuildContext context) => const Authen(),
};

String? firstState;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) {
    print('Firebase Initial Success');
    firstState = '/authen';
    runApp(const MyApp());
  }).catchError((value) {
    print('Cannot Firebase ${value.code}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: map,
      initialRoute: firstState,
    );
  }
}
