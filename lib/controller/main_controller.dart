import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kids360_kids/model/app_usage_model.dart';
import 'package:kids360_kids/model/local_user_model.dart';
import 'package:kids360_kids/screen/connection_screen.dart';
import 'package:location/location.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';
import 'package:get/get.dart';
import 'package:kids360_kids/screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import '../model/task.dart';
// import 'dart:typed_data';

class MainController extends GetxController {
  Color darkColor = const Color(0xff0379ff);
  RxList<Application> installedApps = <Application>[].obs;
  RxList<AppUsage> appUsages = <AppUsage>[].obs;
  final getStorageBox = GetStorage();
  var childLocalData = Rx<LocalUserData?>(
      LocalUserData(isConnected: "", parentsUID: "", childUID: ""));
//location var
  Location location = Location();
  var tasks = <Task>[].obs;
  var connectionLoad = false.obs;

  bool? serviceEnabled;
  PermissionStatus? permissionGranted;
  LocationData? locationData;
  List? appsImage;
  @override
  void onInit() async {
    super.onInit();
    getCompleteData();


  }
Future<void> getCompleteData() async {
  await readGetStorage();

  await getAllData();
  appsImage = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeAppIcons: true,
      includeSystemApps: true);

  await getLocationDetails().whenComplete(() async {
    if (childLocalData.value!.isConnected.value.toString() == "null" ||
        childLocalData.value!.isConnected.value!.isEmpty) {
      Get.to(() => ConnectionScreen());
    } else if (childLocalData.value!.isConnected.value == "true") {
      Get.to(() => HomeScreen());
      fetchTasks(childLocalData.value!.childUID.value!);
      await updateAppUsagesToFirestore(
          appUsages, childLocalData.value!.childUID.value!);
    } else {
      print("Koe or masla: ${childLocalData.value!.isConnected.value}");
    }
  });
}

  void fetchTasks(String deviceId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('child_section')
          .doc(deviceId)
          .collection('tasks')
          .get();

      tasks.value = querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  Future<void> getLocationDetails() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled!) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled!) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    print(
        "latitude: ${locationData!.latitude} /longitude: ${locationData!.longitude} ");
  }

  Future<void> getAllData() async {
    await getAllInstalledApps();
    await getUsageInfo();
    print("check length in connection getAllData: ${appUsages.length}");
    // You can add other operations here if needed
  }

  Future<void> getAllInstalledApps() async {
    // grant usage permission - opens Usage Settings
    UsageStats.grantUsagePermission();

    // check if permission is granted
    bool? permissionResult = await UsageStats.checkUsagePermission();

    // Now, check if permissionResult is not null and then assign its value to isPermission.
    bool isPermission = permissionResult ?? false;
    try {
      List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeSystemApps: true,
        includeAppIcons: true,
      );
      print("Total Apps in mob: ${apps.length}");
      installedApps.assignAll(apps);
    } catch (e) {
      // Error handling
      print("Error fetching installed apps: $e");
      installedApps.clear(); // or handle error as needed
    }
  }

  Future<void> getUsageInfo() async {
    DateTime endDate = DateTime.now();
    DateTime startDate =
        DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

    List<UsageInfo> usageStats =
        await UsageStats.queryUsageStats(startDate, endDate);

    List<AppUsage> usages = [];
    for (int i = 0; i < installedApps.length; i++) {
      Application app = installedApps[i];
      UsageInfo? appUsageInfo;
      for (var element in usageStats) {
        if (element.packageName == app.packageName) {
          appUsageInfo = element;
          break;
        }
      }
      if (appUsageInfo != null) {
        AppUsage appUsage = AppUsage(
          //  appIcon: app.packageName,
          appName: app.appName,
          packageName: app.packageName,
          lastTimeUsed: appUsageInfo.lastTimeUsed!,
          screenTime: appUsageInfo.totalTimeInForeground!,
        );
        usages.add(appUsage);
      }
    }
    appUsages.assignAll(usages);
  }

  TextEditingController parentIdController = TextEditingController();
  Future<void> connectionBuilder() async {
    // final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // final CollectionReference appUsagesCollection =
    //     firestore.collection('child_section');
    // // Save the map as a single document for the device
    // DocumentReference documentReference = appUsagesCollection.doc();
    // //  await documentReference.set({"parentID": parentIdController.text});
    // // Update the document with the generated document ID as the uid
    // //   await documentReference.update({"childUid": documentReference.id});
    await saveAppUsagesToFirestore(appUsages);

    Get.to(() => HomeScreen());
  }

  Future<void> saveAppUsagesToFirestore(List<AppUsage> appUsages) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference appUsagesCollection =
        firestore.collection('child_section');

    // Create a map to hold all app usage data
    Map<String, dynamic> usageData = {};
    print("check length in saveAppUsagesToFirestore: ${appUsages.length}");
    // Add each AppUsage to the map

    for (var appUsage in appUsages) {
      usageData[appUsage.packageName] = {
        'appName': appUsage.appName,
        'screenTime': appUsage.screenTime,
        'lastTimeUsed': appUsage.lastTimeUsed,
      };
    }

    // Save the map as a single document for the device
    DocumentReference documentReference = appUsagesCollection.doc();
    await documentReference.set(usageData);
    print(
        "firs time run (parentIdController.text): ${parentIdController.text}");
    print("firs time run (documentReference.id): ${documentReference.id}");
    print("firs time run (locationData!.latitude): ${locationData!.latitude}");
    print(
        "firs time run (locationData!.longitude): ${locationData!.longitude}");
    print(
        "firs time run (datetime): ${DateTime.now().hour}:${DateTime.now().minute}/${DateTime.now().day}-${DateTime.now().month}");
    String? token = await FirebaseMessaging.instance.getToken();

    await documentReference.update({
      "parentID": parentIdController.text,
      "childUID": documentReference.id,
      "langitude": locationData!.latitude,
      "longitude": locationData!.longitude,
      "datetime":
          "${DateTime.now().hour}:${DateTime.now().minute}/${DateTime.now().day}-${DateTime.now().month}",
      'token':token??''
    });
    writeGetStorage("true", parentIdController.text, documentReference.id);
    parentIdController.clear();
  }

  Future<void> updateAppUsagesToFirestore(
      List<AppUsage> appUsages, String doc) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference appUsagesCollection =
        firestore.collection('child_section');

    // Create a map to hold all app usage data
    Map<String, dynamic> usageData = {};
    print("check length in updateAppUsagesToFirestore: ${appUsages.length}");
    String? token = await FirebaseMessaging.instance.getToken();
    for (var appUsage in appUsages) {
      usageData[appUsage.packageName] = {
        'appName': appUsage.appName,
        'screenTime': appUsage.screenTime,
        'lastTimeUsed': appUsage.lastTimeUsed,
      };
    }

    // Save the map as a single document for the device
    DocumentReference documentReference = appUsagesCollection.doc(doc);
    await documentReference.set(usageData);
    print(
        "update time run (childLocalData.value!.parentsUID.value): ${childLocalData.value!.parentsUID.value}");
    print(
        "update time run (childLocalData.value!.childUID.value): ${childLocalData.value!.childUID.value}");
    print(
        "update time run (locationData!.latitude): ${locationData!.latitude}");
    print(
        "update time run (locationData!.longitude): ${locationData!.longitude}");
    print(
        "update time run (datetime): ${DateTime.now().hour}:${DateTime.now().minute}/${DateTime.now().day}-${DateTime.now().month}");
