import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameMode});

  final String gameMode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  List<int> _numbers = [];
  List<Gradient> _containerColors = [];
  int _timeLeft = 60;
  Timer? _timer;
  int _lives = 3;
  bool gameLose = false;
  double runTime = 1;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _showMessage = false;
  String _message = "";

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
        }
      });

    _setupGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _setupGame() {
    if (widget.gameMode == "Easy") {
      _timeLeft = 60;
      _lives = 3;
      _generateNumbers(6);
    } else if (widget.gameMode == "Hard") {
      _timeLeft = 45;
      _lives = 3;
      _generateNumbers(9);
    }
    _startTimer();
  }

  void _generateNumbers(int count) {
    _numbers = List.generate(count, (_) => generateRandomNumber());
    _generateRandomColors();
    setState(() {});
  }

  void _generateRandomColors() {
    _containerColors = List.generate(_numbers.length, (_) {
      return generateRandomGradient();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: runTime.toInt()), (timer) {
      if (_timeLeft > 0 && _lives > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _finalResultDisplay(
            "- Game Over -",
            "You didn't manage to escape the room. Don't worry, you'll get them next time!",
            "New Game",
            "Quit");
      }
    });
  }

  void _finalResultDisplay(
      String title, String message, String startGame, String quitGame) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              width: 380,
              height: 400,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/button.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              color: Color(0xFF682903),
                              fontSize: 39,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          message,
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              color: Color(0xFF682903),
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _restartGame();
                          },
                          child: Text(
                            startGame,
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  color: Color(0xFF682903),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    bottom:
                                        2, 
                                    child: Container(
                                      height: 5, 
                                      width:
                                          200, 
                                      color: const Color(
                                          0xFF682903),
                                    ),
                                  ),
                                  // Text with no underline
                                  Text(
                                    quitGame,
                                    style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                        color: Color(0xFF682903),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _timer?.cancel();
      _setupGame();
    });
  }

  int generateRandomNumber() {
    return _random.nextInt(301) - 100;
  }

  LinearGradient generateRandomGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(
          255,
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
        ),
        Color.fromARGB(
          255,
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
        ),
      ],
    );
  }

  void _onContainerTap(int number) async {
    int smallestNumber = _numbers.reduce(min);

    if (number == smallestNumber) {
      setState(() {
        _numbers.remove(number);
        _generateRandomColors();
      });
    } else {
      _showBottomMessage("Wrong choice, Please try again");
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
      _shakeController.forward();
      setState(() {
        _lives--;
      });
    }

    if (_numbers.isEmpty && _lives != 0 && _timeLeft != 0) {
      _timer?.cancel();
      _finalResultDisplay(
          "- Congratulations -",
          "You've escaped the room! You solved the puzzles and made it out in time",
          "New Game",
          "Quit");
    }

    if (_lives <= 0 || _timeLeft <= 0) {
      _timer?.cancel();
      _finalResultDisplay(
          "- Game Over -",
          "You didn't manage to escape the room. Don't worry, you'll get them next time!",
          "New Game",
          "Quit");
    }
  }

  void _showBottomMessage(String message) {
    setState(() {
      _message = message;
      _showMessage = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showMessage = false;
      });
    });
  }

  Widget buildRandomContainer(int number) {
    double containerWidth = MediaQuery.of(context).size.width * 0.25;
    int index = _numbers.indexOf(number);
    return GestureDetector(
      onTap: () => _onContainerTap(number),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        width: containerWidth,
        height: 100,
        decoration: BoxDecoration(
          gradient: index != -1 ? _containerColors[index] : null,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: AnimatedOpacity(
          opacity: _numbers.contains(number) ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          child: Center(
            child: Text(
              number.toString(),
              style: GoogleFonts.roboto(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(int startIndex) {
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            3,
            (index) => _numbers.length > startIndex + index
                ? buildRandomContainer(_numbers[startIndex + index])
                : const SizedBox(
                    width: 120,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60, right: 20),
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Lives : ",
                          style: GoogleFonts.roboto(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        for (int i = 0; i < _lives; i++)
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 29,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Time Left : $_timeLeft",
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main game content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 180),
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  const Spacer(),
                  buildRow(0),
                  const SizedBox(height: 20),
                  buildRow(3),
                  const SizedBox(height: 20),
                  buildRow(6),
                  const SizedBox(height: 20),
                  buildRow(9),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showMessage ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _message,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
