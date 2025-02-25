import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfcare/utils/constants/colors.dart';
import 'package:selfcare/utils/constants/responisve.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> quotes = [
    'Taking care of yourself is productive.',
    "Almost everything will work again if you unplug it for a few minutes, including you.",
    "You can't pour from an empty cup. Take care of yourself first.",
    "Small steps every day lead to big changes over time.",
    "Your mind is a garden. Your thoughts are the seeds. You can grow flowers or weeds.",
    "Self-love is not selfish; you cannot truly love another until you know how to love yourself.",
  ];
  bool _checked = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _timeofday(),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: context.height * 0.24,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50,
                      Colors.purple.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.format_quote,
                        size: 20,
                        color: Colors.blue[400],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      quotes[Random().nextInt(quotes.length)],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              CarouselSlider(
                items: [
                  Container(
                    color: Colors.red,
                    height: context.height * 0.2,
                    width: context.width * 0.4,
                    child: Text('Mood Check-in'),
                  ),
                  Container(
                    color: Colors.blue,
                    height: context.height * 0.2,
                    width: context.width * 0.4,
                    child: Text('tasks'),
                  ),
                  Container(
                    color: Colors.yellow,
                    height: context.height * 0.2,
                    width: context.width * 0.4,
                    child: Text('add'),
                  )
                ],
                options: CarouselOptions(
                  height: context.height * 0.2,
                  viewportFraction: 0.5,
                  autoPlayInterval: Duration(seconds: 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _timeofday() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good Morning!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
        Text('DADDA',
            style:
                GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  } else if (hour < 18) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good Afternoon,',
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        Text('Heba',
            style:
                GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good Evening :)',
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        Text('Heba',
            style:
                GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
