import 'package:flutter/material.dart';
import 'category_explore.dart';
import 'category_tab.dart';
import 'genre_card_widget.dart';
import 'genre_model.dart';

class ExploreBody extends StatefulWidget {


  @override
  _ExploreBodyState createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<ExploreBody> {
  // List of categories
  final List<String> categories = ['Novels', 'Comics', 'Manga', 'Podcasts', 'More'];

  // Current selected category index
  int selectedCategoryIndex = 0;

  // Dummy book data for different categories
  final Map<String, List<Genre>> categoryBooks = {
    'Novels': [
      Genre(name: 'Adventure', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
      Genre(name: 'Crime', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
      Genre(name: 'Fanfiction', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
      Genre(name: 'Geopolitics', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
    ],
    'Comics': [
      Genre(name: 'Superhero', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
      Genre(name: 'Graphic Novel', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
    ],
    'Manga': [
      Genre(name: 'Shonen', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
      Genre(name: 'Shojo', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
    ],
    'Podcasts': [
      Genre(name: 'True Crime', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
      Genre(name: 'Technology', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
    ],
    'More': [
      Genre(name: 'Science Fiction', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
      Genre(name: 'Poetry', imagePath: "https://i.pinimg.com/564x/6f/9a/9f/6f9a9fcd6f6b8bc8c4de77ad7a42c766.jpg"),
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Get the books for the selected category
    List<Genre> displayedBooks = categoryBooks[categories[selectedCategoryIndex]] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: Icon(Icons.mic, color: Colors.orange),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),

                ),
              ),
            ),
            SizedBox(height: 16),

            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(categories.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                      });
                    },
                    child: CategoryTab(
                      title: categories[index],
                      isActive: selectedCategoryIndex == index,
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16),

            // Grid View
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,

                ),
                itemCount: displayedBooks.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      child: GenreCard(genre: displayedBooks[index]),
                    onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CategoryExplore(category: displayedBooks[index].name ,)));
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 100,)
          ],
        ),

      ),
    );
  }
}
