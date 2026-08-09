import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Service class for communicating with the Node.js GitHub backend.
class GithubService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  /// GET /api/github/profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl${AppConstants.githubProfileEndpoint}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load GitHub profile: ${response.statusCode}');
  }

  /// GET /api/github/repositories
  Future<List<dynamic>> getRepositories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl${AppConstants.githubReposEndpoint}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load repositories: ${response.statusCode}');
  }

  /// GET /api/github/contributions
  Future<Map<String, dynamic>> getContributions() async {
    final response = await http.get(
      Uri.parse('$_baseUrl${AppConstants.githubContributionsEndpoint}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load contributions: ${response.statusCode}');
  }

  /// GET /api/github/commits
  Future<List<dynamic>> getCommits() async {
    final response = await http.get(
      Uri.parse('$_baseUrl${AppConstants.githubCommitsEndpoint}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load commits: ${response.statusCode}');
  }

  /// GET /api/github/contribution-graph
  Future<Map<String, dynamic>> getContributionGraph() async {
    final response = await http.get(
      Uri.parse('$_baseUrl${AppConstants.githubContribGraphEndpoint}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load contribution graph: ${response.statusCode}');
  }

  /// GET /api/github/all-commits
  Future<Map<String, dynamic>> getAllCommits() async {
    final response = await http.get(
      Uri.parse('$_baseUrl${AppConstants.githubAllCommitsEndpoint}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load all commits: ${response.statusCode}');
  }
}
