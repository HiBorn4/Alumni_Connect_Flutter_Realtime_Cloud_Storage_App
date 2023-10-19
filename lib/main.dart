import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // ignore: deprecated_member_use
  final databaseReference = FirebaseDatabase.instance.reference();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AlumniConnect'),
        ),
        body: MyForm(databaseReference),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  final DatabaseReference databaseReference;

  const MyForm(this.databaseReference, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  List<Map<dynamic, dynamic>> dataList = [];
  bool showData = false;

  @override
  void initState() {
    super.initState();

    // Set up a listener for Firebase changes.
    widget.databaseReference.onChildAdded.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? value = snapshot.value as Map<dynamic, dynamic>?;
      if (value != null) {
        dataList.add(value);
        setState(() {});
      }
    });
  }

  void _submitData() {
    String name = nameController.text;
    String number = numberController.text;

    if (name.isNotEmpty && number.isNotEmpty) {
      widget.databaseReference.push().set({'name': name, 'number': number});
      nameController.clear();
      numberController.clear();
    }
  }

  void _retrieveData() {
    widget.databaseReference.once().then((DatabaseEvent event) async {
      dataList.clear();
      Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        values.forEach((key, value) {
          dataList.add(value);
        });
        setState(() {});
      }
    });
    if (!showData) {
      setState(() {
        showData = true;
      });
    }
  }

  void _clearData() {
    widget.databaseReference.remove().then((_) {
      dataList.clear();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                "Join the Alumni Network - Let's Stay Connected",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: const Offset(0, 3),
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'What\'s your Name?',
                    prefixIcon: Icon(Icons.person), // Icon of a person
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone), // Icon of a phone
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Submit'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _retrieveData,
                    child: const Text('Retrieve'),
                  ),
                  ElevatedButton(
                    onPressed: _clearData,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: showData
              ? ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          'Name: ${dataList[index]['name']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: const Offset(0, 3),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(
                          'Number: ${dataList[index]['number']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            shadows: [
                              Shadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: const Offset(0, 3),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Container(),
        )
      ],
    );
  }
}
