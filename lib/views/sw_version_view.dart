import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/providers/all_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SwVersionView extends ConsumerStatefulWidget {
  const SwVersionView({super.key});

  @override
  SwVersionViewState createState() => SwVersionViewState();
}

class SwVersionViewState extends ConsumerState<SwVersionView> {
  String appVersion = "";
  String allDatabaseVersion = "";
  String userDatabaseVersion = "";
  double fontSize = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchVersionInfo();
  }

  Future<void> _fetchVersionInfo() async {
    // Get the app version from package_info_plus
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;

    // Get the database versions (converting int to String)
    allDatabaseVersion = await _getAllDatabaseVersion();
    userDatabaseVersion = await _getUserDatabaseVersion();

    // Update the state to display the versions
    setState(() {});
  }

  Future<String> _getAllDatabaseVersion() async {
    try {
      String currentVersion = (await AllProvider.getCurrentDatabaseVersion()).toString();
      debugPrint('Current all.sqlite version: $currentVersion');
      return currentVersion;
    } catch (e) {
      debugPrint('Error fetching all.sqlite database versions: $e');
      return "Error all.sqlite"; // Error case, return -1 for invalid version
    }
  }  

  Future<String> _getUserDatabaseVersion() async {
    try {
      String currentVersion = (await UserProvider.getCurrentDatabaseVersion()).toString();
      debugPrint('Current users.sqlite version: $currentVersion');
      return currentVersion;
    } catch (e) {
      debugPrint('Error fetching users.sqlite database versions: $e');
      return "Error users.sqlite"; // Error case, return -1 for invalid version
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    if (screenInfo.isTablet && MediaQuery.of(context).orientation == Orientation.landscape) {
      fontSize *= 1.3;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "版本資訊",
          style: TextStyle(
            fontSize: fontSize * 1.5,
          ),
        ),
      ),
      backgroundColor: beige, // Set background color to beige
      body: _buildVersion(),
    );
  }

  Widget _buildVersion() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.5, vertical: fontSize * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App 版本: $appVersion',
            style: TextStyle(fontSize: fontSize * 1.0, color: Colors.black),
          ),
          Text(
            'all.sqlite 版本: $allDatabaseVersion',
            style: TextStyle(fontSize: fontSize * 1.0, color: Colors.black),
          ),
          Text(
            'user.sqlite 版本: $userDatabaseVersion',
            style: TextStyle(fontSize: fontSize * 1.0, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
