class Repository {
  final int id;
  final String name;
  final bool isPrivate;
  final String ownerName;
  final String ownerAvatar;
  final String repoUrl;

  Repository({
    required this.id,
    required this.name,
    required this.isPrivate,
    required this.ownerName,
    required this.ownerAvatar,
    required  this.repoUrl
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'],
      name: json['name'],
      isPrivate: json['private'],
      ownerName: json['owner']['login'],
      ownerAvatar: json['owner']['avatar_url'],
      repoUrl: json['html_url'],
    );
  }
  /* i have choosen to display the name of the owner , the avatar ,  
  the name of the repository  and the category whether private or public and the link to the repo
  coz thats the basic info one would need to know the repo and find it
  */
}