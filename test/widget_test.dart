import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:beverage_ims/main.dart';

void main() {
  testWidgets('App renders dashboard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Hai, Farisha!'), findsOneWidget);
  });
}
