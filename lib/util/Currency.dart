class CurrencySymbol {
  String code;
  String symbol;
  CurrencySymbol(this.code, this.symbol);
}

List<CurrencySymbol> currency = _currency
    .map((e) => CurrencySymbol(e['code'], e['symbol']))
    .toList(growable: false);

var _currency = [
  {"code": "MMK", "symbol": "K"},
  {"code": "USD", "symbol": r"$"},
  {"code": "THB", "symbol": "฿"},
  {"code": "CNY", "symbol": "¥"},
  {"code": "JPY", "symbol": "¥"},
  {"code": "EURO", "symbol": "€"}
];
