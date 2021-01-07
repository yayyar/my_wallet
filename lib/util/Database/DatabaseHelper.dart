import 'package:my_wallet/model/BudgetCategoryItem.dart';
import 'package:my_wallet/model/BudgetItem.dart';
import 'package:my_wallet/model/CategoryItem.dart';
import 'package:my_wallet/model/ExpenseItem.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper.internal();
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  /*
  Use the factory keyword when implementing a constructor
  that doesn't always create a new instance of its class.
  a factory constructor might return an instance of a subtype.
   */
  factory DatabaseHelper() => _instance;

  //database name
  final String _databaseName = 'myWalletWloHc.db';

  // category table and column name
  final String _categoryTable = "categoryTable";
  final String _categoryId = "categoryId";
  final String _categoryName = "categoryName";
  final String _categoryDate = "categoryDate";

  // budget table and column name
  final String _budgetTable = "budgetTable";
  final String _budgetId = "budgetId";
  final String _budgetName = "budgetName";
  final String _budgetDate = "budgetDate";
  final String _budgetStatus = "budgetStatus";
  final String _lastUpdatedDate = "lastUpdatedDate";

  // item table and column name
  final String _itemTable = "itemTable";
  final String _itemId = "itemId";
  final String _itemNameDescription = "itemNameDescription";
  final String _actualCost = "actualCost";
  final String _itemDate = "itemDate";
  // categoryId from categoryTable

  //budgetCategory table and column name
  final String _budgetCategoryTable = "budgetCategory";
  final String _budgetCategoryId = "budgetCategoryId";
  final String _budgetCategoryDate = "budgetCategoryDate";
  final String _estimateCost = "estimateCost";
  // budgetId from budgetTable
  // categoryId from categoryTable

  final String _monthYear = "monthYear";

  static Database _db;

  //initiate database
  initDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);
    var _onCreateDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _onCreateDb;
  }

  //create table
  void _onCreate(Database db, int version) async {
    String categoryTable =
        "CREATE TABLE $_categoryTable($_categoryId INTEGER PRIMARY KEY AUTOINCREMENT, $_categoryName TEXT, $_categoryDate TEXT, $_monthYear TEXT)";
    await db.execute(categoryTable);

    String budgetTable =
        "CREATE TABLE $_budgetTable($_budgetId INTEGER PRIMARY KEY AUTOINCREMENT, $_budgetName TEXT, $_budgetDate TEXT, $_budgetStatus INTEGER, $_monthYear TEXT, $_lastUpdatedDate TEXT)";
    await db.execute(budgetTable);

    String budgetCategoryTable =
        "CREATE TABLE $_budgetCategoryTable($_budgetCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,$_budgetCategoryDate TEXT, $_budgetId INTEGER, $_categoryId INTEGER, $_estimateCost REAL, $_monthYear TEXT)";
    await db.execute(budgetCategoryTable);

    String itemTable =
        "CREATE TABLE $_itemTable($_itemId INTEGER PRIMARY KEY AUTOINCREMENT, $_itemNameDescription TEXT, $_actualCost REAL, $_itemDate INTEGER, $_categoryId INTEGER, $_monthYear TEXT)";
    await db.execute(itemTable);
  }

  //get created database
  Future<Database> get getDb async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  //CRUD Create|Retrieve|Update|Delete

  // insert budget
  Future<int> saveBudgetItem(BudgetItem budgetItem) async {
    var dbClient = await getDb;
    int res = await dbClient.insert(_budgetTable, budgetItem.toMap());
    return res;
  }

  // select budget item
  Future<List> getAllBudgetItems() async {
    var dbClient = await getDb;
    String sql = "SELECT * FROM $_budgetTable ORDER BY $_budgetId ASC";
    var res = await dbClient.rawQuery(sql);
    return res.toList();
  }

