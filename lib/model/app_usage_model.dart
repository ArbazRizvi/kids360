class AppUsage {
  final String appName;
  final String packageName;
  final String screenTime;
  final String lastTimeUsed;

  AppUsage({
    required this.appName,
    required this.packageName,
    required this.screenTime,
    required this.lastTimeUsed,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'screenTime': screenTime,
      'lastTimeUsed': lastTimeUsed,
    };
  }

  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      appName: map['appName'] ?? '',
      packageName: map['packageName'] ?? '',
      screenTime: map['screenTime'] ?? '',
      lastTimeUsed: map['lastTimeUsed'] ?? '',
    );
  }
}
