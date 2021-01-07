import 'package:flutter/material.dart';
import 'package:my_wallet/ui/ReportPages/ItemDetailPage.dart';
import 'package:my_wallet/util/DateTools.dart';

class NewExpenseListView extends StatefulWidget {
  final List items;
  final int startDate;
  final int endDate;
  NewExpenseListView({Key key, @required this.items, @required this.startDate, @required this.endDate}) : super(key: key);
  @override
  _NewExpenseListViewState createState() => _NewExpenseListViewState();
}

class _NewExpenseListViewState extends State<NewExpenseListView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.items.length,
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {
                //debugPrint('Click ${widget.items[index]['categoryId']}');
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ItemDetailPage(
                    title: '${widget.items[index]['categoryName']}',
                    categoryId: widget.items[index]['categoryId'],
                    startDate: widget.startDate,
                    endDate: widget.endDate,
                  );
                }));
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.items[index]['categoryName']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  '${monthYearFormatted(date: DateTime.fromMillisecondsSinceEpoch(widget.items[index]['itemDate']))}',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ))),
                    Align(
                      alignment: Alignment.topRight,
                      child: CustomPaint(
                        painter: Chevron(),
                        child: Container(
                          width: 30.0,
                          height: 20.0,
                          margin: EdgeInsets.only(right: 5, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("${widget.items[index]['itemCount']}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${widget.items[index]['actualCost']} Ks',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Chevron extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Gradient gradient = new LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.blueGrey[500], Colors.blueGrey[300]],
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
