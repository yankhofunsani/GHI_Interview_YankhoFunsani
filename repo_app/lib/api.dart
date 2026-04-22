import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/repositorylist.dart';

class ApiService {
  static const String url = "https://api.github.com/repositories";

  static Future<List<Repository>> fetchRepositories() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      return data.map((repo) => Repository.fromJson(repo)).toList();
    } else {
      throw Exception("Failed to load repositories");
    }
  }
}