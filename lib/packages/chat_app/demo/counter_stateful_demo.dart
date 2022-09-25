import 'package:flutter/material.dart';

class CounterStateful extends StatefulWidget {
  //Widget variables should be final
  final Color buttonColor;

  const CounterStateful({Key? key, required this.buttonColor})
      : super(key: key);

  @override
  State<CounterStateful> createState() => _CounterStatefulState();
}

class _CounterStatefulState extends State<CounterStateful> {
  int counter = 0;

  void increment() {
    setState(() {
      counter++;
    });
    debugPrint(counter.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Counter'),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: widget.buttonColor,
          child: const Icon(Icons.add),
          onPressed: () {
            increment();
          },
        ),
        body: Center(
          child: Text(
            '$counter',
            style: const TextStyle(fontSize: 30),
          ),
        ));
  }
}
