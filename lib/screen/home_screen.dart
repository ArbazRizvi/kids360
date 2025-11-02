import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids360_kids/controller/main_controller.dart';
import 'package:kids360_kids/screen/task_screen.dart';
import 'package:kids360_kids/widgets/sizedbox.dart';
import 'package:kids360_kids/widgets/text_widget.dart';

import '../model/task.dart';

final MainController mainController = Get.find();

// ignore: use_key_in_widget_constructors
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var controller = Get.put(MainController());

  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getCompleteData().then((_) async {
      controller.tasks.forEach((Task task) async {});
      if (controller.tasks.isNotEmpty) {
        for (var task in controller.tasks) {
          final alarmSetting = AlarmSettings(
            id: int.parse(task.id),
            dateTime: DateTime.parse(task.dueDate),
            assetAudioPath: 'assets/alarm.mp3',
            loopAudio: true,
            vibrate: true,
            volume: 0.8,
            fadeDuration: 3.0,
            notificationTitle: task.title,
            notificationBody: task.description,

          );
          await Alarm.set(alarmSettings: alarmSetting);
          await Alarm.setNotificationOnAppKillContent(task.title, task.description);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // showDeleteDialog(context);
        return false;
      },
      child: Scaffold(
        floatingActionButton: Container(
          width: 80,
          child: FloatingActionButton(
            onPressed: () {
              Get.to(TaskScreen());
            },
            isExtended: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Tasks'),
                Icon(Icons.double_arrow_outlined),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: mainController.darkColor,
          leading: sizedBox(0, 0),
          centerTitle: true,
          title: customText(
              "Kids 360", 20.0, FontWeight.bold, Colors.white, "Lora-Regular"),
        ),
        body:
            //  FutureBuilder(
            //     future: DeviceApps.getInstalledApplications(
            //       onlyAppsWithLaunchIntent: true,
            //       includeSystemApps: true,
            //       includeAppIcons: true,
            //     ),
            //     builder: ((context, snapshot) {
            //       if (snapshot.hasData) {
            //         return Container(
            //           child: customText("Please wait", 18.0, FontWeight.normal,
            //               Colors.black, "Lora-Regular"),
            //         );
            //       }
            //       List<Application> apps = snapshot.data as List<Application>;
            //       return
            //        Container(
            //         child:
            ListView.builder(
                shrinkWrap: true,
                itemCount: mainController.installedApps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Image.memory(mainController.appsImage![index]
                                    is ApplicationWithIcon
                                ? mainController.appsImage![index].icon
                                : null),
                          ), // : CircleAvatar(

                          title:
                              Text(mainController.installedApps[index].appName),
                          // subtitle:
                          //     Text(mainController.installedApps[index].),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            color: Colors.grey.shade400,
                          ),
                        )
                      ],
                    ),
                  );
                }),
        //   );
        //  }),
        // ),

        // Obx(
        //   () => ListView.builder(
        //     itemCount: mainController.appUsages.length,
        //     itemBuilder: (context, index) {
        //       return ListTile(
        //         title: Text(mainController.appUsages[index].packageName),
        //         subtitle: Text(
        //             "${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(int.parse(mainController.appUsages[index].lastTimeUsed)))}"),
        //         leading: Text(
        //             "${(int.parse(mainController.appUsages[index].screenTime) / 1000 / 60).toStringAsFixed(2)}"),
        //       );
        //     },
        //   ),
        // ),
      ),
    );
  }
}
