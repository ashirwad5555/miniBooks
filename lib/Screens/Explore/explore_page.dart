import 'package:flutter/material.dart';

import 'explore_body.dart';

class ExplorePage extends StatelessWidget {
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
