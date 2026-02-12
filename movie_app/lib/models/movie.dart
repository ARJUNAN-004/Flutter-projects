class Movie {
  final String id;
  final String primaryTitle;
  final String? description;
  final String? primaryImage;
  final String? releaseDate;
  final double? averageRating;
  final List<String> genres;

  Movie({
    required this.id,
    required this.primaryTitle,
    this.description,
    this.primaryImage,
    this.releaseDate,
    this.averageRating,
    required this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      primaryTitle: json['primaryTitle'] ?? 'Unknown Title',
      description: json['description'],
      primaryImage: json['primaryImage'],
      releaseDate: json['releaseDate'],
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
    );
  }
}