//https://chat.openai.com/share/500e449a-af95-4ba9-ad81-c7e2684fb04f
    // Update the document with the generated document ID as the uid

    await documentReference.update({
      "parentID": childLocalData.value!.parentsUID.value,
      "childUID": childLocalData.value!.childUID.value,
      "langitude": locationData!.latitude,
      "longitude": locationData!.longitude,
      "datetime":
          "${DateTime.now().hour}:${DateTime.now().minute}/${DateTime.now().day}-${DateTime.now().month}",
    'token':token??''
    });
    readGetStorage();
  }

  List<AppUsage> appUsagesget = [];

  Future<List<AppUsage>> getAppUsagesFromFirestore(String deviceId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference appUsagesCollection =
        firestore.collection('child_section');
    final CollectionReference tasks =
    firestore.collection('child_section').doc(deviceId).collection('tasks');

    try {
      // Get the document with the specified device ID
      DocumentSnapshot documentSnapshot =
          await appUsagesCollection.doc(deviceId).get();
      QuerySnapshot documentSnapshot2 =
          await tasks.get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Retrieve the data from the document
        print("documentSnapshot.exists");
        Map<String, dynamic> usageData =
            documentSnapshot.data() as Map<String, dynamic>;


        // Convert the data into a list of AppUsage objects
        usageData.forEach((packageName, data) {
          // Check if screenTime and lastTimeUsed are integers, or try to convert them
          print("for each");
          int screenTime;
          int lastTimeUsed;
          try {
            screenTime = int.parse(data['screenTime']);
            lastTimeUsed = int.parse(data['lastTimeUsed']);
          } catch (e) {
            // Error parsing screenTime or lastTimeUsed to int, skip this entry
            print("Error parsing data for packageName $packageName: $e");
            //     if (data['screenTime'] == 'parentID') {

            //  } else if (data['screenTime'] == 'childUID') {

            //  }

            return; // Skip to the next iteration of the loop
          }

          // Create AppUsage object and add to list
          AppUsage appUsage = AppUsage(
            // appIcon: data['appIcon'],
            appName: data['appName'],
            packageName: packageName,
            screenTime:
                screenTime.toString(), // Convert back to string if needed
            lastTimeUsed:
                lastTimeUsed.toString(), // Convert back to string if needed
          );
          appUsagesget.add(appUsage);
        });

        return appUsagesget;
      } else {
        // Document does not exist
        return [];
      }
    } catch (e) {
      // Error handling
      print("Error getting app usages: $e");
      return []; // Return an empty list or handle the error as needed
    }
  }

  Future<void> printChildUID() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference appUsagesCollection =
        firestore.collection('child_section');
    try {
      // Get all documents in the collection
      QuerySnapshot querySnapshot = await appUsagesCollection.get();

      // Check if there are any documents in the collection
      if (querySnapshot.docs.isNotEmpty) {
        // Access the first document and print the value of 'childUID'
        print("childUID: ${querySnapshot.docs[0]['childUID']}");
      } else {
        // Handle case when there are no documents in the collection
        print("No documents found in the collection.");
      }
    } catch (e) {
      // Error handling
      print("Error printing childUID: $e");
    }
  }

