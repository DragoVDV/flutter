import 'package:flutter/material.dart';
import 'package:lab_1/providers/connectivity_provider.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    return Column(
      children: [
        if (!isOnline)
          const Material(
            color: AppColors.missed,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Немає підключення до інтернету',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
