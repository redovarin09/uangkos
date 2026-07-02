import 'package:flutter_test/flutter_test.dart';
import 'package:uang_kos/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UangKosApp());
  });
}
