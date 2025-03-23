import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'taskpage2.dart';

class TaskList extends StatelessWidget {
  // 파이어베이스의 데이터
  final List<QueryDocumentSnapshot>? list;

  // 문서의 아이디
  final projectId;

  TaskList({Key? key, this.list, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(15),
              child: Text(
                '전체 ${list!.length}',
                style: const TextStyle(color: Colors.grey),
              )),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 15, right: 15),
              itemCount: list?.length,
              itemBuilder: (context, position) {
                final item = list?[position];
                return InkWell(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      margin: EdgeInsets.all(5),
                      child: ListTile(
                        title: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            item!['title'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: Text(
                          '${item['state']}  •  ${item['date']}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    var taskId = list![position].id;
                    var info = list![position].data()as Map;

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => taskEditor(
                              projectId: projectId,
                              taskId: taskId,
                              info: info,
                            )));
                  },
                  onLongPress: () {
                    AlertDialog dialog = AlertDialog(
                      title: Text('삭제'),
                      content: Text(
                        '${item['title']}을 삭제하시겠습니까?',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            '취소',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('Project')
                                .doc(projectId)
                                .collection('Task')
                                .doc(list![position].id)
                                .delete();
                            Navigator.of(context).pop();
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => dialog);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
