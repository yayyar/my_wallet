import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/model/ExpenseItem.dart';
import 'package:my_wallet/ui/ReportPages/NewExpenseListView.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/Database/DatabaseHelper.dart';
import 'package:my_wallet/util/DateTools.dart';
import 'package:my_wallet/widget/date_range_picker.dart';
import 'package:provider/provider.dart';

class NavHome extends StatefulWidget {
  @override
  _NavHomeState createState() => _NavHomeState();
}

class _NavHomeState extends State<NavHome> {
  final TextEditingController _itemNameController = new TextEditingController();
  final TextEditingController _itemExpenseController =
      new TextEditingController();
  String? categoryName;
  int _categoryId = 0;
  var _db = new DatabaseHelper();
  var _categoryMap = {};
  List<String> _activeCategoryList = <String>[];
  bool _actualCostValidator = false, _itemDescriptionValidator = false;
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

    int count = await _db.findActiveBudget();
    setState(() {
      if (count == 1) {
        _isActiveBudget = true;
      } else {
        _isActiveBudget = false;
      }
    });

    //debugPrint('Category List => $_activeCategoryList');
    //debugPrint('Category Map => $_categoryMap');
  }

  @override
  void initState() {
    super.initState();
    _getActiveBudgetCategoryList();
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
                          margin:
                              EdgeInsets.only(top: 50, left: 10.0, right: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MyBudget',
                                style: FlResponsiveUI().getTextStyleRegular(
                                    fontSize: 20, color: Colors.white70),
                              ),
                              DateRangePickerWidget(),
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
                                        currencySymbol:
                                            appState.currencySymbol),
                                    reportCard(
                                        title: "Actual",
                                        cost: appState.actualCost,
                                        currencySymbol:
                                            appState.currencySymbol),
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
              startDate: DateTime.parse(appState.activeStartDate)
                  .millisecondsSinceEpoch,
              endDate:
                  DateTime.parse(appState.activeEndDate).millisecondsSinceEpoch,
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
    );
  }

  Widget reportCard(
      {required String title,
      required double cost,
      required String currencySymbol}) {
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
                                      categoryName != null &&
                                      _categoryId != 0) {
                                    int itemDate = DateTime.parse(
                                            fullDateFormatted(
                                                date: DateTime.now()))
                                        .millisecondsSinceEpoch;
                                    String monthYear = monthYearFormatted(
                                        date: DateTime.now());
                                    String updateExpenseDate =
                                        fullDateFormatted(date: DateTime.now());
                                    ExpenseItem expenseItem = new ExpenseItem(
                                        _itemNameController.text,
                                        double.parse(
                                            _itemExpenseController.text),
                                        itemDate,
                                        _categoryId,
                                        monthYear);
                                    await _db.saveExpenseItem(expenseItem);
                                    await _db.updateBudgetExpenseDate(
                                        updateExpenseDate);
                                    _appStateNotifier.getAllExpenseItems();
                                    _appStateNotifier.getEstimateCost();
                                    _appStateNotifier.getActualCost();
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
                                    onChanged: (newValue) {
                                      if (newValue != null)
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
                                errorText: _actualCostValidator
                                    ? 'Invalid cost'
                                    : null,
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
  }
}
