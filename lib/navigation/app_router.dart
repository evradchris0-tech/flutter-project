import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/about_screen.dart';
import '../screens/all_destinations_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/main_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/search_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/region_screen.dart';
import 'package:discover_cameroon/screens/bookings_screen.dart';
import '../screens/partner_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../models/destination.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/detail',
      pageBuilder: (context, state) {
        final destination = state.extra as Destination;
        return CustomTransitionPage(
          key: state.pageKey,
          child: DetailScreen(destination: destination),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/partner',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PartnerDetailScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
           return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AboutScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/quiz',
      pageBuilder: (context, state) {
        final destinations = state.extra as List<Destination>;
        return CustomTransitionPage(
          key: state.pageKey,
          child: QuizScreen(destinations: destinations),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/region',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, String>;
        return CustomTransitionPage(
          key: state.pageKey,
          child: RegionScreen(
            name: data['name']!,
            filterKey: data['filterKey']!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/all-destinations',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AllDestinationsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    ),
  ],
);
