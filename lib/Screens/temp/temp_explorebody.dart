// // explore_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mini_books/Screens/BookSummaryPage/book_summary_page.dart';
// import 'package:mini_books/Screens/temp/test_book_sammaryPage.dart';

// import '../../providers/explore_book_provider.dart';

// class ExploreBody1 extends ConsumerStatefulWidget {
//   const ExploreBody1({Key? key}) : super(key: key);

//   @override
//   _ExploreBody1State createState() => _ExploreBody1State();
// }

// class _ExploreBody1State extends ConsumerState<ExploreBody1> {
//   late TextEditingController _searchController;

//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final booksAsync = ref.watch(booksDataProvider);
//     final query = ref.watch(searchQueryProvider); // Watch the search query

//     return booksAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error: $error')),
//       data: (_) {
//         final allGenres = ref.watch(genresProvider);
//         final filteredBooks = ref.watch(filteredBooksProvider1);

//         return Scaffold(
//           body: Column(
//             children: [
//               SizedBox(height: 15,),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200], // Light background color
//                     borderRadius: BorderRadius.circular(24), // Rounded corners
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5), // Subtle shadow
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // Shadow position
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _searchController, // Set the controller
//                     decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                       hintText: 'Search books, authors, genres...',
//                       hintStyle: TextStyle(color: Colors.grey[600]), // Softer hint text color
//                       border: InputBorder.none, // Remove default border
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey), // Add a search icon
//                       suffixIcon: query.isNotEmpty
//                           ? IconButton(
//                         icon: const Icon(Icons.clear, color: Colors.grey),
//                         onPressed: () {
//                           _searchController.clear(); // Clear the text in the search bar
//                           ref.read(searchQueryProvider.notifier).state = ''; // Clear the search query in the provider
//                         },
//                       )
//                           : const Icon(Icons.mic, color: Colors.grey),
//                     ),
//                     onChanged: (value) {
//                       ref.read(searchQueryProvider.notifier).state = value;
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: query.isEmpty
//                 // Show genre grid when there's no search query
//                     ? allGenres.isEmpty
//                     ? const Center(child: Text('No genres available'))
//                     : GridView.builder(
//                   padding: const EdgeInsets.all(16),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 1,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                   ),
//                   itemCount: allGenres.length,
//                   itemBuilder: (context, index) {
//                     final genre = allGenres.elementAt(index);
//                     final booksWithGenre = ref.watch(booksByGenreProvider(genre));

//                     final coverUrl = booksWithGenre.isNotEmpty
//                         ? booksWithGenre.first['coverUrl'] ?? 'assets/images/default_cover.jpg'
//                         : 'assets/images/default_cover.jpg';

//                     return GenreCard(
//                       genre: genre,
//                       imageUrl: coverUrl,
//                       bookCount: booksWithGenre.length,
//                     );
//                   },
//                 )
//                 // Show filtered books list when search query is not empty
//                     : filteredBooks.isEmpty
//                     ? const Center(child: Text('No books found'))
//                     : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: filteredBooks.length,
//                   itemBuilder: (context, index) {
//                     final book = filteredBooks[index];
//                     return GestureDetector(
//                       child: ListTile(
//                       leading: Image.network(
//                         book['coverUrl'] ?? 'assets/images/default_cover.jpg',
//                         fit: BoxFit.cover,
//                         width: 50,
//                         height: 80,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             color: Colors.grey[300],
//                             child: const Icon(Icons.broken_image),
//                           );
//                         },
//                       ),
//                       title: Text(book['title'] ?? 'Unknown Title'),
//                       subtitle: Text(book['author'] ?? 'Unknown Author'),
//                     ),
//                       onTap: (){
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => BookSummaryPage1(book: book),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }




// class GenreCard extends StatelessWidget {
//   final String genre;
//   final String imageUrl;
//   final int bookCount;

//   const GenreCard({
//     Key? key,
//     required this.genre,
//     required this.imageUrl,
//     required this.bookCount,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.network(
//             imageUrl,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 color: Colors.grey[300],
//                 child: const Icon(Icons.broken_image),
//               );
//             },
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withOpacity(0.7),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 16,
//             left: 16,
//             right: 16,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   genre,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '$bookCount books',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }