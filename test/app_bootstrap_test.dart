import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galchat/app.dart';
import 'package:galchat/state/settings_state.dart';

void main() {
  testWidgets('waits for settings before building the home route',
      (tester) async {
    final settingsCompleter = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsLoadProvider.overrideWith((ref) => settingsCompleter.future),
        ],
        child: const GalChatApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
