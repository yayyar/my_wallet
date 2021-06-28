//import 'dart:io';

//import 'package:csv/csv.dart';
import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/model/ExpenseItem.dart';
import 'package:my_wallet/ui/ReportPages/NewExpenseListView.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:my_wallet/util/ActiveBudgetService.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/Database/DatabaseHelper.dart';
import 'package:my_wallet/util/DateTools.dart';
//import 'package:my_wallet/util/FileUtil.dart';
//import 'package:open_file/open_file.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class NavHome extends StatefulWidget {
  @override
  _NavHomeState createState() => _NavHomeState();
}

class _NavHomeState extends State<NavHome> {
  List<dynamic> _dateRangeList;
  String _startDateStr, _endDateStr;
  final TextEditingController _itemNameController = new TextEditingController();
  final TextEditingController _itemExpenseController =
      new TextEditingController();
  String categoryName;
  int _categoryId = 0;
  var _db = new DatabaseHelper();
  var _categoryMap = {};
  List<String> _activeCategoryList = <String>[];
  bool _actualCostValidator = false, _itemDescriptionValidator = false;
  int startPickedDate, endPickedDate;
  var activeBudgetService = new ActiveBudgetService();
  bool _isActiveBudget = false;
  //bool _isFlClick = false;
  //PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _getActiveBudgetCategoryList() async {
    _activeCategoryList = [];
    _categoryMap = {};
    List items = await _db.getActiveBudgetCategory();
    items.forEach((value) {
      _activeCategoryList.add(value['categoryName']);
      _categoryMap[value['categoryId']] = value['categoryName'];
    });
    //debugPrint('Category List => $_activeCategoryList');
    //debugPrint('Category Map => $_categoryMap');
  }

  _initDate() async {
    var now = DateTime.now();
    setState(() {
      _startDateStr = dayMonthFormatted(date: now);
      _endDateStr = dayMonthFormatted(date: now);
    });

    await activeBudgetService.getCurrentBudgetDate();
    DateTime curBudgetDate = DateTime.parse(activeBudgetService.curDateStr);
    DateTime lastUpdateDate = DateTime.parse(activeBudgetService.lastUpdatedDateStr);
    _dateFormatted(dateTime: [curBudgetDate, lastUpdateDate]);

    int count = await _db.findActiveBudget();
    setState(() {
      if(count == 1){
        _isActiveBudget = true;
      }else{
        _isActiveBudget = false;
      }
    });

    _getActiveBudgetCategoryList();
  }

  @override
  void initState() {
    super.initState();
    _initDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Consumer<AppStateNotifier>(builder: (context, appState, child) {
        //debugPrint("Consumer=> ${appState.estimateCost}, ${appState.actualCost}, ${appState.expenseItemList.toString()}");
        return Column(
          children: [
            Container(
              // top layer
              //color: Colors.black45,
              height: FlResponsiveUI().getProportionalHeight(height: 190.0),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          width: double.infinity,
                          height: FlResponsiveUI()
                              .getProportionalHeight(height: 150.0),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: FlResponsiveUI()
                                  .getProportionalHeight(height: 50.0),
                              left: 10.0,
                              right: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MyBudget',
                                style: FlResponsiveUI().getTextStyleRegular(
                                    fontSize: 20, color: Colors.white70),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.cyan),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    final List<DateTime> picked =
                                        await DateRangePicker.showDatePicker(
                                            context: context,
                                            initialFirstDate:
                                                _dateRangeList != null
                                                    ? _dateRangeList[0]
                                                    : new DateTime.now(),
                                            initialLastDate:
                                                _dateRangeList != null
                                                    ? _dateRangeList[1]
                                                    : new DateTime.now(),
                                            firstDate: new DateTime(
                                                DateTime.parse(_dateRangeList[0].toString()).year - 2),
                                            lastDate: new DateTime(
                                                DateTime.parse(_dateRangeList[0].toString()).year + 2),
                                            selectableDayPredicate:
                                                 allowCurrentMonthDay);
                                    if (picked != null && picked.length == 2) {
                                      _dateFormatted(dateTime: picked);
                                      final _appStateNotifier = Provider.of<AppStateNotifier>(context, listen: false);
                                      //startPickedDate = DateTime.parse(fullDateFormatted(date: picked[0])).millisecondsSinceEpoch;
                                      //endPickedDate = DateTime.parse(fullDateFormatted(date: picked[1])).millisecondsSinceEpoch;
                                      _appStateNotifier.getAllExpenseItems(startDate: startPickedDate,endDate: endPickedDate);
                                      _appStateNotifier.getActualCost(startDate: startPickedDate,endDate: endPickedDate);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        '${_startDateStr != null ? _startDateStr : ''}',
                                        style: FlResponsiveUI()
                                            .getTextStyleRegular(
                                                fontSize: 14,
                                                color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.yellow[600],
                                        size: FlResponsiveUI()
                                            .getProportionalWidth(width: 15),
                                      ),
                                      Text(
                                        '${_endDateStr != null ? _endDateStr : ''}',
                                        style: FlResponsiveUI()
                                            .getTextStyleRegular(
                                                fontSize: 14,
                                                color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: Row(
                                  children: [
                                    reportCard(
                                        title: "Estimate",
                                        cost: appState.estimateCost,
                                      currencySymbol: appState.currencySymbol
                                    ),
                                    reportCard(
                                        title: "Actual",
                                        cost: appState.actualCost,
                                      currencySymbol: appState.currencySymbol
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            NewExpenseListView(
              items: appState.expenseItemList,
              startDate: startPickedDate,
                endDate: endPickedDate,
            )
          ],
        );
      }),
     floatingActionButton: Visibility(
       visible: _isActiveBudget,
       child: FloatingActionButton(
         tooltip: "Add new expense",
         onPressed: () {
           _addNewItemDialog();
         },
         child: Icon(
           Icons.edit,
         ),
       ),
     ),
//       floatingActionButton: Visibility(
//         visible: _isActiveBudget,
//         child: Stack(
//           children: <Widget>[
//             Positioned(
//               bottom: 150.0,
//               right: 10.0,
//               child: Visibility(
//                 visible: _isFlClick,
//                 child: Row(
//                   children: [
//                     Card(
//                       child: Container(
//                         height: 22,
//                         width: 70,
//                         child: Center(child: Text('Download')),
//                       ),
//                     ),
//                     FloatingActionButton(
//                       onPressed: () {
//                         requestPermission(Permission.storage);
//                       },
//                       mini: true,
//                       child: Icon(Icons.file_download),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 80.0,
//               right: 10.0,
//               child: Visibility(
//                 visible: _isFlClick,
//                 child: Row(
//                   children: [
//                     Card(
//                       child: Container(
//                         height: 22,
//                         width: 120,
//                         child: Center(child: Text('Add new expense')),
//                       ),
//                     ),
//                     FloatingActionButton(
//                       onPressed: () {
//                         _addNewItemDialog();
//                       },
//                       mini: true,
//                       child: Icon(Icons.edit),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 10.0,
//               right: 10.0,
//               child: FloatingActionButton(
//                 onPressed: () {
//                   setState(() {
//                     _isFlClick = !_isFlClick;
//                   });
//                 },
//                 child: Icon(_isFlClick ? Icons.close : Icons.add),
//               ),
//             ),
//           ],
//         ),
//       ),
    );
  }

  Widget reportCard({String title, double cost, String currencySymbol}) {
    return Container(
      width: FlResponsiveUI().getProportionalWidth(width: 230.0),
      height: FlResponsiveUI().getProportionalHeight(height: 105.0),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: FlResponsiveUI().getTextStyleRegular(
                fontSize: 18,
              ),
            ),
            Text(
              '$currencySymbol ${currencyFormat(data: cost)}',
              style: FlResponsiveUI().getTextStyleRegular(
                fontSize: 20,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _dateFormatted({List dateTime}) {
    setState(() {
      //debugPrint('dateTimePick=> $dateTime');
      _dateRangeList = dateTime;
      //debugPrint('dateTimePickParse=> ${DateTime.parse(_dateRangeList[0].toString()).year}');
      setState(() {
        startPickedDate = DateTime.parse(fullDateFormatted(date: _dateRangeList[0])).millisecondsSinceEpoch;
        endPickedDate = DateTime.parse(fullDateFormatted(date: _dateRangeList[1])).millisecondsSinceEpoch;
        _startDateStr = dayMonthFormatted(date: _dateRangeList[0]);
        _endDateStr = dayMonthFormatted(date: _dateRangeList[1]);
      });
    });
  }

  void _addNewItemDialog() {
    _resetAddItemData();
    var _dialog = new Dialog(
      child: Container(
          height: 290,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              final _appStateNotifier =
                  Provider.of<AppStateNotifier>(context, listen: false);
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'New expense (${dayMonthFormatted(date: DateTime.now())})',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            InkWell(
                                onTap: () async {
                                  setState(() {
                                    if (_itemExpenseController.text.isEmpty) {
                                      _actualCostValidator = true;
                                    } else {
                                      _actualCostValidator = false;
                                    }
                                    if (_itemNameController.text.isEmpty) {
                                      _itemDescriptionValidator = true;
                                    } else {
                                      _itemDescriptionValidator = false;
                                    }
                                  });
                                  if (!_itemDescriptionValidator &&
                                      !_actualCostValidator &&
                                      categoryName.isNotEmpty &&
                                      _categoryId != 0) {
                                    int itemDate = DateTime.parse(fullDateFormatted(date: DateTime.now())).millisecondsSinceEpoch;
                                    String monthYear = monthYearFormatted(date: DateTime.now());
                                    String updateExpenseDate = fullDateFormatted(date: DateTime.now());
                                    ExpenseItem expenseItem = new ExpenseItem(
                                        _itemNameController.text,
                                        double.parse(
                                            _itemExpenseController.text),
                                        itemDate,
                                        _categoryId,monthYear);
                                    await _db.saveExpenseItem(expenseItem);
                                    await _db.updateBudgetExpenseDate(updateExpenseDate);
                                    _appStateNotifier.getAllExpenseItems();
                                    _appStateNotifier.getEstimateCost();
                                    _appStateNotifier.getActualCost();
                                    _initDate();
                                    Navigator.pop(context);
                                  }
                                },
                                child: Icon(
                                  Icons.done,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.category,
                                    color: Color(0xff8C8C8C),
                                  )),
                              Expanded(
                                child: Container(
                                  padding:
                                      EdgeInsets.only(left: 2.0, right: 2.0),
                                  margin: EdgeInsets.only(
                                      top: 8.0, left: 15.0, right: 8.0),
                                  child: DropdownButton<String>(
                                    value: categoryName,
                                    iconSize: 24,
                                    elevation: 16,
                                    underline: Container(
                                      height: 0.8,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        categoryName = newValue;
                                        _categoryId = _categoryMap
                                                .containsValue(categoryName)
                                            ? _categoryMap.keys.firstWhere(
                                                (k) =>
                                                    _categoryMap[k] ==
                                                    categoryName,
                                                orElse: null)
                                            : 0;
                                      });
                                    },
                                    isExpanded: true,
                                    hint: Text('Category'),
                                    items: _activeCategoryList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 5.0, left: 8.0, right: 8.0),
                            child: TextField(
                              controller: _itemExpenseController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Cost",
                                errorText:
                                    _actualCostValidator ? 'Invalid cost' : null,
                                icon: Icon(Icons.data_usage),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: TextField(
                              controller: _itemNameController,
                              decoration: InputDecoration(
                                labelText: "Description",
                                errorText: _itemDescriptionValidator
                                    ? 'Invalid description'
                                    : null,
                                icon: Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
    );
    showDialog(
        context: context,
        builder: (_) {
          return _dialog;
        });
  }

  void _resetAddItemData() {
    _itemDescriptionValidator = false;
    _actualCostValidator = false;
    categoryName = null;
    _categoryId = 0;
    _itemNameController.clear();
    _itemExpenseController.clear();
    // setState(() {
    //   _isFlClick = false;
    // });
  }
//   Future<void> requestPermission(Permission permission) async {
//     final status = await permission.request();
//     _permissionStatus = status;
//     _downloadCSV();
//   }
//   _downloadCSV() async {
//
//     if (_permissionStatus.isGranted) {
//
//       List allExpenseList = await _db.getAllExpenseToDownload(startDate: startPickedDate,endDate: endPickedDate);
//       if(allExpenseList.length <= 0){
//         _scaffoldKey.currentState.showSnackBar(
//           SnackBar(
//             content: Text('No data to download'),
//           ),
//         );
//         setState(() {
//           _isFlClick = false;
//         });
//       } else if( allExpenseList.length > 0){
//         //print('AllExp => $allExpenseList');
//         List associateList = [
//           {
//             'itemNameDescription': 'Item name',
//             'categoryName': 'Category name',
//             'itemDate': 'Date',
//             'actualCost': 'Cost'
//           }
//         ];
//         associateList.addAll(allExpenseList);
//
//         List<List<dynamic>> rows = List<List<dynamic>>();
//         for (int i = 0; i < associateList.length; i++) {
//           List<dynamic> row = List();
//           row.add(associateList[i]['itemNameDescription']);
//           row.add(associateList[i]['categoryName']);
//           row.add(i !=0 ? fullDateFormatted(date: DateTime.fromMillisecondsSinceEpoch(associateList[i]['itemDate'])) : 'Date');
//           row.add(associateList[i]['actualCost']);
//           rows.add(row);
//         }
//         //debugPrint('Rows => $rows');
//         String folderName = 'Download';
//         String folderPath = await FileUtil.createFolderInDesireDir(folderName);
//         //debugPrint('FolderPath => $folderPath');
//
//         File f = new File(folderPath + "${fullDateAndTime(date: DateTime.now())}_budget.csv");
//         //debugPrint('File => $f');
//
//         String csv = const ListToCsvConverter().convert(rows);
//         //debugPrint('CSV => $csv');
//
//         f.writeAsString(csv);
//         _scaffoldKey.currentState.showSnackBar(
//           SnackBar(
//             content: Text('Download success'),
// //          action: SnackBarAction(
// //            label: 'Open',
// //            onPressed: () async{
// //              String path = f.path;
// //              debugPrint('Path => $path');
// //              await OpenFile.open(path);
// //            },
// //          ),
//           ),
//         );
//       }
//     } else if (_permissionStatus.isDenied) {
//       _scaffoldKey.currentState.showSnackBar(
//         SnackBar(
//           content: Text('Storage is not accessed to download'),
//         ),
//       );
//     }
//     setState(() {
//       _isFlClick = false;
//     });
//   }

}
