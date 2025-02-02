import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/all_books.dart';
import '../data/books_data.dart';

final booksProvider = Provider<List<Map<String, dynamic>>>((ref) => allBooks);