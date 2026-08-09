import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/github_service.dart';
import '../models/github_profile.dart';
import '../models/repository.dart';
import '../models/contribution.dart';
import '../models/commit.dart';

/// Singleton instance of the GitHub service.
final githubServiceProvider = Provider<GithubService>((ref) => GithubService());

/// Fetches GitHub profile data.
final githubProfileProvider = FutureProvider<GithubProfile>((ref) async {
  final service = ref.read(githubServiceProvider);
  final json = await service.getProfile();
  return GithubProfile.fromJson(json);
});

/// Fetches repositories list.
final repositoriesProvider = FutureProvider<List<Repository>>((ref) async {
  final service = ref.read(githubServiceProvider);
  final jsonList = await service.getRepositories();
  return jsonList.map((j) => Repository.fromJson(j)).toList();
});

/// Fetches contribution data (total, streaks, daily).
final contributionsProvider = FutureProvider<ContributionData>((ref) async {
  final service = ref.read(githubServiceProvider);
  final json = await service.getContributions();
  return ContributionData.fromJson(json);
});

/// Fetches recent commits.
/// The API returns commits grouped by repository:
/// [{repository: "name", commits: [...]}, ...]
/// We flatten them into a single sorted list.
final commitsProvider = FutureProvider<List<CommitData>>((ref) async {
  final service = ref.read(githubServiceProvider);
  final jsonList = await service.getCommits();
  return CommitData.parseGroupedResponse(jsonList);
});

/// Fetches contribution graph data for the heatmap.
final contributionGraphProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(githubServiceProvider);
  return service.getContributionGraph();
});

/// Fetches total commit count across all repositories.
final allCommitsProvider = FutureProvider<int>((ref) async {
  final service = ref.read(githubServiceProvider);
  final json = await service.getAllCommits();
  return json['totalCommits'] as int? ?? 0;
});
