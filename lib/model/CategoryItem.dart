class CategoryItem {
  int? _categoryId;
  late String _categoryName;
  late String _categoryDate;

  CategoryItem(this._categoryName, this._categoryDate);

  CategoryItem.map(dynamic obj) {
    this._categoryId = obj['categoryId'];
    this._categoryName = obj['categoryName'];
    this._categoryDate = obj['categoryDate'];
  }

  int get categoryId => _categoryId ?? 0;
  String get categoryName => _categoryName;
  String get categoryDate => _categoryDate;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['categoryId'] = _categoryId;
    map['categoryName'] = _categoryName;
    map['categoryDate'] = _categoryDate;
    return map;
  }

  CategoryItem.fromMap(Map<String, dynamic> map) {
    this._categoryId = map['categoryId'];
    this._categoryName = map['categoryName'];
    this._categoryDate = map['categoryDate'];
  }
}
