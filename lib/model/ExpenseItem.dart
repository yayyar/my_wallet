class ExpenseItem {
  int _itemId;
  String _itemNameDescription;
  double _actualCost;
  int _itemDate;
  int _categoryId;
  String _monthYear;

  ExpenseItem(this._itemNameDescription, this._actualCost, this._itemDate,this._categoryId,this._monthYear);

  ExpenseItem.map(dynamic obj) {
    this._itemId = obj['itemId'];
    this._itemNameDescription = obj['itemNameDescription'];
    this._actualCost = obj['actualCost'];
    this._itemDate = obj['itemDate'];
    this._categoryId = obj['categoryId'];
    this._monthYear = obj['monthYear'];
  }

  int get itemId => _itemId;
  String get itemNameDescription => _itemNameDescription;
  double get actualCost => _actualCost;
  int get itemDate => _itemDate;
  int get categoryId => _categoryId;
  String get monthYear => _monthYear;

  Map<String, dynamic> toMap() {
    Map map = new Map<String, dynamic>();
    if (_itemId != null) {
      map['itemId'] = _itemId;
    }
    map['itemNameDescription'] = _itemNameDescription;
    map['actualCost'] = _actualCost;
    map['itemDate'] = _itemDate;
    map['categoryId'] = _categoryId;
    map['monthYear'] = _monthYear;
    return map;
  }

  ExpenseItem.fromMap(Map<String, dynamic> map) {
    this._itemId = map['itemId'];
    this._itemNameDescription = map['itemNameDescription'];
    this._actualCost = map['actualCost'];
    this._itemDate = map['itemDate'];
    this._categoryId = map['categoryId'];
    this._monthYear = map['monthYear'];
  }
}
