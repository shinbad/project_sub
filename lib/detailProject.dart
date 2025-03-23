import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'taskList.dart';
import 'stateBar.dart';
import 'schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailProject extends StatefulWidget {
  // 프로젝트의 제목과, 문서의 아이디, 날짜를 받음
  final String projectId;
  final String title;
  final String date;

  const DetailProject(
      {super.key,
      required this.title,
      required this.projectId,
      required this.date});

  @override
  State<DetailProject> createState() => _DetailProjectState();
}

class _DetailProjectState extends State<DetailProject> {
  // 날짜와 상태의 크기
  double w = 180.0;
  double h = 110.0;

  double progress = 0.0;    // 상태 진행도

  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController? _titleController;

  void initState(){
    super.initState();
    _titleController = TextEditingController();
  }

  // 바텀 시트 추가 페이지
  void addBottomSheet(BuildContext context) {
    _titleController?.text='';   //텍스트 초기화
    String taskDate = '일정';   // 일정 초기화

    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Padding(
              padding: EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom),
              child:SingleChildScrollView(
              child:SizedBox(
              height: 130,
              child: Center(
                child: SizedBox(
                  width: 380,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child:TextField(
                          controller: _titleController,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          decoration: const InputDecoration(
                              hintText: '태스크 제목',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5),),
                                borderSide: BorderSide(width: 1, color: Colors.blue),
                              ),
                              contentPadding: EdgeInsets.all(10)
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                              onPressed: () {
                                showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2300)
                                ).then((selectDate){
                                  setState(() {
                                    taskDate=DateFormat('yyyy-MM-dd').format(selectDate!);
                                  });
                                });
                              },
                              child: const Text('일정')),
                          TextButton(
                            // 텍스트 필드가 비어있으면 생성이 불가능
                              onPressed: _titleController!.text.isEmpty? null: (){
                                final data = {
                                  "date": taskDate,
                                  "title": _titleController!.value.text,
                                  "state": "대기",
                                  "importance": 0.0,
                                  "evaluation": 0.0
                                };
                                // 파이어페이스에 추가
                                db
                                    .collection('Project')
                                    .doc(widget.projectId)
                                    .collection('Task')
                                    .add(data);
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                '생성',
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ))));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: db
              .collection('Project')
              .doc(widget.projectId)
              .collection('Task')
              .orderBy('importance', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final items = snapshot.data?.docs;
            progress = state(items);
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 180,
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: w,
                            height: h,
                            child: Schedule(  // 일정 위젯
                              w: w,
                              h: h,
                              date: widget.date,
                              projectId: widget.projectId,
                            )),
                        SizedBox(
                          width: w,
                          height: h,
                          child: StateBar(w: w, h: h, progress: progress),    // 상태 위젯
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    color: Colors.white,
                    child: const Text(
                      'Task',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Flexible(
                      child: TaskList(    // 리스트 뷰 위젯
                    list: items,
                    projectId: widget.projectId,
                  )),
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addBottomSheet(context),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
    @override
    void dispose(){
      _titleController!.dispose();
      super.dispose();
    }
  }

  // 상태의 진행도를 완료의 갯수의 따라 계산
  double state(List<QueryDocumentSnapshot>? list) {
    int count = 0;
    String complete = '진행중';
    int? total = list?.length;
    if(list!.isEmpty){
      return 0.0;
    }
    for (var i = 0; i < total!; i++) {
      if (list[i]['state'] == '완료') {
        count++;
      }
    }
    double result = count / total;
    if(result==1){
      complete='완료';
    }
    var info = db
        .collection('Project')
        .doc(widget.projectId)
        .update({"progress": result,"complete":complete});
    return result;
  }
}
