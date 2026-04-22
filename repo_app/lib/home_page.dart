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
  List<Repository> filteredRepos = [];
  bool isLoading = true;

  String searchQuery = "";
  String filter = "All"; 

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
      repos = await db.getRepos();
    }

    applyFilters();

    setState(() {
      isLoading = false;
    });
  }

  void applyFilters() {
    setState(() {
      filteredRepos = repos.where((repo) {
        final matchesSearch =
            repo.name.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesFilter = filter == "All"
            ? true
            : filter == "Public"
                ? repo.isPrivate == false
                : repo.isPrivate == true;

        return matchesSearch && matchesFilter;
      }).toList();
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

      //filter and search functions 

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search repository...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      applyFilters();
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    filterButton("All"),
                    filterButton("Public"),
                    filterButton("Private"),
                  ],
                ),

                SizedBox(height: 10),
// details page
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRepos.length,
                    itemBuilder: (context, index) {
                      final repo = filteredRepos[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(repo.ownerAvatar),
                        ),
                        title: Text(repo.name),
                        subtitle: Text(
                          "${repo.ownerName} • ${repo.isPrivate ? "Private" : "Public"}",
                        ),
                        onTap: () => _openRepo(repo.repoUrl),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget filterButton(String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          filter = text;
          applyFilters();
        });
      },
      child: Text(text),
    );
  }
}