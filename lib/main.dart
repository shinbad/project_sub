import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'detailProject.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? dropdownValue;
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController? _projectTitleController;
  TextEditingController? _search;
  String searchTitle='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _projectTitleController=TextEditingController();
    _search=TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                DropdownButton<String>(
                  icon: Icon(Icons.list),
                  onChanged: (newValue) {
                    setState(() {
                      print(newValue);
                      dropdownValue = newValue;
                    });
                  },
                  value: dropdownValue,
                  items: <String>['진행중', '완료']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Container(
                  padding: EdgeInsets.only(right: 20),
                  width: 250,
                    child: TextField(
                      controller: _search,
                      keyboardType: TextInputType.text,
                      onChanged: (value){
                        setState(() {
                          searchTitle=value;
                        });
                      },
                    )
                )
              ],
            ),
            const SizedBox(height: 16.0),
            StreamBuilder(
                stream: searchTitle.isEmpty? db
                    .collection('Project')
                    .where('complete',isEqualTo: dropdownValue)
                    .snapshots(): db
                    .collection('Project')
                    .where('title',isEqualTo: searchTitle)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final items = snapshot.data?.docs;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: items?.length,
                      itemBuilder: (context, index) {
                        final item = items?[index];
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailProject(
                                    title: item['title'],
                                    projectId: items![index].id,
                                    date: item['date']),
                              ),
                            );
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
                                        .doc(items![index].id)
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
                  );
                }),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('프로젝트 추가'),
                    content: TextField(
                      controller: _projectTitleController,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: '제목'
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed:(){
                          final data = {
                            "date": " ",
                            "title": _projectTitleController!.value.text,
                            "complete": "진행중",
                            "progress":0.0
                          };
                          db
                              .collection('Project')
                              .add(data);
                          Navigator.of(context).pop();
                        },
                        child: Text('추가'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('프로젝트 생성'),
            ),
          ],
        ),
      ),
    );
  }
}
