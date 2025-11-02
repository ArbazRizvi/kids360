import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids360_kids/controller/main_controller.dart';

import '../model/task.dart';
import '../widgets/sizedbox.dart';
import '../widgets/text_widget.dart';
import 'home_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
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
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainController.darkColor,
        leading: sizedBox(0, 0),
        centerTitle: true,
        title: customText(
            "Kids 360", 20.0, FontWeight.bold, Colors.white, "Lora-Regular"),
      ),
      body:ListView.builder(
        itemCount: controller.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          final event = controller.tasks[index];

          return Container(
            height: size.height / 6,
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(8.0),
            color: Color(0x80b1b0b0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 8.0),
                buildRichText(
                  'Title: ${event.title} ',
                ),
                buildRichText(
                  'Description: ${event.description}',
                ),
                buildRichText(
                  'Time: ${DateTime.parse(event.dueDate)}',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  RichText buildRichText(String text) {
    final parts = text.split(':');
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${parts[0]}: ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                overflow: TextOverflow.ellipsis
            ),
          ),
          TextSpan(
            text: parts.length > 1 ? parts.sublist(1).join(':') : '',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }
}
