import 'package:flutter/material.dart';
import 'package:my_wallet/ui/ReportPages/BudgetPage.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/Currency.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NavMore extends StatefulWidget {
  @override
  _NavMoreState createState() => _NavMoreState();
}

class _NavMoreState extends State<NavMore> {
  //String toLaunch = 'fb://page/103594718332924';
  String toLaunch = 'https://www.facebook.com/103594718332924/posts/104530501572679/';
  String currencyCode='', currencySymbol='';
  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Settings',
      )),
      body: Container(
        child: SettingsList(
          sections: [
            SettingsSection(
              title: 'General',
              tiles: [
                SettingsTile.switchTile(
                  title: 'Dark mode',
                  leading: Icon(Icons.brightness_2),
                  switchValue: Provider.of<AppStateNotifier>(context).isDarkMode,
                  onToggle: (bool value) {
                    print(value);
                      Provider.of<AppStateNotifier>(context,listen: false).updateTheme(value);
                  },
                ),
               SettingsTile(
                 title: 'Currency',
                 subtitle: currencyCode,
                 subtitleTextStyle: TextStyle(
                   color: const Color(0xff2491ea),
                 ),
                 leading: CircleAvatar(
                   backgroundColor: Colors.transparent,
                   radius: 12,
                   child: Text(currencySymbol,style: TextStyle(
                     fontSize: 20,
                     color: const Color(0xff2491ea),
                   ),),
                 ),
                 onTap: () {
                   _changeCurrencySymbol(context);
                 },
               ),
              ],
            ),
            SettingsSection(
              title: 'Data',
              tiles: [
                SettingsTile(
                  title: 'Budget',
                  subtitle: 'Budget list',
                  leading: Icon(Icons.style),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return BudgetPage();
                    }));
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'Support us',
              tiles: [
                SettingsTile(
                  title: 'Feedback',
                  leading: Icon(Icons.mail),
                  onTap: () => _launchMail(),
                ),
                SettingsTile(
                  title: 'About',
                  leading: Icon(Icons.info),
                  onTap: () => _launchPage(toLaunch),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPage(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchMail() async {
    final Uri _emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'nextstep2k20@gmail.com',
    queryParameters: {
    'subject': 'Feedback'
    });
    await launch(_emailLaunchUri.toString());
  }

  void _changeCurrencySymbol(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for( var data in currency)
              ListTile(
                leading: CircleAvatar(child:Text(data.symbol)),
                title: Text(data.code,
                style: TextStyle(
                  color: data.code == currencyCode ? Colors.white : null
                ),),
                onTap: () {
                  _setCurrency(data.code, data.symbol, context);
                },
                selected: data.code == currencyCode,
                selectedTileColor: Colors.blue
              ),
            ],
          );
        });
  }

  _loadCurrency() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currencyCode = (prefs.getString('code') ?? 'MMK');
      currencySymbol = (prefs.getString('symbol') ?? 'K');
    });
  }

  void _setCurrency(String code, String symbol, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('code', code);
    prefs.setString('symbol', symbol);
    Navigator.pop(context);
    _loadCurrency();
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
