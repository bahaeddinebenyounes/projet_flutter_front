import 'dart:async';
import 'dart:convert'; // For JSON encoding
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

int level = 8;

class Home extends StatefulWidget {
  final int size;
  final Map<String, dynamic> user;

  const Home({Key? key, this.size = 8, required this.user}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<GlobalKey<FlipCardState>> cardStateKeys = [];
  List<bool> cardFlips = [];
  List<String> data = [];
  int previousIndex = -1;
  bool flip = false;
  int time = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Debugging user data
    print("User data passed to Home widget: ${widget.user}");

    // Check if essential user data is present
    if (widget.user['username'] == null) {
      print("Error: Username is missing.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }

    // Optional debug message for successful data initialization
    print("User data is valid. Proceeding to initialize cards.");
    print("User data passed to Home widget: ${widget.user}"); // Check if id is present

    initializeCards();
  }


  void initializeCards() {
    for (var i = 0; i < widget.size; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
      cardFlips.add(true);
    }

    for (var i = 0; i < widget.size ~/ 2; i++) {
      data.add(i.toString());
    }
    for (var i = 0; i < widget.size ~/ 2; i++) {
      data.add(i.toString());
    }

    startTimer();
    data.shuffle();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        time += 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safely access user data with fallback values
    String username = widget.user['username'] ?? 'Guest';
    String userId = widget.user['id']?.toString() ?? 'unknown_id';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Level ${level ~/ 8}", // Divide by 8 for level number
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "$time",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Theme(
                data: ThemeData.dark(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) => FlipCard(
                      key: cardStateKeys[index],
                      onFlip: () {
                        if (!flip) {
                          flip = true;
                          previousIndex = index;
                        } else {
                          flip = false;
                          if (previousIndex != index) {
                            if (data[previousIndex] != data[index]) {
                              cardStateKeys[previousIndex]
                                  ?.currentState
                                  ?.toggleCard();
                              previousIndex = index;
                            } else {
                              cardFlips[previousIndex] = false;
                              cardFlips[index] = false;

                              if (cardFlips.every((t) => !t)) {
                                print("Won");
                                showResult();
                              }
                            }
                          }
                        }
                      },
                      direction: FlipDirection.HORIZONTAL,
                      flipOnTouch: cardFlips[index],
                      front: Container(
                        margin: const EdgeInsets.all(4.0),
                        color: Colors.deepOrange.withOpacity(0.3),
                      ),
                      back: Container(
                        margin: const EdgeInsets.all(4.0),
                        color: Colors.deepOrange,
                        child: Center(
                          child: Text(
                            data[index],
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                    ),
                    itemCount: data.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showResult() async {
    try {
      await ApiService.submitLevelTime(
        widget.user['id']?.toString() ?? '0', // Fallback to '0'
        level ~/ 8,
        time,
      ).catchError((error) {
        print("API Error: $error");
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Won!!!"),
          content: Text(
            "Time $time",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                int nextLevelSize = level + 8;
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => Home(
                      size: nextLevelSize,
                      user: widget.user,
                    ),
                  ),
                );
                level = nextLevelSize;
              },
              child: const Text("NEXT"),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
