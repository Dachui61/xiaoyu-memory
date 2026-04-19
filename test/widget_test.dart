import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xiaoyu_memory/app/app.dart';

void main() {
  testWidgets('App smoke test - app launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(child: XiaoYuApp()),
    );
    // App should render without crashing - just verify the widget tree builds
    expect(find.byType(XiaoYuApp), findsOneWidget);
  });
}
