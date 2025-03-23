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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Main Page',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? dropdownValue = '전체';
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController? _projectTitleController;
  TextEditingController? _search;
  String searchTitle = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _projectTitleController = TextEditingController();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _projectTitleController?.dispose();
    _search?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: TextField(
                      controller: _search,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: searchTitle.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _search?.clear();
                                    setState(() {
                                      searchTitle = '';
                                    });
                                  },

                                  icon: const Icon(Icons.cancel))
                              : null,
                          hintText: '프로젝트 이름으로 검색',
                          isDense: true,
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Color(0xffe8eaef)),
                      onChanged: (value) {
                        setState(() {
                          searchTitle = value;
                        });
                      },
                    )),
                DropdownButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (newValue) {
                    setState(() {
                      print(newValue);
                      dropdownValue = newValue;
                    });
                  },
                  value: dropdownValue,
                  items: <String>['전체', '진행중', '완료']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            StreamBuilder(
                stream: searchTitle.isEmpty
                    ? (dropdownValue == '전체'
                        ? db.collection('Project').snapshots()
                        : db
                            .collection('Project')
                            .where('complete', isEqualTo: dropdownValue)
                            .snapshots())
                    : db
                        .collection('Project')
                        .where('title', isEqualTo: searchTitle)
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
                              margin: const EdgeInsets.all(5),
                              child: ListTile(
                                title: Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    item!['title'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
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
                              title: const Text('삭제'),
                              content: Text(
                                '${item['title']}을 삭제하시겠습니까?',
                                style: const TextStyle(fontSize: 20.0),
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
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('프로젝트 추가'),
              content: TextField(
                controller: _projectTitleController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: const InputDecoration(hintText: '제목'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    _projectTitleController?.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    final data = {
                      "date": " ",
                      "title": _projectTitleController!.value.text,
                      "complete": "진행중",
                      "progress": 0.0
                    };
                    db.collection('Project').add(data);
                    _projectTitleController?.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
