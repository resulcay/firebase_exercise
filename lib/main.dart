import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initializeApp = Firebase.initializeApp();
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _initializeApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("An error occured"),
            );
          } else if (snapshot.hasData) {
            return const MyHomePage();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var movRef = firestore.collection('movies');
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
              stream: movRef.snapshots(),
              builder: (BuildContext context, AsyncSnapshot asyncsnapshot) {
                if (asyncsnapshot.hasError) {
                  return const Center(
                    child: Text("Error"),
                  );
                } else if (asyncsnapshot.hasData) {
                  List<DocumentSnapshot> listOfDocumentSnapshot =
                      asyncsnapshot.data.docs;
                  return Flexible(
                    child: ListView.builder(
                        itemCount: listOfDocumentSnapshot.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${listOfDocumentSnapshot[index].get('name')}'),
                              subtitle: Text(
                                  '${listOfDocumentSnapshot[index].get('rating')}'),
                              trailing: IconButton(
                                onPressed: () async {
                                  await listOfDocumentSnapshot[index]
                                      .reference
                                      .delete();
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                          );
                        }),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }),
          Form(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(hintText: "type movie name"),
                ),
                TextFormField(
                  controller: ratingController,
                  decoration: const InputDecoration(hintText: "type rating"),
                ),
                TextFormField(
                  controller: yearController,
                  decoration: const InputDecoration(hintText: "type year"),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> movieData = {
            'name': nameController.text,
            'rating': ratingController.text,
            'year': yearController.text,
          };

          await movRef.doc(nameController.text).set(movieData);
        },
        tooltip: 'Increment',
        child: const Text("Add"),
      ),
    );
  }
}
