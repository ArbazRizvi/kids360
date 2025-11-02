import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids360_kids/controller/main_controller.dart';

// ignore: must_be_immutable
class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  MainController mainController = Get.put(MainController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
            child: Image.asset(
          "assets/png/kid360 kid.png",
          height: 300.0,
        )),
        const Center(child: CircularProgressIndicator())
      ],
    ));
  }
}
