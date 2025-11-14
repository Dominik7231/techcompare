// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:techcomparev1/main.dart';

void main() {
  testWidgets('MyApp builds and shows title', (WidgetTester tester) async {
    final previousSize = tester.binding.platformDispatcher.views.first.physicalSize;
    final previousRatio = tester.binding.platformDispatcher.views.first.devicePixelRatio;
    tester.binding.platformDispatcher.views.first.physicalSize = const ui.Size(1280, 800);
    tester.binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.binding.platformDispatcher.views.first.physicalSize = previousSize;
      tester.binding.platformDispatcher.views.first.devicePixelRatio = previousRatio;
    });
    await tester.pumpWidget(const MyApp(enableAds: false));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Tech Compare'), findsWidgets);
  });
}
