import 'package:get/get.dart';

class LocalUserData {
  Rx<String?> isConnected = Rx<String?>("");
  Rx<String?> parentsUID = Rx<String?>("");
  Rx<String?> childUID = Rx<String?>("");

  LocalUserData({
    String? isConnected,
    String? parentsUID,
    String? childUID,
  }) {
    this.isConnected.value = isConnected;
    this.parentsUID.value = parentsUID;
    this.childUID.value = childUID;
  }
}