//  List<AppUsage> appUsagesfirst = [];

// Future<List<AppUsage>> getAppUsagesFromFirestoretwo(String deviceId) async {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final CollectionReference appUsagesCollection =
//       firestore.collection('child_section');

//   try {
//     // Get the document with the specified device ID
//     DocumentSnapshot documentSnapshot =
//         await appUsagesCollection.doc(deviceId).get();

//     // Check if the document exists
//     if (documentSnapshot.exists) {
//       // Retrieve the data from the document
//       print("documentSnapshot.exists");
//       Map<String, dynamic> usageData =
//           documentSnapshot.data() as Map<String, dynamic>;

//       String? parentID;
//       String? childUID;

//       // Iterate over each key-value pair in the usageData map
//       usageData.forEach((key, value) {
//         // Check if the key is 'parentID' or 'childUID'
//         if (key == 'parentID') {
//           parentID = value.toString();
//         } else if (key == 'childUID') {
//           childUID = value.toString();
//         } else {
//           // Handle other fields (excluding 'parentID' and 'childUID')
//           // Check if screenTime and lastTimeUsed are integers, or try to convert them
//           print("for each");
//           int screenTime;
//           int lastTimeUsed;
//           try {
//             screenTime = int.parse(value['screenTime']);
//             lastTimeUsed = int.parse(value['lastTimeUsed']);
//           } catch (e) {
//             // Error parsing screenTime or lastTimeUsed to int, skip this entry
//             print("Error parsing data for packageName $key: $e");
//             return; // Skip to the next iteration of the loop
//           }

