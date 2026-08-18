import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_networking/main.dart';
import 'package:flutter_networking/data/services/hive_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final hiveService = LocalStorageService();
    await tester.pumpWidget(MyApp(hiveService: hiveService));
  });
}