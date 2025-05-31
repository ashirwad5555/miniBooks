import 'package:flutter/material.dart';
import '../../Theme/mytheme.dart';

import 'explore_body.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Category',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        flexibleSpace: Container(
          decoration: AppTheme.getGradientDecoration(),
        ),
      ),
      body: const ExploreBody(),
    );
  }
}
