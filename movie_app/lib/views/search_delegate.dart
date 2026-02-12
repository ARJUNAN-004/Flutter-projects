import 'package:flutter/material.dart';
import 'package:dioapidemo/models/movie.dart';
import 'package:dioapidemo/views/details_page.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  final List<Movie> movies;

  MovieSearchDelegate(this.movies);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultsList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultsList(context);
  }

  Widget _buildResultsList(BuildContext context) {
    final results = movies
        .where(
          (movie) =>
              movie.primaryTitle.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    if (results.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            "No movies found",
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.white24, height: 1),
        itemBuilder: (context, index) {
          final movie = results[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            leading: movie.primaryImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie.primaryImage!,
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 75,
                        color: Colors.grey[900],
                        child: const Icon(Icons.movie, size: 20),
                      ),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 75,
                    color: Colors.grey[900],
                    child: const Icon(Icons.movie, size: 20),
                  ),
            title: Text(
              movie.primaryTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              movie.releaseDate ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(movie: movie),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
