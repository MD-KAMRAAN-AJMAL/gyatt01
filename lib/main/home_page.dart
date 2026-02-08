import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gyatt_osc/main/movie_details_page.dart';
import 'package:gyatt_osc/main/search_page.dart';
import 'package:http/http.dart' as http;

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  final String apiKey =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNTRhOGQ4YTMyMjE1OGEyNTIyOTRkZWViZWYzYjhmNyIsIm5iZiI6MTc3MDQwMDUxNi42NjksInN1YiI6IjY5ODYyYjA0NjI1YmZmZDFmMTI4OWY2NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.JCwZsfjWUWSXQKiFPRA_WRp6szhUVtICjUEPWfkl93M";
  late Future<List<dynamic>> moviesFuture;

  @override
  void initState() {
    super.initState();
    moviesFuture = fetchMovies();
  }

  Future<List<dynamic>> fetchMovies() async {
    try {
      final response = await http
          .get(
            Uri.parse("https://api.themoviedb.org/3/movie/popular"),
            headers: {"Authorization": "Bearer $apiKey"},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["results"];
      }
    } catch (_) {}

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Popular Movies"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchScreen()),
              );
            },
            icon: Icon(Icons.search_rounded, size: 28),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            );
          }

          final movies = snapshot.data!;

          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(10),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.65,
            children: movies.map((movie) {
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
                                  width: double.infinity,
                                  fit: BoxFit.cover,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "⭐ ${(movie["vote_average"] as double).toStringAsFixed(1)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
