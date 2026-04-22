import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api.dart';
import 'models/repositorylist.dart';
import 'database/dbfile.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Repository> repos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
  final db = DBHelper();

  try {
    final apiRepos = await ApiService.fetchRepositories();
    await db.insertRepos(apiRepos);
    repos = await db.getRepos();
  } catch (e) {
    //incase api faills
    repos = await db.getRepos();
  }

  setState(() {
    isLoading = false;
  });
}

  Future<void> _openRepo(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Repositories")),
      body:  isLoading
    ? Center(child: CircularProgressIndicator())
    : ListView.builder(
        itemCount: repos.length,
        itemBuilder: (context, index) {
          final repo = repos[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(repo.ownerAvatar),
            ),
            title: Text(repo.name),
            subtitle: Text(
              "${repo.ownerName} • ${repo.isPrivate ? "Private" : "Public"}",
            ),
            onTap: () => _openRepo(repo.repoUrl),
          );
        },
      ),
    );
}}
