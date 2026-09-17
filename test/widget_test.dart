import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplecalculator/main.dart';

void main() {
  Future<void> press(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      final button = find.widgetWithText(FilledButton, key);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
    }
  }

  String display(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('display'))).data!;

  testWidgets('Basic arithmetic and left-to-right chaining', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['8', '+', '2', '=']);
    expect(display(tester), '10');
    await press(tester, ['−', '4', '×', '3', '÷', '2', '=']);
    expect(display(tester), '9');
    await press(tester, ['7']);
    expect(display(tester), '7');
  });

  testWidgets('Decimals, editing, sign changes, and clear', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['.', '5', '.', '2', '⌫', '±', '+', '1', '=']);
    expect(display(tester), '0.5');
    await press(tester, ['AC']);
    expect(display(tester), '0');
    await press(tester, ['0', '.', '1', '+', '0', '.', '2', '=']);
    expect(display(tester), '0.3');
  });

  testWidgets('Replace an operator and recover from division by zero', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['6', '+', '×', '2', '=']);
    expect(display(tester), '12');
    await press(tester, ['÷', '0', '=']);
    expect(display(tester), 'Error');
    expect(find.text('Cannot divide by zero'), findsOneWidget);
    await press(tester, ['3', '+', '4', '=']);
    expect(display(tester), '7');
  });
}
