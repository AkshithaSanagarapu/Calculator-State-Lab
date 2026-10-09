import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  Future<void> launchCalculator(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();
  }

  Future<void> press(WidgetTester tester, String label) async {
    final button = find.text(label).last;
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> calculate(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      await press(tester, key);
    }
  }

  void expectDisplay(String expected) {
    final display = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == expected &&
          widget.style?.fontWeight == FontWeight.w300,
    );

    expect(display, findsOneWidget);
  }

  testWidgets('Calculator starts with zero', (tester) async {
    await launchCalculator(tester);

    expect(find.text('STATE LAB'), findsOneWidget);
    expectDisplay('0');
  });

  testWidgets('Left-to-right evaluation gives 20', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['2', '+', '3', '×', '4', '=']);

    expectDisplay('20');
  });

  testWidgets('Repeated operator replaces pending operator', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['9', '+', '×', '2', '=']);

    expectDisplay('18');
  });

  testWidgets('Equals without operand is ignored', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['7', '+', '=']);
    expectDisplay('7');

    await calculate(tester, ['3', '=']);
    expectDisplay('10');
  });

  testWidgets('Decimal addition works', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['1', '.', '5', '+', '2', '.', '5', '=']);

    expectDisplay('4');
  });

  testWidgets('Decimal subtraction works', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['5', '.', '5', '−', '2', '.', '2', '=']);

    expectDisplay('3.3');
  });

  testWidgets('Decimal multiplication works', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['1', '.', '5', '×', '2', '=']);

    expectDisplay('3');
  });

  testWidgets('Decimal division works', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['7', '.', '5', '÷', '2', '=']);

    expectDisplay('3.75');
  });

  testWidgets('Multiple decimal points are prevented', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['1', '.', '2', '.', '3']);

    expectDisplay('1.23');
  });

  testWidgets('Division by zero shows error', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['8', '÷', '0', '=']);

    expect(find.text('Cannot divide by zero'), findsOneWidget);
  });

  testWidgets('AC clears pending calculation', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['9', '+', '3']);
    await press(tester, 'AC');

    expectDisplay('0');

    await calculate(tester, ['2', '+', '4', '=']);
    expectDisplay('6');
  });

  testWidgets('Backspace removes last digit', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['9', '8', '⌫']);

    expectDisplay('9');
  });

  testWidgets('Digit after equals starts fresh', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['5', '+', '2', '=', '8']);

    expectDisplay('8');
  });

  testWidgets('History saves and reuses result', (tester) async {
    await launchCalculator(tester);

    await calculate(tester, ['6', '÷', '2', '=']);

    expectDisplay('3');

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.text('6 ÷ 2'), findsOneWidget);

    await tester.tap(find.text('6 ÷ 2'));
    await tester.pumpAndSettle();

    expectDisplay('3');

    // Verify that the history sheet closed after reuse.
    expect(find.text('Calculation History'), findsNothing);

    // Verify that the reused result can start a new calculation.
    await calculate(tester, ['+', '4', '=']);
    expectDisplay('7');
  });
}
