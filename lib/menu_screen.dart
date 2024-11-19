import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minmaxgame_escaperoom/game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  String gameMode = 'Easy'; 

  Widget backgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/bg.png"), fit: BoxFit.cover),
      ),
    );
  }

  Widget logoImage() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 350,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget startButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                GameScreen(gameMode: gameMode,),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var fadeAnimation = animation.drive(tween);
              return FadeTransition(
                opacity: fadeAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 550),
        child: Center(
          child: AnimatedOpacity(
            opacity: 1.0, // Fully visible when this screen appears
            duration:
                const Duration(seconds: 1), // Duration for the fade-in effect
            child: Image.asset(
              "assets/images/button_play.png",
              width: 250,
            ),
          ),
        ),
      ),
    );
  }


  Widget dropdownMenu(BuildContext context) {
    return Positioned(
      top: 595,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/images/button.png"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: gameMode, // Reference stateful property
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF682903),
                size: 40,
              ),
              dropdownColor: Colors.white,
              style: GoogleFonts.roboto(
                fontSize: 30,
                color: Color(0xFF682903),
                fontWeight: FontWeight.bold,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    gameMode = newValue; // Update the state
                  });
                }
              },
              items: <String>['Easy', 'Hard']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
          backgroundImage(),
          logoImage(),
                    dropdownMenu(context),
          startButton(context),
        ],
      ),
    );
  }
}
