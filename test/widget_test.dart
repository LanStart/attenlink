import 'package:flutter_test/flutter_test.dart';

import 'package:attenlink/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const AttenLinkApp());

    // Verify that the app renders with bottom navigation
    expect(find.text('探索'), findsOneWidget);
    expect(find.text('搜索'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
