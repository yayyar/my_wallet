import 'package:flutter/material.dart';
import 'package:my_wallet/ui/MyHomePage.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return Consumer<AppStateNotifier>(
      builder: (context, appState, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyBudget',
          theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              primaryColor: Colors.blueGrey,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              brightness:
                  appState.isDarkMode ? Brightness.dark : Brightness.light),
          home: MyHomePage(title: 'MyBudget'),
        );
      },
    );
  }
}
