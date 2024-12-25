import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/widgets/app_spacer.dart';

class WindowCloseController extends GetxController with WindowListener {
  RxBool isWindowClosePrevented = false.obs;

  @override
  void onInit() {
    super.onInit();

    windowManager.addListener(this);
    _configureWindowSettings();
  }

  @override
  void onClose() {
    windowManager.removeListener(this);
    super.onClose();
  }

  Future<void> _configureWindowSettings() async {
    await windowManager.setPreventClose(true);
    isWindowClosePrevented.value = true;
  }

  Future<bool> _showMacOSExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: Get.context!,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: const Color(0xFF2C2C2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2C2C2E), strokeAlign: BorderSide.strokeAlignOutside),
              ),
              child: Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6C6D6F)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 75,
                      height: 75,
                      child: FlutterLogo(),
                    ),
                    const VerticalSpace(16),
                    const Text(
                      '?Do you really want to quit',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back(result: true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Exit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const HorizontalSpace(),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back(result: false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C6D6F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false; // Default return if dismissed
  }

  Future<bool> _showDefaultExitDialog() async {
    return await Get.defaultDialog(
          content: const Text('?Do you really want to quit'),
          confirm: ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text('Exit'),
          ),
          cancel: ElevatedButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('Cancel'),
          ),
        ) ??
        false; // Default return if dismissed
  }

  Future<bool> showExitConfirmationDialog() async {
    if (Platform.isMacOS) {
      return _showMacOSExitConfirmationDialog();
    } else {
      return _showDefaultExitDialog();
    }
  }

  @override
  Future<void> onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();

    if (isPreventClose) {
      // Show the macOS-like exit confirmation dialog
      bool shouldClose = await showExitConfirmationDialog();

      if (shouldClose) {
        await windowManager.destroy(); // Close the window
      }
    }
  }
}
