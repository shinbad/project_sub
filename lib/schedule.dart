import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule extends StatefulWidget {
  // 위젯의 크기
  final double w;
  final double h;

  final String date; // 일정
  final projectId;  // 문서의 아이디

  const Schedule({super.key, required this.w, required this.h, required this.date, required this.projectId});

  @override
  State<StatefulWidget> createState() => _Schedule();
}
class _Schedule extends State<Schedule> {
  String _range='';

  // 일정 초기화
  @override
  void initState(){
    super.initState();
    _range=widget.date;
  }


  // 일정을 내가 원하는 형식으로 저장
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      _range = '${DateFormat('yyyy-MM-dd').format(args.value.startDate)} ~\n'
      // ignore: lines_longer_than_80_chars
          ' ${DateFormat('yyyy-MM-dd').format(args.value.endDate ?? args.value.startDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: InkWell(
          child: Container(
            width: widget.w,
            height: widget.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0x00e7e9f0).withOpacity(0.2),
            ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Container(
                   margin: const EdgeInsets.only(bottom: 10, left: 15),
                   child:const Text(
                     '일정',
                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                   ),
                 ),
                 Container(
                   margin: const EdgeInsets.only(left: 15),
                   child:Text(
                     _range,
                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                   ),
                 )
                ],
              ),
          ),
          onTap: () {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                      height: 400,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                              height: 320,
                              child: SfDateRangePicker(
                                onSelectionChanged: _onSelectionChanged,
                                selectionMode:
                                    DateRangePickerSelectionMode.range,
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(
                                              width: 1, color: Colors.blue)),
                                      child: const Text(
                                        '취소',
                                        style: TextStyle(color: Colors.blue),
                                      ))),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    final date = FirebaseFirestore.instance.collection('Project').doc(widget.projectId);
                                    date.update({"date": _range});
                                    _range;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('확인'),
                              ),
                            ],
                          )
                        ],
                      ));
                });
          },
        ),
      ),
    );
  }
}