//  Future<BudgetItem> getBudgetItem(int id) async {
//    var dbClient = await getDb;
//    String sql = "SELECT * FROM $_budgetTable WHERE $_budgetId = $id";
//    var result = await dbClient.rawQuery(sql);
//    if (result != null) {
//      return BudgetItem.fromMap(result.first);
//    } else {
//      return null;
//    }
//  }

  //Delete
  // use whereArgs for more secure and to prevent sql injection
  Future<int> deleteBudgetItem(int id) async {
    var dbClient = await getDb;
    var result = dbClient
        .delete(_budgetTable, where: "$_budgetId = ? ", whereArgs: [id]);
    return result;
  }

  //Updated
  Future<int> updateBudgetItem(String budgetName, int id, int status) async {
    var dbClient = await getDb;
    String statusSql =
        "UPDATE $_budgetTable SET $_budgetName = '$budgetName', $_budgetStatus = $status  WHERE $_budgetId = $id";
    var result = await dbClient.rawQuery(statusSql);
    if(result != null){
      return 1;
    }else{
      return 0;
    }
  }

  Future<int> updateBudgetExpenseDate(String budgetUpdatedDate) async {
    var dbClient = await getDb;
    String statusSql =
        "UPDATE $_budgetTable SET $_lastUpdatedDate = '$budgetUpdatedDate'  WHERE $_budgetStatus = 1";
    var result = await dbClient.rawQuery(statusSql);
    if(result != null){
      return 1;
    }else{
      return 0;
    }
  }

  Future<int> updateBudgetStatus() async {
    int _activeStatus = 1, _deactivateStatus = 0;
    var dbClient = await getDb;
    String statusSql =
        "UPDATE $_budgetTable SET $_budgetStatus = $_deactivateStatus WHERE $_budgetStatus = $_activeStatus";
    var result = await dbClient.rawQuery(statusSql);
    if (result != null) {
      return 1;
    } else {
      return 0;
    }
  }

  //insert category
  Future<int> saveCategoryItem(CategoryItem categoryItem) async {
    var dbClient = await getDb;
    int res = await dbClient.insert(_categoryTable, categoryItem.toMap());
    return res;
  }

  //select category
  Future<List> getAllCategoryItems() async {
    var dbClient = await getDb;
    String sql = "SELECT * FROM $_categoryTable ORDER BY $_categoryId ASC";
    var res = await dbClient.rawQuery(sql);
    return res.toList();
  }

  //Select var parameter
  Future<List> findCategoryName(String categoryName) async {
    var dbClient = await getDb;
    String sql =
        "SELECT $_categoryId FROM $_categoryTable WHERE $_categoryName = '$categoryName'";
    var result = await dbClient.rawQuery(sql);
    //print('Find category => $result');
    return result.toList();
  }

  //Select var parameter
  Future<int> findBudgetCategoryName(int categoryId, int budgetId) async {
    var dbClient = await getDb;
    String sql =
        "SELECT count(*) FROM $_budgetCategoryTable WHERE $_categoryId = $categoryId AND $_budgetId = $budgetId";
    var result = await dbClient.rawQuery(sql);
    int count = Sqflite.firstIntValue(result);
    //print('Find category id => $result');
    return count;
  }

  //insert category budget
  Future<int> saveBudgetCategoryItem(
      BudgetCategoryItem budgetCategoryItem) async {
    var dbClient = await getDb;
    int res =
        await dbClient.insert(_budgetCategoryTable, budgetCategoryItem.toMap());
    return res;
  }

  //select budget category
  Future<List> getAllBudgetCategoryItems(int activeBudgetId) async {
    var dbClient = await getDb;
    String sql =
        "SELECT * FROM $_categoryTable left join $_budgetCategoryTable using($_categoryId) WHERE $_budgetId = $activeBudgetId ORDER BY $_categoryId ASC";
    var res = await dbClient.rawQuery(sql);
    return res.toList();
  }

  Future<List> getBudgetCategoryCount() async {
    var dbClient = await getDb;
    String sql =
        "SELECT $_budgetId,count(*) as count FROM $_budgetCategoryTable GROUP BY $_budgetId";
    var result = await dbClient.rawQuery(sql);
    return result;
  }

  Future<List> getActiveBudgetCategory() async {
    var dbClient = await getDb;
    String sql =
        "SELECT ct.$_categoryId,ct.$_categoryName FROM $_categoryTable ct inner join $_budgetCategoryTable bct on ct.$_categoryId = bct.$_categoryId inner join $_budgetTable bt on bt.$_budgetId = bct.$_budgetId WHERE bt.$_budgetStatus = 1 ";
    var res = await dbClient.rawQuery(sql);
    return res.toList();
  }

  Future<List> getEstimateCost() async {
    var dbClient = await getDb;
    String sql =
        "SELECT SUM($_estimateCost) as estimateCost FROM $_budgetCategoryTable bct inner join $_budgetTable bt on bt.$_budgetId = bct.$_budgetId WHERE bt.$_budgetStatus = 1";
    var res = await dbClient.rawQuery(sql);
    //print('estimate cost => ${res.toList()}');
    return res.toList();
  }

  Future<List> getActualCost({int startDate, int endDate}) async {
    var dbClient = await getDb;
    String sql;
    if(startDate == endDate){
      sql = "SELECT SUM($_actualCost) as actualCost FROM $_itemTable itb inner join $_budgetCategoryTable bct on bct.$_categoryId = itb.$_categoryId inner join $_budgetTable bt on bt.$_budgetId = bct.$_budgetId WHERE bt.$_budgetStatus = 1 AND bt.$_monthYear = itb.$_monthYear AND itb.$_itemDate = $startDate";
    }else{
      sql = "SELECT SUM($_actualCost) as actualCost FROM $_itemTable itb inner join $_budgetCategoryTable bct on bct.$_categoryId = itb.$_categoryId inner join $_budgetTable bt on bt.$_budgetId = bct.$_budgetId WHERE bt.$_budgetStatus = 1 AND bt.$_monthYear = itb.$_monthYear AND itb.$_itemDate BETWEEN $startDate AND $endDate";
    }
    //print(sql);
    var res = await dbClient.rawQuery(sql);
    //print('actual cost => ${res.toList()}');
    return res.toList();
  }

  // insert item table
  Future<int> saveExpenseItem(ExpenseItem expenseItem) async {
    //print('new expense=> ${expenseItem.toMap()}');
    var dbClient = await getDb;
    int res = await dbClient.insert(_itemTable, expenseItem.toMap());
    return res;
  }

  //select all expense category
  Future<List> getAllExpenseItems({int startDate, int endDate}) async {
    var dbClient = await getDb;
    String sql;
    if(startDate == endDate){
      sql = "SELECT bt.$_budgetDate,bt.$_budgetId, ct.$_categoryId,ct.$_categoryName,itb.$_itemDate,SUM(itb.$_actualCost) as actualCost, COUNT(itb.$_categoryId) as itemCount, itb.$_monthYear FROM $_itemTable itb inner join $_categoryTable ct on itb.$_categoryId = ct.$_categoryId inner join $_budgetCategoryTable bct on ct.$_categoryId = bct.$_categoryId inner join $_budgetTable bt on bt.$_budgetId = bct.$_budgetId WHERE bt.$_budgetStatus = 1 AND bt.$_monthYear = itb.$_monthYear AND itb.$_itemDate = $startDate  GROUP BY itb.$_categoryId";
    }else{
      sql = "SELECT bt.$_budgetDate,bt.$_budgetId, ct.$_categoryId,ct.$_categoryName,itb.$_itemDate,SUM(itb.$_actualCost) as actualCost, COUNT(itb.$_categoryId) as itemCount, itb.$_monthYear FROM $_itemTable itb inner join $_categoryTable ct on itb.$_categoryId = ct.$_categoryId inner join $_budgetCategoryTable bct on ct.$_categoryId = bct.$_categoryId inner join $_budgetTable bt on bt.$_budgetId = bct.$_budgetId WHERE bt.$_budgetStatus = 1 AND bt.$_monthYear = itb.$_monthYear AND itb.$_itemDate BETWEEN $startDate AND $endDate  GROUP BY itb.$_categoryId";
    }
    //print(sql);
    var res = await dbClient.rawQuery(sql);
    //print('all expense => ${res.toList()}');
    return res.toList();
  }

  Future<List> getAllExpenseToDownload({int startDate, int endDate}) async {
    var dbClient = await getDb;
    String sql;
    if(startDate == endDate){
      sql = "SELECT itb.$_itemNameDescription, ct.$_categoryName, itb.$_itemDate, itb.$_actualCost from $_itemTable itb inner join $_categoryTable ct on itb.$_categoryId = ct.$_categoryId AND itb.$_itemDate = $startDate ORDER BY itb.$_itemId ASC";
    }else{
      sql = "SELECT itb.$_itemNameDescription, ct.$_categoryName, itb.$_itemDate, itb.$_actualCost from $_itemTable itb inner join $_categoryTable ct on itb.$_categoryId = ct.$_categoryId AND itb.$_itemDate BETWEEN $startDate AND $endDate ORDER BY itb.$_itemId ASC";
    }
    //print(sql);
    var res = await dbClient.rawQuery(sql);
    //print('all item data => ${res.toList()}');
    return res.toList();
  }

  //select category expense items
  Future<List> getExpenseItems({int categoryId,int startDate, int endDate}) async {
    var dbClient = await getDb;
    String sql;
    if(startDate == endDate){
      sql = "SELECT itb.$_itemId,bct.$_estimateCost,itb.$_itemNameDescription, itb.$_itemDate, itb.$_actualCost from $_itemTable itb inner join $_budgetCategoryTable bct on itb.$_categoryId = bct.$_categoryId inner join $_budgetTable bt on bct.$_budgetId = bt.$_budgetId WHERE bct.$_categoryId = $categoryId AND bt.$_budgetStatus = 1 AND bt.$_monthYear = itb.$_monthYear AND itb.$_itemDate = $startDate ORDER BY itb.$_itemId ASC";
    }else{
      sql = "SELECT itb.$_itemId,bct.$_estimateCost,itb.$_itemNameDescription, itb.$_itemDate, itb.$_actualCost from $_itemTable itb inner join $_budgetCategoryTable bct on itb.$_categoryId = bct.$_categoryId inner join $_budgetTable bt on bct.$_budgetId = bt.$_budgetId WHERE bct.$_categoryId = $categoryId AND bt.$_budgetStatus = 1 AND bt.$_monthYear = itb.$_monthYear AND itb.$_itemDate BETWEEN $startDate AND $endDate ORDER BY itb.$_itemId ASC";
    }
    //print(sql);
    var res = await dbClient.rawQuery(sql);
    return res.toList();
  }

  Future<int> deleteExpenseItem(int id) async {
    var dbClient = await getDb;
    var result = dbClient
        .delete(_itemTable, where: "$_itemId = ? ", whereArgs: [id]);
    return result;
  }

  Future<int> findActiveCategory(int id) async {
    var dbClient = await getDb;
    String sql =
        "SELECT COUNT(*) FROM $_itemTable itb inner join $_budgetCategoryTable bct on itb.$_categoryId = bct.$_categoryId inner join $_budgetTable bt on bt.$_budgetId = bct.$_budgetId WHERE bt.$_budgetStatus = 1 AND  bct.$_categoryId = $id";
    var result = await dbClient.rawQuery(sql);
    int count = Sqflite.firstIntValue(result);
    //print('active category count=> $count');
    return count;
  }

  Future<int> deleteCategoryItem(int id) async {
    var dbClient = await getDb;
    var result = dbClient
        .delete(_budgetCategoryTable, where: "$_budgetCategoryId = ? ", whereArgs: [id]);
    return result;
  }

  Future<int> findCurrentBudget(String monthYear) async {
    var dbClient = await getDb;
    String sql =
        "SELECT COUNT(*) FROM $_budgetTable WHERE $_monthYear = '$monthYear'";
    var result = await dbClient.rawQuery(sql);
    int count = Sqflite.firstIntValue(result);
    //print('current budget count=> $count');
    return count;
  }

  Future<int> findActiveBudget() async {
    var dbClient = await getDb;
    String sql =
        "SELECT COUNT(*) FROM $_budgetTable WHERE $_budgetStatus = 1";
    var result = await dbClient.rawQuery(sql);
    int count = Sqflite.firstIntValue(result);
    //print('current budget count=> $count');
    return count;
  }

  Future<List> currentBudgetDate() async {
    var dbClient = await getDb;
    String sql = "SELECT $_budgetDate,$_lastUpdatedDate from $_budgetTable WHERE $_budgetStatus = 1 ";
    var result = await dbClient.rawQuery(sql);
    return result.toList();
  }

  //close db
  Future close() async {
    var dbClient = await getDb;
    return dbClient.close();
  }
}
