class BudgetCategoryItem {
  int? _budgetCategoryId;
  late int _budgetId;
  late int _categoryId;
  late double _estimateCost;
  late String _budgetCategoryDate;

  BudgetCategoryItem(this._budgetId, this._categoryId, this._budgetCategoryDate,
      this._estimateCost);

  BudgetCategoryItem.map(dynamic obj) {
    this._budgetId = obj['budgetId'];
    this._categoryId = obj['categoryId'];
    this._estimateCost = obj['estimateCost'];
    this._budgetCategoryDate = obj['budgetCategoryDate'];
  }

  int get budgetId => _budgetId;
  int get categoryId => _categoryId;
  double get estimateCost => _estimateCost;
  String get budgetCategoryDate => _budgetCategoryDate;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['budgetCategoryId'] = _budgetCategoryId;
    map['budgetId'] = _budgetId;
    map['categoryId'] = _categoryId;
    map['estimateCost'] = _estimateCost;
    map['budgetCategoryDate'] = _budgetCategoryDate;
    return map;
  }

  BudgetCategoryItem.fromMap(Map<String, dynamic> map) {
    this._budgetCategoryId = map['budgetCategoryId'];
    this._budgetId = map['budgetId'];
    this._categoryId = map['categoryId'];
    this._estimateCost = map['estimateCost'];
    this._budgetCategoryDate = map['budgetCategoryDate'];
  }
}
