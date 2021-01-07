//import 'package:device_preview/device_preview.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/ui/MyHomePage.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//void main() {
//  runApp(DevicePreview(
//    enabled: !kReleaseMode,
//    builder: (context) => MyApp(),
//  ));
//}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      create: (_) => AppStateNotifier(prefs),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
//    return MaterialApp(
//      locale: DevicePreview.of(context).locale, // <--- /!\ Add the locale
//      builder: DevicePreview.appBuilder, // <--- /!\ Add the builder
//      debugShowCheckedModeBanner: false,
//      title: 'MyWallet',
//      theme: ThemeData(
//        primarySwatch: Colors.blueGrey,
//        primaryColor: Colors.blueGrey,
//        visualDensity: VisualDensity.adaptivePlatformDensity,
//        brightness: Brightness.light
//      ),
//      home: MyHomePage(title: 'MyWallet'),
//    );
    return Consumer<AppStateNotifier>(
      builder: (context, appState, child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyWallet',
          theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              primaryColor: Colors.blueGrey,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              brightness: appState.isDarkMode ? Brightness.dark : Brightness.light
          ),
          home: MyHomePage(title: 'MyWallet'),
        );
      },
    );
  }
}
