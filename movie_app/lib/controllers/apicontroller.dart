import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dioapidemo/models/movie.dart';

final dio = Dio();

Future<List<Movie>> getData() async {
  try {
    final response = await dio.get(
      'https://raw.githubusercontent.com/itzjoyboy/my-json-api/refs/heads/main/movies.json',
    );

    if (response.statusCode == 200) {
      List<dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data) as List<dynamic>;
      } else {
        data = response.data as List<dynamic>;
      }
      return data.map((json) => Movie.fromJson(json)).toList();
    } else {
      print("HTTP Error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Fetch Error: $e");
    return [];
  }
}
