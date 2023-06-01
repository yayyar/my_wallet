import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/model/BudgetItem.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/Database/DatabaseHelper.dart';
import 'package:my_wallet/util/DateTools.dart';
import 'package:provider/provider.dart';
import 'CategoryListPage.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  int _activeBudget = 1;
  final TextEditingController _budgetNameController =
      new TextEditingController();
  bool _budgetNameValidator = false;
  var _db = new DatabaseHelper();
  List<BudgetItem> _budgetItemsList = <BudgetItem>[];
  bool _isDataLoad = false;
  bool _currentBudget = true;
  _loadBudgetList() async {
    _budgetItemsList = <BudgetItem>[];
    List _items = await _db.getAllBudgetItems();
    _items.forEach((itemList) {
      setState(() {
        _budgetItemsList.add(BudgetItem.map(itemList));
      });
    });
    debugPrint('list=> $_items');
    _isDataLoad = true;
    String monthYear = monthYearFormatted(date: DateTime.now());
    int count = await _db.findCurrentBudget(monthYear);
    if (count == 1) {
      setState(() {
        _currentBudget = false;
      });
    } else {
      setState(() {
        _currentBudget = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBudgetList();
  }

  @override
  Widget build(BuildContext context) {
    final _appStateNotifier =
        Provider.of<AppStateNotifier>(context, listen: false);
    if (_isDataLoad) {
      _appStateNotifier.getBudgetCategoryCount();
      _isDataLoad = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
      ),
      body: ListView.builder(
        itemCount: _budgetItemsList.length,
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {
                if (_activeBudget ==
                    _budgetItemsList[index].toMap()["budgetStatus"]) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CategoryListPage(
                      budgetId: _budgetItemsList[index].toMap()["budgetId"],
                    );
                  }));
                }
              },
              onLongPress: () {
                _showBudgetManageAction(
                    context,
                    _budgetItemsList[index].toMap()["budgetId"],
                    index,
                    _budgetItemsList[index].toMap()["budgetName"],
                    _budgetItemsList[index].toMap()["budgetStatus"]);
              },
              child: Container(
                height: FlResponsiveUI().getProportionalHeight(height: 80),
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_budgetItemsList[index].toMap()['budgetName']}',
                                  style: FlResponsiveUI()
                                      .getTextStyleRegular(fontSize: 18),
                                ),
                                Text(
                                  '${monthYearFormatted(date: DateTime.parse(_budgetItemsList[index].toMap()['budgetDate']))}',
                                  style: FlResponsiveUI()
                                      .getTextStyleRegular(fontSize: 16),
                                ),
                              ],
                            ))),
                    Align(
                      alignment: Alignment.topRight,
                      child: CustomPaint(
                        painter: Chevron(
                            startColor: _activeBudget ==
                                    _budgetItemsList[index]
                                        .toMap()["budgetStatus"]
                                ? Colors.yellow
                                : Colors.blueGrey,
                            endColor: _activeBudget ==
                                    _budgetItemsList[index]
                                        .toMap()["budgetStatus"]
                                ? Colors.yellowAccent
                                : Colors.blueGrey),
                        child: Container(
                          width:
                              FlResponsiveUI().getProportionalWidth(width: 40),
                          height: FlResponsiveUI()
                              .getProportionalHeight(height: 30),
                          margin: EdgeInsets.only(right: 10, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                                "${_appStateNotifier.countMap.containsKey(_budgetItemsList[index].toMap()['budgetId']) ? _appStateNotifier.countMap[_budgetItemsList[index].toMap()['budgetId']] : 0}",
                                style: TextStyle(
                                    color: _activeBudget ==
                                            _budgetItemsList[index]
                                                .toMap()["budgetStatus"]
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Switch(
                            value: _activeBudget ==
                                _budgetItemsList[index].toMap()["budgetStatus"],
                            onChanged: (value) {
                              if (_activeBudget ==
                                  _budgetItemsList[index]
                                      .toMap()["budgetStatus"]) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Deactivate budget"),
                                        content:
                                            Text("Are you sure to deactivate?"),
                                        actions: [
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text('Ok'),
                                            onPressed: () {
                                              _db.updateBudgetStatus();
                                              _updateBudgetItem(
                                                itemName:
                                                    _budgetItemsList[index]
                                                        .toMap()["budgetName"],
                                                id: _budgetItemsList[index]
                                                    .toMap()["budgetId"],
                                                budgetStatus: 0,
                                                alert: true,
                                              );
                                            },
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                _db.updateBudgetStatus();
                                _updateBudgetItem(
                                    itemName: _budgetItemsList[index]
                                        .toMap()["budgetName"],
                                    id: _budgetItemsList[index]
                                        .toMap()["budgetId"],
                                    budgetStatus: 1,
                                    alert: false);
                              }
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: _currentBudget,
        child: FloatingActionButton(
          onPressed: () {
            _showBudgetItemDialog(isCreate: true);
          },
          child: Icon(Icons.add),
          tooltip: 'Add new category',
        ),
      ),
    );
  }

  void _showBudgetItemDialog(
      {required bool isCreate,
      String? budgetItemName,
      int? budgetItemId,
      int? status}) {
    _resetBudget();
    setState(() {
      !isCreate
          ? _budgetNameController.text = budgetItemName ?? ''
          : _budgetNameController.clear();
    });
    var _dialog = new Dialog(
      child: Container(
        height: 150,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
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
                                  '${isCreate ? 'New' : 'Edit'}, ${dayMonthFormatted(date: DateTime.now())}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    _budgetNameController.text.isEmpty
                                        ? _budgetNameValidator = true
                                        : _budgetNameValidator = false;
                                  });
                                  if (!_budgetNameValidator) {
                                    isCreate
                                        ? _setBudgetItem(
                                            budgetName:
                                                _budgetNameController.text)
                                        : _updateBudgetItem(
                                            itemName:
                                                _budgetNameController.text,
                                            id: budgetItemId ?? 0,
                                            budgetStatus: status,
                                            alert: true);
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
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0),
                      child: TextField(
                        controller: _budgetNameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: "Budget",
                          hintText: 'Budget name',
                          icon: Icon(Icons.style),
                          errorText: _budgetNameValidator
                              ? 'Invalid budget name'
                              : null,
                        ),
                      ),
                    )
                  ],
                );
              },
            )),
      ),
    );
    showDialog(
        context: context,
        builder: (_) {
          return _dialog;
        });
  }

  void _resetBudget() {
    _budgetNameValidator = false;
    _budgetNameController.clear();
  }

  void _setBudgetItem({required String budgetName}) async {
    String budgetDate = fullDateFormatted(date: DateTime.now());
    String monthYear = monthYearFormatted(date: DateTime.now());
    BudgetItem _budgetItem =
        new BudgetItem(budgetName, budgetDate, 0, monthYear, budgetDate);
    await _db.saveBudgetItem(_budgetItem);
    _loadBudgetList(); // after insert new budgetItem, reload all budget items
    Navigator.pop(context);
  }

  void _showBudgetManageAction(context, id, index, itemName, budgetStatus) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.edit),
                    title: new Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      _showBudgetItemDialog(
                          isCreate: false,
                          budgetItemName: itemName,
                          budgetItemId: id,
                          status: budgetStatus);
                    }),
                new ListTile(
                  leading: new Icon(Icons.delete),
                  title: new Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteBudgetItem(id, index);
                  },
                ),
              ],
            ),
          );
        });
  }

  _deleteBudgetItem(int id, int index) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete budget"),
            content: Text("Are you sure to delete?"),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  _submitDeleteBudget(id, index);
                },
              )
            ],
          );
        });
  }

  _submitDeleteBudget(id, index) async {
    await _db.deleteBudgetItem(id);
    _loadBudgetList();
    Navigator.pop(context);
  }

  _updateBudgetItem(
      {required String itemName,
      required int id,
      required budgetStatus,
      bool alert = false}) async {
    await _db.updateBudgetItem(itemName, id, budgetStatus);
    setState(() {
      _loadBudgetList();
    });
    if (alert) {
      Navigator.pop(context);
    }
  }
}

class Chevron extends CustomPainter {
  final Color startColor, endColor;
  Chevron({required this.startColor, required this.endColor});
  @override
  void paint(Canvas canvas, Size size) {
    final Gradient gradient = new LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [startColor, endColor],
      tileMode: TileMode.clamp,
    );

    final Rect colorBounds = Rect.fromLTRB(0, 0, size.width, size.height);
    final Paint paint = new Paint()
      ..shader = gradient.createShader(colorBounds);

    Path path = Path();
    path.moveTo(0, 0);
    //path.lineTo(0, size.height);
    //path.lineTo(size.width / 2, size.height - size.height / 3);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
