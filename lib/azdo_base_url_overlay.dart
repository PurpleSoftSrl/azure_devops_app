import 'dart:async';

import 'package:azure_devops/azdo_base_url_controller.dart';
import 'package:flutter/material.dart';

class AzdoBaseUrlOverlay extends StatelessWidget {
  const AzdoBaseUrlOverlay({
    super.key,
    required this.child,
    this.navigatorKey,
    this.scaffoldMessengerKey,
  });

  final Widget? child;

  /// Pass the same navigatorKey you use in MaterialApp.
  /// e.g. AppRouter.navigatorKey
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Optional: pass your scaffoldMessengerKey if you have one
  /// (your app has OverlayService.scaffoldMessengerKey).
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    if (child == null) return const SizedBox.shrink();

    return Stack(
      children: [
        child!,
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: _ChipButton(
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AzdoBaseUrlController.isSignedInNotifier,
      builder: (context, isSignedIn, _) {
        if (isSignedIn) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<String?>(
          valueListenable: AzdoBaseUrlController.baseUrlNotifier,
          builder: (context, value, _) {
            final label = value == null ? 'dev.azure.com' : _shorten(value);
            return Material(
              color: Colors.transparent,
              child: ActionChip(
                avatar: const Icon(Icons.cloud, size: 18),
                label: Text(label),
                onPressed: () => _scheduleDialog(value, context),
              ),
            );
          },
        );
      },
    );
  }

  void _scheduleDialog(String? current, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        unawaited(_showDialog(current, fallbackContext: context));
      }
    });
  }

  String _shorten(String url) {
    try {
      final u = Uri.parse(url);
      if (u.host.isNotEmpty) return u.host;
    } catch (_) {}
    return url.replaceFirst(RegExp('^https?://'), '').split('/').first.trim();
  }

  BuildContext? _dialogContext(BuildContext fallbackContext) {
    return navigatorKey?.currentContext ??
        navigatorKey?.currentState?.context ??
        fallbackContext;
  }

  void _showSnack(String msg) {
    final messenger = scaffoldMessengerKey?.currentState;
    if (messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _showDialog(
    String? current, {
    required BuildContext fallbackContext,
  }) async {
    final ctx = _dialogContext(fallbackContext);
    if (ctx == null) return;

    final serverCtrl = TextEditingController(text: _serverBase(current));
    final collectionCtrl = TextEditingController(
      text: AzdoBaseUrlController.collection,
    );

    final result = await showDialog<_DialogResult>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: const Text('Azure DevOps Server URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leave empty for cloud (dev.azure.com).\n'
              'For self-hosted, enter your server base URL (optional path prefix).',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: serverCtrl,
              decoration: const InputDecoration(
                hintText: 'https://tfs.contoso.local',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: collectionCtrl,
              decoration: const InputDecoration(
                labelText: 'Default collection',
                hintText: 'DefaultCollection',
                border: OutlineInputBorder(),
              ),
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(_DialogResult.clear),
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(_DialogResult.cancel),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dctx).pop(
              _DialogResult.save(serverCtrl.text, collectionCtrl.text),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    switch (result.kind) {
      case _DialogKind.cancel:
        return;

      case _DialogKind.clear:
        AzdoBaseUrlController.clear();
        _showSnack('Using cloud endpoints (dev.azure.com)');
        return;

      case _DialogKind.save:
        final v = result.serverUrl.trim();
        if (v.isNotEmpty) {
          final parsed = Uri.tryParse(v);
          if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
            _showSnack('Enter a complete server URL, for example https://devops.example.com');
            return;
          }
        }
        AzdoBaseUrlController.setServerConnection(
          serverUrl: v,
          collection: result.collection,
        );
        _showSnack(v.isEmpty ? 'Using cloud endpoints' : 'Base URL set');
        return;
    }
  }

  String _serverBase(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final parsed = Uri.tryParse(value.trim());
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      return value;
    }
    return parsed
        .replace(path: '', query: null, fragment: null)
        .toString()
        .replaceFirst(RegExp(r'/$'), '');
  }
}

enum _DialogKind { cancel, clear, save }

class _DialogResult {
  const _DialogResult._(this.kind, [this.serverUrl = '', this.collection = '']);

  final _DialogKind kind;
  final String serverUrl;
  final String collection;

  static const cancel = _DialogResult._(_DialogKind.cancel);
  static const clear = _DialogResult._(_DialogKind.clear);
  static _DialogResult save(String serverUrl, String collection) =>
      _DialogResult._(_DialogKind.save, serverUrl, collection);
}
