import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gyatt_osc/main/movie_details_page.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final String bearerToken =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNTRhOGQ4YTMyMjE1OGEyNTIyOTRkZWViZWYzYjhmNyIsIm5iZiI6MTc3MDQwMDUxNi42NjksInN1YiI6IjY5ODYyYjA0NjI1YmZmZDFmMTI4OWY2NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.JCwZsfjWUWSXQKiFPRA_WRp6szhUVtICjUEPWfkl93M";
  final TextEditingController controller = TextEditingController();

  List<dynamic> results = [];
  bool isLoading = false;
  Timer? _debounce;

  void searchMovies(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) return;

      setState(() => isLoading = true);

      try {
        final response = await http.get(
          Uri.parse(
            "https://api.themoviedb.org/3/search/movie?query=${Uri.encodeComponent(query.trim())}",
          ),
          headers: {"Authorization": "Bearer $bearerToken"},
        );

        if (response.statusCode == 200) {
          setState(() {
            results = jsonDecode(response.body)["results"];
          });
        }
      } catch (_) {}

      setState(() => isLoading = false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Movies")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Search movies...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: searchMovies, // 🔥 press enter
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(10),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.65,
              children: results.map((movie) {
                final posterPath = movie["poster_path"];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: posterPath != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    "https://image.tmdb.org/t/p/w500$posterPath",
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : const Center(child: Icon(Icons.movie)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            movie["title"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
