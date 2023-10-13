import 'package:mypod_client/mypod_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:mypod_client/src/protocol/article_class.dart' as ac;

//?for Android
var client = Client('http://10.0.2.2:8080/')
// ..connectivityMonitor = FlutterConnectivityMonitor();
// var client = Client('http://localhost:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Serverpod Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // These fields hold the last result or error message that we've received from
  // the server or null if no result exists yet.
  String? _resultMessage;
  String? _errorMessage;
  List? list;

  @override
  void initState() {
    fetchArticel();
    super.initState();
  }

  final _titletextEditingController = TextEditingController();
  final _contenttextEditingController = TextEditingController();

  addArticel() async {
    var article = ac.Article(
      title: _titletextEditingController.text.toString(),
      content: _contenttextEditingController.text.toString(),
      publishedOn: DateTime.now(),
      isPrime: true,
    );

    try {
      var result = await client.article.addArticle(article);
      fetchArticel();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  fetchArticel() async {
    try {
      var result = await client.article.getArticals();
      if (result.isNotEmpty) {
        list = result;
        setState(() {});
        // print(result);
      } else {
        list = [];
      }
    } catch (e) {
      print(e);
    }
  }

  // flutter dialog box with two inputs
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Article'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _titletextEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _contenttextEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Content',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                try {
                  addArticel();
                } catch (e) {
                  print(e);
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: _showMyDialog,
          tooltip: 'Send to Server',
          child: const Icon(Icons.add),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 720,
              child: Center(
                child: ListView.builder(
                  itemCount: list?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(8),
                      color: Color.fromARGB(255, 232, 232, 232),
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                list?[index].title ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                list?[index].content ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  _titletextEditingController.text =
                                      list?[index].title ?? '';
                                  _contenttextEditingController.text =
                                      list?[index].content ?? '';
                                  await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Edit Article'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 16.0),
                                                child: TextField(
                                                  controller:
                                                      _titletextEditingController,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Title',
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 16.0),
                                                child: TextField(
                                                  controller:
                                                      _contenttextEditingController,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Content',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Approve'),
                                            onPressed: () async {
                                              try {
                                                var article = ac.Article(
                                                  id: list?[index].id,
                                                  title:
                                                      _titletextEditingController
                                                          .text
                                                          .toString(),
                                                  content:
                                                      _contenttextEditingController
                                                          .text
                                                          .toString(),
                                                  publishedOn: DateTime.now(),
                                                  isPrime: true,
                                                );
                                                await client.article
                                                    .updateArticle(article);
                                                fetchArticel();
                                                setState(() {});
                                              } catch (e) {
                                                print(e);
                                              }

                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  try {
                                    await client.article
                                        .deleteArticle(list?[index].id ?? 0);
                                    fetchArticel();
                                    setState(() {});
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
