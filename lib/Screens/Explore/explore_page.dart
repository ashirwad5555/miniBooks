import 'package:flutter/material.dart';

import '../temp/temp_explorebody.dart';
import 'explore_body.dart';

class ExplorePage extends StatefulWidget {
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Category'),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),

      body: ExploreBody(),

    );
  }
}
