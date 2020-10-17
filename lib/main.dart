import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:scoped_model/scoped_model.dart';

import 'models/userModel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final FirebaseAuth mAuth = FirebaseAuth.instance;
  UserModel userModel = UserModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: userModel,
      child: MaterialApp(
        title: 'Fretes Go',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        //home: HomePage(),
        home: HomePage(),
      ),
    );
  }

}

