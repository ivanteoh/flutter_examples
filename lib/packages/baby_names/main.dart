// https://firebase.flutter.dev/docs/migration/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

final List<Map<String, dynamic>> dummySnapshot = [
  {"name": "Filip", "votes": 15},
  {"name": "Abraham", "votes": 14},
  {"name": "Richard", "votes": 11},
  {"name": "Ike", "votes": 10},
  {"name": "Justin", "votes": 1},
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baby Name Votes')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // return _buildList(context, dummySnapshot);
    final babies = FirebaseFirestore.instance.collection('baby').snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: babies,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return _buildList(context, snapshot.data!.docs);
      },
    );
  }

  // when `dummySnapshot` is used, snapshot is List<Map<String, dynamic>>
  Widget _buildList(BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  updateVote(Record record) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(record.reference)
          as DocumentSnapshot<Map<String, dynamic>>;
      final fresh = Record.fromSnapshot(freshSnapshot);

      transaction
          .update(record.reference, <String, int>{'votes': fresh.votes + 1});
    }).then(
      (value) => debugPrint("DocumentSnapshot successfully updated!"),
      onError: (dynamic e) => debugPrint("Error updating document $e"),
    );
  }

  // when `dummySnapshot` is used, snapshot is Map<String, dynamic>
  Widget _buildListItem(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> data) {
    // final record = Record.fromMap(data);
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          trailing: Text(record.votes.toString()),
          // onTap: () => debugPrint(record),
          onTap: updateVote(record),
        ),
      ),
    );
  }
}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        name = map['name'],
        votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}
