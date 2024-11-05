//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../providers/books_collection_provider.dart';
//
// class CollectionBooksScreen extends ConsumerWidget {
//   final String collectionName;
//
//   CollectionBooksScreen({required this.collectionName});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final books = ref.watch(bookCollectionsProvider
//         .select((collections) => collections.firstWhere((collection) => collection.name == collectionName).books));
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(collectionName),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => _showAddBookDialog(context, ref),
//           ),
//         ],
//       ),
//       body: books.isEmpty
//           ? Center(child: Text('No books in this collection'))
//           : ListView.builder(
//         itemCount: books.length,
//         itemBuilder: (context, index) {
//           final book = books[index];
//           return ListTile(
//             leading: Image.network(book['coverUrl'], width: 50, height: 80),
//             title: Text(book['title']),
//             subtitle: Text(book['author']),
//           );
//         },
//       ),
//     );
//   }
//
//   void _showAddBookDialog(BuildContext context, WidgetRef ref) {
//     Map<String, dynamic> newBook = {
//       "title": "",
//       "author": "",
//       "coverUrl": "",
//     };
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add New Book'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 decoration: InputDecoration(hintText: 'Title'),
//                 onChanged: (value) => newBook['title'] = value,
//               ),
//               TextField(
//                 decoration: InputDecoration(hintText: 'Author'),
//                 onChanged: (value) => newBook['author'] = value,
//               ),
//               TextField(
//                 decoration: InputDecoration(hintText: 'Cover URL'),
//                 onChanged: (value) => newBook['coverUrl'] = value,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: Text('Add'),
//               onPressed: () {
//                 if (newBook['title'].isNotEmpty && newBook['author'].isNotEmpty) {
//                   ref.read(bookCollectionsProvider.notifier).addBookToCollection(collectionName, newBook);
//                   Navigator.of(context).pop();
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
