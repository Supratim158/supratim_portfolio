/// GitHub commit model.
/// Parses the real API format where commits are grouped by repository:
/// [{repository: "repo_name", commits: [{sha, commit: {author, message}, ...}]}]
class CommitData {
  final String sha;
  final String message;
  final String repoName;
  final DateTime date;
  final String authorName;
  final String htmlUrl;

  const CommitData({
    required this.sha,
    required this.message,
    required this.repoName,
    required this.date,
    required this.authorName,
    this.htmlUrl = '',
  });

  /// Parse a single commit object from the GitHub API.
  /// [repoName] is injected from the parent repository group.
  factory CommitData.fromJson(Map<String, dynamic> json, {String repoName = ''}) {
    // The commit message lives inside commit.message
    final commitObj = json['commit'] as Map<String, dynamic>?;
    final message = commitObj?['message'] ?? json['message'] ?? '';

    // Date can be at commit.author.date or commit.committer.date
    final authorObj = commitObj?['author'] as Map<String, dynamic>?;
    final dateStr = authorObj?['date'] ?? json['date'] ?? json['created_at'] ?? '';
    final date = DateTime.tryParse(dateStr.toString()) ?? DateTime.now();

    // Author name
    final authorName = authorObj?['name'] ?? json['authorName'] ?? json['author'] ?? '';

    return CommitData(
      sha: json['sha'] ?? '',
      message: message,
      repoName: repoName.isNotEmpty ? repoName : (json['repoName'] ?? json['repo'] ?? ''),
      date: date,
      authorName: authorName,
      htmlUrl: json['html_url'] ?? '',
    );
  }

  /// Parse the full grouped API response:
  /// [{repository: "name", commits: [...]}, ...]
  /// Returns a flat list of CommitData sorted by date descending.
  static List<CommitData> parseGroupedResponse(List<dynamic> jsonList) {
    final allCommits = <CommitData>[];

    for (final group in jsonList) {
      if (group is Map<String, dynamic>) {
        final repoName = group['repository'] as String? ?? '';
        final commits = group['commits'] as List<dynamic>? ?? [];

        for (final commitJson in commits) {
          if (commitJson is Map<String, dynamic>) {
            allCommits.add(CommitData.fromJson(commitJson, repoName: repoName));
          }
        }
      }
    }

    // Sort by date descending (most recent first)
    allCommits.sort((a, b) => b.date.compareTo(a.date));
    return allCommits;
  }
}
