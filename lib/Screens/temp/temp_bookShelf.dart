// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../Theme/mytheme.dart';
// import '../../providers/books_collection_provider.dart';
// import '../Collection/playlist_books_screen.dart';

// class BookShelfScreen extends ConsumerWidget {
//   const BookShelfScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final bookCollections = ref.watch(bookCollectionsProvider);
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'BookShelf',
//           style: theme.textTheme.titleLarge?.copyWith(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: AppTheme.getGradientDecoration(),
//         ),
//       ),
//       backgroundColor: colorScheme.background,
//       body: bookCollections.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.shelves,
//                     size: 80,
//                     color: AppTheme.gradientStart.withOpacity(0.6),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No playlists created yet.',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       color: colorScheme.onSurfaceVariant,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32),
//                     child: Text(
//                       'Create playlists to organize your favorite books',
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: colorScheme.onSurfaceVariant.withOpacity(0.7),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
                  
//                 ],
//               ),
//             )
//           : Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: GridView.builder(
//                 physics: const BouncingScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12.0,
//                   mainAxisSpacing: 12.0,
//                   childAspectRatio: 3 / 2,
//                 ),
//                 itemCount: bookCollections.length,
//                 itemBuilder: (context, index) {
//                   final collection = bookCollections[index];
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => PlaylistBooksScreen(
//                             collection: collection,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 4,
//                       shadowColor: Colors.black.withOpacity(0.1),
//                       child: Container(
//                         padding: const EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           gradient: LinearGradient(
//                             colors: [
//                               AppTheme.gradientStart.withOpacity(0.9),
//                               AppTheme.gradientEnd.withOpacity(0.9),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Stack(
//                           children: [
//                             // Decorative element
//                             Positioned(
//                               top: -20,
//                               right: -20,
//                               child: Container(
//                                 width: 60,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white.withOpacity(0.1),
//                                 ),
//                               ),
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   collection.name,
//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                     shadows: [
//                                       Shadow(
//                                         blurRadius: 3.0,
//                                         color: Colors.black.withOpacity(0.2),
//                                         offset: const Offset(1, 1),
//                                       ),
//                                     ],
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const Spacer(),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 8, vertical: 4),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white.withOpacity(0.2),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         '${collection.books.length} ${collection.books.length == 1 ? 'book' : 'books'}',
//                                         style:
//                                             theme.textTheme.bodySmall?.copyWith(
//                                           color: Colors.black87,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.all(6),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Colors.white.withOpacity(0.2),
//                                       ),
//                                       child: const Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: 12,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
      
//     );
//   }
// }