//           // Create AppUsage object and add to list
//           AppUsage appUsage = AppUsage(
//             appName: value['appName'],
//             packageName: key,
//             screenTime: screenTime.toString(), // Convert back to string if needed
//             lastTimeUsed: lastTimeUsed.toString(), // Convert back to string if needed
//           );
//           appUsagesfirst.add(appUsage);
//         }
//       });

//       // Create a ParentChildIds object
//       ParentChildIds parentChildIds = ParentChildIds(
//         parentID: parentID ?? '', // Use empty string if parentID is null
//         childUID: childUID ?? '', // Use empty string if childUID is null
//       );

//       // You can return both appUsages and parentChildIds here
//       return appUsagesfirst;
//     } else {
//       // Document does not exist
//       return [];
//     }
//   } catch (e) {
//     // Error handling
//     print("Error getting app usages: $e");
//     return []; // Return an empty list or handle the error as needed
//   }
// }
// Future<Uint8List> getAppIcon(String packageName) async {
//   PackageInfo packageInfo = await PackageInfo.fromPlatform();
//   // if (packageInfo.packageName == packageName) {
//   //   return FlutterLauncherIcons.getDefaultIcon();
//   // }
//   // return FlutterLauncherIcons.getIconFromPackage(packageName);
// }
//get purchase data

  writeGetStorage(
      String isConnected, String parentsUID, String childUID) async {
    await getStorageBox.write("isConnected", isConnected);
    await getStorageBox.write("parentsUID", parentsUID);
    await getStorageBox.write("childUID", childUID);
    readGetStorage();
  }

  Future<void> readGetStorage() async {
    childLocalData.value!.isConnected.value =
        getStorageBox.read("isConnected").toString();
    childLocalData.value!.parentsUID.value =
        getStorageBox.read("parentsUID").toString();
    childLocalData.value!.childUID.value =
        getStorageBox.read("childUID").toString();

    print("check length in  ${childLocalData.value!.isConnected.value}");
    print("check length in  ${childLocalData.value!.parentsUID.value}");
    print("check length in  ${childLocalData.value!.childUID.value}");
  }

//web scraping
  Future<String?> getAppIconUrl(String packageName) async {
    // Construct the URL for the app's page on the Google Play Store
    String url = 'https://play.google.com/store/apps/details?id=$packageName';

    // Send an HTTP GET request to the Play Store page
    var response = await http.get(Uri.parse(url));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Extract the URL of the app's icon image from the HTML content
      var iconUrl = extractAppIconUrlFromHtml(response.body);
      return iconUrl;
    }

    // Return null if unable to retrieve the icon URL
    return null;
  }

  String? extractAppIconUrlFromHtml(String htmlContent) {
    // Parse the HTML content
    var document = html.parse(htmlContent);

    // Extract the URL of the app's icon image
    var iconElement = document.querySelector('img.T75of.cN0oRe.fFmL2e');
    if (iconElement != null) {
      return iconElement.attributes['src'];
    }

    // Return null if unable to retrieve the icon URL
    return null;
  }

  List appIconUrlList = [].obs;
  Future<void> makeAppIconUrlList() async {
    appIconUrlList.clear();
    for (var element in appUsagesget) {
      // Call getAppIconUrl for each package name
      String? iconUrl = await getAppIconUrl(element.packageName);
      // Add the icon URL or null to the list
      appIconUrlList.add(iconUrl);
    }
  }
}
