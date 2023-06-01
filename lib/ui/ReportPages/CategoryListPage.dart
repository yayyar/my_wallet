import 'package:flutter/material.dart';
import 'package:my_wallet/model/BudgetCategoryItem.dart';
import 'package:my_wallet/model/CategoryItem.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/Database/DatabaseHelper.dart';
import 'package:my_wallet/util/DateTools.dart';
import 'package:provider/provider.dart';

class CategoryListPage extends StatefulWidget {
  final int budgetId;
  CategoryListPage({required this.budgetId});
  @override
  _CategoryListPageState createState() => _CategoryListPageState(budgetId);
}

class _CategoryListPageState extends State<CategoryListPage> {
  final int budgetItemId;

  _CategoryListPageState(this.budgetItemId);

  final TextEditingController _categoryNameController =
      new TextEditingController();
  final TextEditingController _categoryEstimateCostController =
      new TextEditingController();
  bool _categoryNameValidator = false, _categoryEstimateCostValidator = false;
  var _db = new DatabaseHelper();

  List _budgetCategoryItemsList = [];
  bool _isLoadNewCategory = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _loadBudgetCategoryList() async {
    _budgetCategoryItemsList = [];
    debugPrint('budgetId => $budgetItemId');
    List _items = await _db.getAllBudgetCategoryItems(budgetItemId);
    _items.forEach((itemList) {
      setState(() {
        _budgetCategoryItemsList.add(itemList);
      });
    });
    debugPrint('_budgetCategoryItemsList=> $_budgetCategoryItemsList');
    _isLoadNewCategory = true;
  }

  @override
  void initState() {
    super.initState();
    _loadBudgetCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    final _appStateNotifier =
        Provider.of<AppStateNotifier>(context, listen: false);
    if (_isLoadNewCategory) {
      _appStateNotifier.getBudgetCategoryCount();
      _isLoadNewCategory = false;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Category'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _budgetCategoryItemsList.length,
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title:
                    Text('${_budgetCategoryItemsList[index]['categoryName']}'),
                subtitle: Text(
                  'Estimate ${_budgetCategoryItemsList[index]['estimateCost']} Ks',
                ),
                trailing: Listener(
                  onPointerDown: (pointerEvent) {
                    _deleteCategoryItem(
                        _budgetCategoryItemsList[index]['categoryId'], index);
                  },
                  child: Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewCategoryDialog();
        },
        child: Icon(Icons.add),
        tooltip: 'Add new category',
      ),
    );
  }

  void _addNewCategoryDialog() {
    _resetCategoryItem();
    var _dialog = new Dialog(
      child: Container(
        height: 230,
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
                                  'New category (${dayMonthFormatted(date: DateTime.now())})',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    _categoryNameController.text.isEmpty
                                        ? _categoryNameValidator = true
                                        : _categoryNameValidator = false;
                                    _categoryEstimateCostController.text.isEmpty
                                        ? _categoryEstimateCostValidator = true
                                        : _categoryEstimateCostValidator =
                                            false;
                                  });
                                  if (!_categoryNameValidator &&
                                      !_categoryEstimateCostValidator) {
                                    setCategoryItem(
                                        categoryName:
                                            _categoryNameController.text,
                                        estimateCost: double.parse(
                                            _categoryEstimateCostController
                                                .text));
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 8.0, right: 8.0),
                            child: TextField(
                              controller: _categoryNameController,
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: "Category",
                                hintText: 'Category name',
                                icon: Icon(Icons.category),
                                errorText: _categoryNameValidator
                                    ? 'Invalid category name'
                                    : null,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 8.0, right: 8.0),
                            child: TextField(
                              controller: _categoryEstimateCostController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Estimate cost",
                                hintText: 'One month cost',
                                icon: Icon(Icons.data_usage),
                                errorText: _categoryEstimateCostValidator
                                    ? 'Estimate cost can\'t be empty'
                                    : null,
                              ),
                            ),
                          ),
                        ],
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

  void _resetCategoryItem() {
    _categoryNameValidator = false;
    _categoryEstimateCostValidator = false;
    _categoryNameController.clear();
    _categoryEstimateCostController.clear();
  }

  void setCategoryItem(
      {required String categoryName, required double estimateCost}) async {
    debugPrint('name $categoryName, cost $estimateCost');
    List _categoryName = await _db.findCategoryName(categoryName);
    debugPrint('Result=> $_categoryName');
    if (_categoryName.isEmpty) {
      CategoryItem _categoryItem = new CategoryItem(
          categoryName, fullDateFormatted(date: DateTime.now()));
      debugPrint('Category item => ${_categoryItem.toMap()}');
      int _categoryId = await _db.saveCategoryItem(_categoryItem);
      debugPrint('Insert category Id => $_categoryId');
      if (_categoryId > 0) {
        BudgetCategoryItem _budgetCategoryItem = new BudgetCategoryItem(
            budgetItemId,
            _categoryId,
            fullDateFormatted(date: DateTime.now()),
            estimateCost);
        debugPrint('BudgetCategoryItems => ${_budgetCategoryItem.toMap()}');
        int _budgetCategoryId =
            await _db.saveBudgetCategoryItem(_budgetCategoryItem);
        debugPrint('Insert BudgetCategory Id => $_budgetCategoryId');
      }
    } else {
      int count = await _db.findBudgetCategoryName(
          _categoryName[0]['categoryId'], budgetItemId);
      if (count == 0) {
        BudgetCategoryItem _budgetCategoryItem = new BudgetCategoryItem(
            budgetItemId,
            _categoryName[0]['categoryId'],
            fullDateFormatted(date: DateTime.now()),
            estimateCost);
        debugPrint('BudgetCategoryItems => ${_budgetCategoryItem.toMap()}');
        int _budgetCategoryId =
            await _db.saveBudgetCategoryItem(_budgetCategoryItem);
        debugPrint('Insert BudgetCategory Id => $_budgetCategoryId');
      } else {
        debugPrint('Already have this name in this budget');
      }
    }
    _loadBudgetCategoryList();
  }

  _deleteCategoryItem(int id, int index) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final _appStateNotifier =
              Provider.of<AppStateNotifier>(context, listen: false);
          return AlertDialog(
            title: Text("Delete category"),
            content: Text("Are you sure to delete?"),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Ok'),
                onPressed: () async {
                  int count = await _db.findActiveCategory(id);
                  debugPrint('Count => $count');
                  if (count == 0) {
                    // delete category item
                    await _db.deleteCategoryItem(id);
                    setState(() {
                      _budgetCategoryItemsList.removeAt(index);
                    });
                    _appStateNotifier.getBudgetCategoryCount();
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('This category is already used!'),
                      ),
                    );
                  }
                },
              )
            ],
          );
        });
  }
}
