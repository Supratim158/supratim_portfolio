/// GitHub user profile model.
class GithubProfile {
  final String login;
  final String name;
  final String avatarUrl;
  final String bio;
  final int publicRepos;
  final int followers;
  final int following;
  final String htmlUrl;

  const GithubProfile({
    required this.login,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.publicRepos,
    required this.followers,
    required this.following,
    required this.htmlUrl,
  });

  factory GithubProfile.fromJson(Map<String, dynamic> json) {
    return GithubProfile(
      login: json['login'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar'] ?? json['avatar_url'] ?? json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
      publicRepos: json['publicRepos'] ?? json['public_repos'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      htmlUrl: json['githubUrl'] ?? json['html_url'] ?? json['htmlUrl'] ?? '',
    );
  }
}
