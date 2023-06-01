import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/ui/ReportPages/BudgetPage.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/model/Currency.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class NavMore extends StatefulWidget {
  @override
  _NavMoreState createState() => _NavMoreState();
}

class _NavMoreState extends State<NavMore> {
  //String toLaunch = 'fb://page/103594718332924';
  String toLaunch =
      'https://www.facebook.com/103594718332924/posts/104530501572679/';
  String currencyCode = '', currencySymbol = '';
  @override
  void initState() {
    super.initState();
    //_loadCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          'Settings',
        )),
        body: Consumer<AppStateNotifier>(builder: (context, appState, child) {
          return Container(
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: Text("General"),
                  tiles: [
                    SettingsTile.switchTile(
                      initialValue: appState.isDarkMode,
                      title: Text('Dark mode'),
                      leading: Icon(
                        appState.isDarkMode
                            ? Icons.brightness_3
                            : CupertinoIcons.brightness_solid,
                      ),
                      onToggle: (bool value) {
                        print(value);
                        appState.updateTheme(value);
                      },
                    ),
                    SettingsTile(
                      title: Text("Currency"),
                      trailing: Text(appState.currencyCode),
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 12,
                        child: Text(
                          appState.currencySymbol,
                          style: TextStyle(
                            fontSize: 20,
                            color: const Color(0xff2491ea),
                          ),
                        ),
                      ),
                      onPressed: (context) {
                        _changeCurrencySymbol(context, appState);
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text("Data"),
                  tiles: [
                    SettingsTile(
                      title: Text('Budget'),
                      trailing: Text('Budget list'),
                      leading: Icon(Icons.style),
                      onPressed: (context) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return BudgetPage();
                        }));
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }));
  }

  // Future<void> _launchPage(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(
  //       url,
  //       forceSafariVC: false,
  //       forceWebView: false,
  //       headers: <String, String>{'my_header_key': 'my_header_value'},
  //     );
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  // Future<void> _launchMail() async {
  //   final Uri _emailLaunchUri = Uri(
  //       scheme: 'mailto',
  //       path: 'nextstep2k20@gmail.com',
  //       queryParameters: {'subject': 'Feedback'});
  //   await launch(_emailLaunchUri.toString());
  // }

  void _changeCurrencySymbol(BuildContext context, AppStateNotifier appState) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var data in currency)
                ListTile(
                    leading: CircleAvatar(child: Text(data.symbol)),
                    title: Text(
                      data.code,
                      style: TextStyle(
                          color: data.code == appState.currencyCode
                              ? Colors.white
                              : null),
                    ),
                    onTap: () {
                      appState.setCurrency(data.code, data.symbol, context);
                    },
                    selected: data.code == appState.currencyCode,
                    selectedTileColor: Colors.blue),
            ],
          );
        });
  }

  // void _changeLanguage() {
  //   var _dialog = new Dialog(
  //     child: Container(
  //       height: 101,
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.vertical,
  //         child: Column(
  //           children: [
  //             InkWell(
  //               child: Container(
  //                 height: 50,
  //                 child: Center(child: Text('မြန်မာ')),
  //               ),
  //               onTap: (){
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             Container(
  //               color: Colors.blueGrey,
  //               height: 1,
  //             ),
  //             InkWell(
  //               child: Container(
  //                 height: 50,
  //                 child: Center(child: Text('English')),
  //               ),
  //               onTap: (){
  //                 Navigator.pop(context);
  //               },
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //   showDialog(
  //       context: context,
  //       builder: (_) {
  //         return _dialog;
  //       });
  // }
}
