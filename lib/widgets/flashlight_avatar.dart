import 'package:flashlight_plugin/flashlight_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lab_1/widgets/profile_widgets.dart';

class FlashlightAvatar extends StatefulWidget {
  const FlashlightAvatar({required this.name, super.key});

  final String name;

  @override
  State<FlashlightAvatar> createState() => _FlashlightAvatarState();
}

class _FlashlightAvatarState extends State<FlashlightAvatar> {
  int _tapCount = 0;
  bool _torchOn = false;

  Future<void> _handleTap() async {
    _tapCount++;
    if (_tapCount < 5) return;
    _tapCount = 0;
    try {
      await FlashlightPlugin.toggleLight();
      setState(() => _torchOn = !_torchOn);
    } on PlatformException catch (e) {
      if (!mounted) return;
      _showUnsupportedDialog(
        e.message ?? 'Ліхтарик не підтримується на цій платформі.',
      );
    }
  }

  void _showUnsupportedDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ліхтарик'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ProfileAvatar(name: widget.name),
    );
  }
}
