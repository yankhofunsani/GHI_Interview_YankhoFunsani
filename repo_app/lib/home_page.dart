import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api.dart';
import 'models/repositorylist.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Repository>> futureRepos;

  @override
  void initState() {
    super.initState();
    futureRepos = ApiService.fetchRepositories();
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
      body: FutureBuilder<List<Repository>>(
        future: futureRepos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final repos = snapshot.data!;

          return ListView.builder(
            itemCount: repos.length,
            itemBuilder: (context, index) {
              final repo = repos[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(repo.ownerAvatar),
                  ),

                  title: Text(repo.name),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${repo.ownerName} • ${repo.isPrivate ? "Private" : "Public"}",
                      ),

                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _openRepo(repo.repoUrl),
                        child: Text(
                          repo.repoUrl,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  trailing: const Icon(Icons.open_in_new),

                  // Also clickable from entire tile
                  onTap: () => _openRepo(repo.repoUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}