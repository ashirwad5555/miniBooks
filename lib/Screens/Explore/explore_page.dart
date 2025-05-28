import 'package:flutter/material.dart';

import 'explore_body.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Category'),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),

      body: const ExploreBody(),

    );
  }
}
