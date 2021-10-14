import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/viewscreen/signin_screen.dart';

void main() {
  runApp(Lesson3App());
}

class Lesson3App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.DEV,
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
      }
    );
  }
  
}