import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
  }

class _State extends ConsumerState<JournalScreen> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.calendar_today)),
            IconButton(onPressed: (){}, icon: Icon(Icons.list)),
            
          ],
        ),
        )
      )
    );
  }
}