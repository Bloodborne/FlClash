import 'package:fl_clash/common/tray.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:test/test.dart';

void main() {
  group('AppTray.getTrayIcon', () {
    final windows = AppTray.forPlatform(isMacOS: false, isWindows: true);
    final macOS = AppTray.forPlatform(isMacOS: true, isWindows: false);
    final linux = AppTray.forPlatform(isMacOS: false, isWindows: false);

    test('windows loads ico files from the windows directory', () {
      expect(
        windows.getTrayIcon(
          isStart: false,
          tunEnable: false,
          safeMode: false,
          mode: Mode.rule,
        ),
        'assets/images/tray/windows/status_1.ico',
      );
      expect(
        windows.getTrayIcon(
          isStart: true,
          tunEnable: false,
          safeMode: false,
          mode: Mode.global,
        ),
        'assets/images/tray/windows/status_2.ico',
      );
      expect(
        windows.getTrayIcon(
          isStart: true,
          tunEnable: false,
          safeMode: false,
          mode: Mode.direct,
        ),
        'assets/images/tray/windows/status_5.ico',
      );
      expect(
        windows.getTrayIcon(
          isStart: true,
          tunEnable: true,
          safeMode: false,
          mode: Mode.global,
        ),
        'assets/images/tray/windows/status_3.ico',
      );
      expect(
        windows.getTrayIcon(
          isStart: true,
          tunEnable: false,
          safeMode: false,
          mode: Mode.rule,
        ),
        'assets/images/tray/windows/status_6.ico',
      );
    });

    test('linux loads png files from the unix directory', () {
      expect(
        linux.getTrayIcon(
          isStart: false,
          tunEnable: false,
          safeMode: false,
          mode: Mode.rule,
        ),
        'assets/images/tray/unix/status_1.png',
      );
      expect(
        linux.getTrayIcon(
          isStart: true,
          tunEnable: false,
          safeMode: false,
          mode: Mode.global,
        ),
        'assets/images/tray/unix/status_2.png',
      );
      expect(
        linux.getTrayIcon(
          isStart: true,
          tunEnable: false,
          safeMode: false,
          mode: Mode.direct,
        ),
        'assets/images/tray/unix/status_5.png',
      );
      expect(
        linux.getTrayIcon(
          isStart: true,
          tunEnable: true,
          safeMode: false,
          mode: Mode.global,
        ),
        'assets/images/tray/unix/status_3.png',
      );
      expect(
        linux.getTrayIcon(
          isStart: true,
          tunEnable: false,
          safeMode: false,
          mode: Mode.rule,
        ),
        'assets/images/tray/unix/status_6.png',
      );
    });

    test('macOS uses distinct template icons for each mode', () {
      for (final (isStart, tunEnable, mode, status) in [
        (false, false, Mode.rule, 1),
        (true, false, Mode.global, 2),
        (true, false, Mode.direct, 5),
        (true, true, Mode.global, 3),
        (true, false, Mode.rule, 6),
      ]) {
        expect(
          macOS.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: false,
            mode: mode,
          ),
          'assets/images/tray/macos/status_$status.png',
        );
      }
    });

    test('macOS shows the color icons once monochrome is off', () {
      for (final (isStart, tunEnable, safeMode, mode, status) in [
        (false, false, false, Mode.rule, 1),
        (true, false, false, Mode.global, 2),
        (true, false, false, Mode.direct, 5),
        (true, true, false, Mode.global, 3),
        (true, false, false, Mode.rule, 6),
        (true, true, true, Mode.direct, 4),
      ]) {
        expect(
          macOS.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: safeMode,
            mode: mode,
            monochrome: false,
          ),
          'assets/images/tray/unix/status_$status.png',
        );
      }
    });

    test('safe mode shows its own icon whatever the core is doing', () {
      for (final (isStart, tunEnable) in [
        (false, false),
        (true, false),
        (true, true),
      ]) {
        expect(
          windows.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: true,
            mode: Mode.global,
          ),
          'assets/images/tray/windows/status_4.ico',
        );
        expect(
          linux.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: true,
            mode: Mode.global,
          ),
          'assets/images/tray/unix/status_4.png',
        );
        expect(
          macOS.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: true,
            mode: Mode.global,
          ),
          'assets/images/tray/macos/status_4.png',
        );
      }
    });
  });
}
