import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/all_books.dart';

final booksProvider = Provider<List<Map<String, dynamic>>>((ref) => books);