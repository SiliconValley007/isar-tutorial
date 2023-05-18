import 'package:flutter/material.dart';
import 'package:routine/core/constants.dart';
import 'package:routine/pages/pages.dart';

import '../collections/routine.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case AppRoutes.home:
        return HomePage.route();
      case AppRoutes.createRoutinePage:
        return CreateRoutinePage.route(routine: routeSettings.arguments as Routine?);
      default:
        return HomePage.route();
    }
  }
}
