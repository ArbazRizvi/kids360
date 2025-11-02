import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids360_kids/controller/main_controller.dart';

// ignore: must_be_immutable
class AppDetailScreen extends StatelessWidget {
  AppDetailScreen({super.key});
  MainController mainController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() => ListView.builder(
          itemCount: mainController.appUsages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Text(mainController.appUsages[index].lastTimeUsed.toString()),
            );
          })),
    );
  }
}
