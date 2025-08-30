import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scapture/Providers/ResetPasswordScreen.dart';


final GoRouter appRouter = GoRouter(
  routes: [
    
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => ResetPasswordScreen(),
    ),
  ],
);