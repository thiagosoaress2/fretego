import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/move_day_page_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/selected_items_chart_model.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/utils/notificationHelper.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/userModel.dart';
import 'dart:io' show Platform;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(flutterLocalNotificationsPlugin);

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  //new firebase auth
  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  bool _initialized = false;

  bool _error = false;

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }


  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  final FirebaseAuth mAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return somethingGetWrong();
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Center(child: CircularProgressIndicator(),);
    }

    return myStartPage();
  }


  Widget myStartPage() {
    UserModel userModel = UserModel();
    NewAuthService newAuthService = NewAuthService();
    HomePageModel homePageModel = HomePageModel();
    MoveDayPageModel moveDayPageModel = MoveDayPageModel();
    MoveModel moveModel = MoveModel();

    const blue = const Color(0xff247BA0);

    return ScopedModel<UserModel>(
      model: userModel,
      child: ScopedModel<NewAuthService>(
        model: newAuthService,
        child: ScopedModel<HomePageModel>(
          model: homePageModel,
          child: ScopedModel<MoveDayPageModel>(
            model: moveDayPageModel,
            child: ScopedModel<MoveModel>(
              model: moveModel,
              child: MaterialApp(
                title: 'Fretes Go',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  primaryColor: blue,


                ),
                //home: HomePage(),
                home: HomePage(),
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                ],
                supportedLocales: [
                  const Locale('pt'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget somethingGetWrong() {
    return Text("Algo errado com o fireFlutter");
  }


}


