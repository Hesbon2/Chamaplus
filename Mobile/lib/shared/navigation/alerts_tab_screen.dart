import 'package:flutter/material.dart';

import '../../features/notifications/presentation/screens/notifications_dashboard_screen.dart';

/// Alerts shell tab — hosts the notifications dashboard.
class AlertsTabScreen extends StatelessWidget {
  const AlertsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsDashboardScreen();
  }
}
