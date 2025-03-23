import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class taskEditor extends StatefulWidget {
  final projectId;
  final taskId;
  final info;

  const taskEditor({Key? key, required this.projectId, required this.taskId, required this.info})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _taskEditor();
  }
}

class _taskEditor extends State<taskEditor> {
  String inputTitle = '';           //task 제목
  String stateValue = '대기';       //상태
  String _selectedDate='일정';      //일정
  double starValue1 = 0;            //우선순위
  double penValue = 0;              //평가점수

  var product = FirebaseFirestore.instance;
  TextEditingController? _textEditController;

  @override
  void initState(){                 //task 화면 실행시 DB에 있는 값을 불러옴
    // TODO: implement initState
    super.initState();
    inputTitle=widget.info['title'];
    stateValue = widget.info['state'];
    _selectedDate= widget.info['date'];
    starValue1 = widget.info['importance'];
    penValue = widget.info['evaluation'];
    _textEditController = TextEditingController(text: inputTitle);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('태스크 수정'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(right: 300, bottom: 10),
                      child: Text('이름'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(                           //제목 변경 위젯
                        controller: _textEditController,
                        onChanged: (text) {
                          setState(() {
                            inputTitle = text;
                          });
                        },
                      ),
                    )
                  ],
                ),
                const Divider(                                        //구분선
                  thickness: 1,
                  color: Colors.grey,
                ),
                Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(right: 300, bottom: 10),
                      child: Text('일정'),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(right: 270, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                showDatePicker(                           //버튼 선택시 날짜 선택하는 datepicker 위젯 화면에 출력
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime(2030),
                                ).then((selectedDate) {
                                  setState(() {
                                    _selectedDate = DateFormat('yyyy-MM-dd')
                                        .format(selectedDate!);
                                  });
                                });
                              },
                              child: Text(
                                _selectedDate != null                               //일정을 저장하는 변수에 데이터가 없을 경우 일정없음을 화면에 출력
                                    ? _selectedDate.toString().split(" ")[0]
                                    : "일정 없음",
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
                const Divider(                              //구분선
                  thickness: 1,
                  color: Colors.grey,
                ),
                Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(right: 300, bottom: 10),
                      child: Text('상태'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 300, bottom: 10),
                      child: TextButton(
                        child: Text(stateValue),
                        onPressed: () {
                          showModalBottomSheet<void>(                           //버튼을 누르면 화면아래에서 새로운 창이 화면에 출력되며 상태 변경하는 위젯을 포함
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 300,
                                color: Colors.white,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(stateValue),
                                      ListTile(
                                        leading: const Icon(
                                            Icons.check_circle_rounded),
                                        title: const Text('대기'),
                                        onTap: () {
                                          setState(() {
                                            stateValue = '대기';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                            Icons.check_circle_rounded),
                                        title: const Text('진행'),
                                        onTap: () {
                                          setState(() {
                                            stateValue = '진행';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                            Icons.check_circle_rounded),
                                        title: const Text('완료'),
                                        onTap: () {
                                          setState(() {
                                            stateValue = '완료';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(                                          //구분선
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 300, bottom: 10),
                      child: Text('우선 순위'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 300, bottom: 10),
                      child: Text('★ ${starValue1.round()}'),                           //슬라이더 위젯으로 변경한 데이터 값을 화면에 출력
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Slider(                                    //슬라이더 위젯을 좌우로 조절하여 우선순위의 값을 설정
                          value: starValue1,
                          min: 0,
                          max: 100,
                          label: '${starValue1.round()}',
                          onChanged: (newValue) {
                            setState(() {
                              starValue1 = newValue;
                            });
                          },
                        )),
                    const Divider(                                         //구분선
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 300, bottom: 10),
                      child: Text('평가 점수'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.edit),
                          Text('${penValue.round()}')                           //슬라이더 위젯으로 변경한 데이터 값을 화면에 출력
                        ],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Slider(                                    //우선순위와 동일하게 평가 점수를 저장하는 슬라이더 위젯
                          value: penValue,
                          min: 0,
                          max: 100,
                          label: '${penValue.round()}',
                          onChanged: (newValue) {
                            setState(() {
                              penValue = newValue;
                            });
                          },
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: ElevatedButton(
                        onPressed: () {
                          updateData(inputTitle, stateValue, _selectedDate,              //버튼 선택시 DB인 firebase에 값을 업데이트하는 위젯
                              starValue1, penValue);
                          Navigator.of(context).pop();
                        },
                        child: const Text('등록'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateData(String inputTitle, String stateValue, String selectedDate,        //firebase에 값을 업데이트하는 함수
      double starValue1, double penValue) {
    final firestoreInstance =
        product.collection('Project').doc(widget.projectId).collection('Task').doc(widget.taskId);
    firestoreInstance.update({
      "title": inputTitle,
      "state": stateValue,
      "date": selectedDate,
      "importance": starValue1,
      "evaluation": penValue,
    });
  }
}
