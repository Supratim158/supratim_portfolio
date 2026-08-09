import 'package:go_router/go_router.dart';
import '../screens/loader/loader_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/stack/stack_screen.dart';
import '../screens/github/github_screen.dart';
import '../screens/projects/projects_screen.dart';
import '../screens/projects/project_detail_screen.dart';
import '../screens/contact/contact_screen.dart';

/// Application router configuration using GoRouter.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoaderScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/stack',
      builder: (context, state) => const StackScreen(),
    ),
    GoRoute(
      path: '/metrics',
      builder: (context, state) => const GithubScreen(),
    ),
    GoRoute(
      path: '/work',
      builder: (context, state) => const ProjectsScreen(),
    ),
    GoRoute(
      path: '/work/:id',
      builder: (context, state) => ProjectDetailScreen(
        projectId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),
  ],
);
