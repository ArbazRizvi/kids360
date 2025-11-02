import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids360_kids/controller/main_controller.dart';
import 'package:kids360_kids/widgets/text_widget.dart';

// ignore: must_be_immutable
class ConnectionScreen extends StatelessWidget {
  ConnectionScreen({super.key});

  MainController mainController = Get.find();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // showDeleteDialog(context);
        return false;
      },
      child: Scaffold(

          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: mainController.parentIdController,
                    decoration: InputDecoration(
                      hintText: 'Enter your Parents Id',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: mainController.connectionLoad.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : InkWell(
                      onTap: () async {
                        mainController.connectionLoad.value = true;
                        await mainController.getAllData();
                        await mainController.connectionBuilder();
                      },
                      child: Container(
                        width: Get.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: mainController.darkColor,
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(
                          //   color: Colors
                          //       .blue, // Change border color based on focus
                          //   width: 2,
                          // ),
                        ),
                        child: Center(
                          child: customText("Connect", 17.0, FontWeight.normal,
                              Colors.white, "Lora-Regular"),
                        ),
                      ),
                    ),
            ),
          )),
    );
  }
}
