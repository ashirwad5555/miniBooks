import 'package:flutter/material.dart';
import '../BookSummaryPage/book_summary_page.dart';

class BookListModule extends StatelessWidget {
  final List<Map<String, dynamic>> books = [
    {
      "title": "Book 1",
      "author": "Author 1",
      "views": 1500,
      "rating": 4.5,
      "coverImage": "https://via.placeholder.com/120x180" // Sample image URL
    },
    {
      "title": "Book 2",
      "author": "Author 2",
      "views": 1200,
      "rating": 4.2,
      "coverImage": "https://via.placeholder.com/120x180"
    },
    {
      "title": "Book 3",
      "author": "Author 3",
      "views": 1000,
      "rating": 4.8,
      "coverImage": "https://via.placeholder.com/120x180"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => BookSummaryPage(
                //       bookTitle: book['title'],
                //       author: book['author'],
                //       views: book['views'],
                //       rating: book['rating'],
                //     ),
                //   ),
                // );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 150,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Book Cover Image
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(book['coverImage']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // Book Title
                        Text(
                          book['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Author Name
                        Text(
                          "by ${book['author']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        // Views and Rating Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.remove_red_eye,
                                color: Colors.grey, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "${book['views']} views",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.star,
                                color: Colors.yellow[700], size: 16),
                            SizedBox(width: 4),
                            Text(
                              "${book['rating']}",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

            );
          },
        ),
      ),
    );
  }
}
