
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mini_books/Screens/temp/test_book_sammaryPage.dart';

// import '../../providers/explore_book_provider.dart';
// import '../BookSummaryPage/book_summary_page.dart';

// class GenreBooksPage extends ConsumerWidget {
//   final String genre;

//   const GenreBooksPage({Key? key, required this.genre}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Get books by the selected genre using the provider
//     final booksByGenre = ref.watch(booksByGenreProvider(genre));

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$genre Books'),
//       ),
//       body: booksByGenre.isEmpty
//           ? const Center(child: Text('No books found for this genre'))
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: booksByGenre.length,
//         itemBuilder: (context, index) {
//           final book = booksByGenre[index];
//           return GestureDetector(
//             child: ListTile(
//               leading: Image.network(
//                 book['coverUrl'] ?? 'assets/images/default_cover.jpg',
//                 fit: BoxFit.cover,
//                 width: 50,
//                 height: 80,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: Colors.grey[300],
//                     child: const Icon(Icons.broken_image),
//                   );
//                 },
//               ),
//               title: Text(book['title'] ?? 'Unknown Title'),
//               subtitle: Text(book['author'] ?? 'Unknown Author'),
//             ),
//             onTap: () {
//               // Navigate to the book summary page when a book is tapped
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => BookSummaryPage1(book: book),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
