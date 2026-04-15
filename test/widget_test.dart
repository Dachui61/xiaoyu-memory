import 'package:flutter_test/flutter_test.dart';
import 'package:xiaoyu_memory/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(child: XiaoYuApp()),
    );
    expect(find.text('小宇记忆'), findsOneWidget);
  });
}
