import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/Database/DatabaseHelper.dart';
import 'package:my_wallet/util/DateTools.dart';
import 'package:provider/provider.dart';

class ItemDetailPage extends StatefulWidget {
  final String title;
  final int categoryId;
  final int startDate;
  final int endDate;
  ItemDetailPage({this.title, this.categoryId, this.startDate, this.endDate});
  @override
  _ItemDetailPageState createState() =>
      _ItemDetailPageState(categoryId, startDate, endDate);
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  DatabaseHelper _db = new DatabaseHelper();
  List _expenseItemsList = [];
  final int categoryId;
  final int startDate;
  final int endDate;
  double _estimateCost = 0.0, _actualCost = 0.0;

  _ItemDetailPageState(this.categoryId, this.startDate, this.endDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          '${widget.title != null ? widget.title : 'CC'}',
        )),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.blueGrey,
                  ),
                  itemCount: _expenseItemsList.length,
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onLongPress: () {
                        _deleteItemDialog(
                            _expenseItemsList[index]['itemId'], index);
                      },
                      child: Container(
                        height: 55,
                        child: Stack(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_expenseItemsList[index]['itemNameDescription']}',
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          '${fullDateFormatted(date: DateTime.fromMillisecondsSinceEpoch(_expenseItemsList[index]['itemDate']))}',
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ))),
                            Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    '${_expenseItemsList[index]['actualCost']} Ks',
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.blueGrey,
                height: FlResponsiveUI().getProportionalHeight(height: 65),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Estimate:   $_estimateCost Ks',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                      child: VerticalDivider(
                        color: Colors.white,
                        thickness: 1.0,
                      ),
                    ),
                    Text(
                      'Actual:   $_actualCost Ks',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  _getExpenseItems() async {
    _expenseItemsList = [];
    _actualCost = 0.0;
    _estimateCost = 0.0;
    //debugPrint('categoryId=> $categoryId, date=> $startDate, $endDate');
    List items = await _db.getExpenseItems(
        categoryId: categoryId, startDate: startDate, endDate: endDate);
    setState(() {
      _expenseItemsList = items;
      _estimateCost = _expenseItemsList.isNotEmpty
          ? _expenseItemsList[0]['estimateCost']
          : 0.0;
      if (_expenseItemsList.isNotEmpty) {
        _expenseItemsList.forEach((value) {
          _actualCost += value['actualCost'];
        });
      } else {
        _actualCost = 0.0;
      }
    });
//    debugPrint('D All expense items list => $_expenseItemsList');
//    debugPrint('D Estimate cost => $_estimateCost');
//    debugPrint('D Actual cost => $_actualCost');
    if (_expenseItemsList.isEmpty) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _getExpenseItems();
  }

  _deleteItemDialog(int id, int index) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final _appStateNotifier =
              Provider.of<AppStateNotifier>(context, listen: false);
          return AlertDialog(
            title: Text("Delete"),
            content: Text("Are you sure to delete?"),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Ok'),
                onPressed: () async {
                  //_submitDelete(id, index);
                  await _db.deleteExpenseItem(id);
                  await _getExpenseItems();
                  _appStateNotifier.getAllExpenseItems(
                      startDate: startDate, endDate: endDate);
                  //_appStateNotifier.getEstimateCost();
                  _appStateNotifier.getActualCost(
                      startDate: startDate, endDate: endDate);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
