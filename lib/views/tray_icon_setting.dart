import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

class TrayIconView extends ConsumerWidget {
  const TrayIconView({super.key});

  String _defaultIcon(int status) {
    if (system.isMacOS) {
      return 'assets/images/icon/macos/status_$status.png';
    }
    final directory = system.isWindows
        ? 'assets/images/tray/windows'
        : 'assets/images/tray/unix';
    final extension = system.isWindows ? 'ico' : 'png';
    return '$directory/status_$status.$extension';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(
      appSettingProvider.select(
        (state) => (
          stopped: state.trayIconStoppedPath,
          proxy: state.trayIconProxyPath,
          tun: state.trayIconTunPath,
          useTemplate: state.trayIconUseTemplate,
        ),
      ),
    );
    final notifier = ref.read(appSettingProvider.notifier);
    final localizations = context.appLocalizations;

    return BaseScaffold(
      title: localizations.trayIcon,
      body: ListView(
        children: [
          ListItem.toggle(
            title: Text(localizations.trayIconUseTemplate),
            subtitle: Text(localizations.trayIconUseTemplateDesc),
            value: setting.useTemplate,
            onChanged: (value) {
              notifier.update(
                (state) => state.copyWith(trayIconUseTemplate: value),
              );
            },
          ),
          const Divider(height: 0),
          _TrayIconRow(
            name: 'stopped',
            label: localizations.stop,
            iconPath: setting.stopped,
            defaultAsset: _defaultIcon(1),
            onPicked: (path) {
              notifier.update(
                (state) => state.copyWith(trayIconStoppedPath: path),
              );
            },
            onReset: () {
              notifier.update(
                (state) => state.copyWith(trayIconStoppedPath: null),
              );
            },
          ),
          const Divider(height: 0),
          _TrayIconRow(
            name: 'proxy',
            label: localizations.systemProxy,
            iconPath: setting.proxy,
            defaultAsset: _defaultIcon(2),
            onPicked: (path) {
              notifier.update(
                (state) => state.copyWith(trayIconProxyPath: path),
              );
            },
            onReset: () {
              notifier.update(
                (state) => state.copyWith(trayIconProxyPath: null),
              );
            },
          ),
          const Divider(height: 0),
          _TrayIconRow(
            name: 'tun',
            label: localizations.tun,
            iconPath: setting.tun,
            defaultAsset: _defaultIcon(3),
            onPicked: (path) {
              notifier.update(
                (state) => state.copyWith(trayIconTunPath: path),
              );
            },
            onReset: () {
              notifier.update(
                (state) => state.copyWith(trayIconTunPath: null),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrayIconRow extends StatefulWidget {
  final String name;
  final String label;
  final String? iconPath;
  final String defaultAsset;
  final ValueChanged<String> onPicked;
  final VoidCallback onReset;

  const _TrayIconRow({
    required this.name,
    required this.label,
    required this.iconPath,
    required this.defaultAsset,
    required this.onPicked,
    required this.onReset,
  });

  @override
  State<_TrayIconRow> createState() => _TrayIconRowState();
}

class _TrayIconRowState extends State<_TrayIconRow> {
  Widget _buildPreview() {
    final path = widget.iconPath;
    if (path != null && File(path).existsSync()) {
      return Image.file(File(path), width: 24, height: 24);
    }
    return Image.asset(widget.defaultAsset, width: 24, height: 24);
  }

  Future<void> _pickIcon() async {
    final file = await picker.pickerFile();
    final sourcePath = file?.path;
    if (sourcePath == null) {
      return;
    }
    final extension = p.extension(sourcePath).toLowerCase();
    if (extension != '.png' && extension != '.ico') {
      return;
    }

    final destinationDirectory = Directory(
      p.join(await appPath.homeDirPath, 'tray_icons'),
    );
    await destinationDirectory.create(recursive: true);
    final destinationPath = p.join(
      destinationDirectory.path,
      '${widget.name}_$uniqueId$extension',
    );
    await File(sourcePath).copy(destinationPath);
    final previousPath = widget.iconPath;
    if (previousPath != null && previousPath != destinationPath) {
      await File(previousPath).safeDelete();
    }
    if (mounted) {
      setState(() {});
    }
    widget.onPicked(destinationPath);
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.iconPath;
    final hasCustomIcon = path != null && File(path).existsSync();
    return ListItem(
      leading: _buildPreview(),
      title: Text(widget.label),
      subtitle: Text(
        hasCustomIcon
            ? p.basename(path!)
            : context.appLocalizations.defaultText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: _pickIcon,
            child: Text(context.appLocalizations.edit),
          ),
          if (hasCustomIcon)
            TextButton(
              onPressed: widget.onReset,
              child: Text(context.appLocalizations.reset),
            ),
        ],
      ),
      tileTitleAlignment: ListTileTitleAlignment.center,
    );
  }
}
