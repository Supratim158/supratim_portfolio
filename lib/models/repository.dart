/// GitHub repository model.
class Repository {
  final String name;
  final String description;
  final String language;
  final int stars;
  final int forks;
  final String htmlUrl;
  final String? homepage;
  final bool isFork;
  final DateTime? updatedAt;

  const Repository({
    required this.name,
    required this.description,
    required this.language,
    required this.stars,
    required this.forks,
    required this.htmlUrl,
    this.homepage,
    this.isFork = false,
    this.updatedAt,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? 'Unknown',
      stars: json['stars'] ?? json['stargazers_count'] ?? 0,
      forks: json['forks'] ?? json['forks_count'] ?? 0,
      htmlUrl: json['repoUrl'] ?? json['html_url'] ?? json['htmlUrl'] ?? '',
      homepage: json['homepage'],
      isFork: json['fork'] ?? json['isFork'] ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : (json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null),
    );
  }
}
