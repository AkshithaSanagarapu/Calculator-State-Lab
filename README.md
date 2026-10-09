
# Calculator State Lab

**CSC 6370 — Mobile App Development**  
**Assignment 01: Calculator State Lab**  
**Student:** Akshitha Sainath Sanagarapu (003027780)
**Framework:** Flutter / Dart

## Project Overview

Calculator State Lab is a Flutter calculator application designed to demonstrate explicit state management, predictable state transitions, arithmetic operations, and error recovery.

Unlike a traditional calculator that follows mathematical operator precedence, this application evaluates operations from left to right, as required by the assignment.

For example:

2 + 3 × 4 = 20

The application also includes three advanced features: calculation history, backspace/delete, and advanced error handling.

## Features

### 1. Basic Calculator Operations

- Addition (+)
- Subtraction (−)
- Multiplication (×)
- Division (÷)
- Decimal number support
- Clear all (AC)
- Equals (=)
- Left-to-right arithmetic evaluation

### 2. Explicit State Management

The calculator tracks:

- Current input
- Accumulated result
- Pending operator
- Whether the next operand is expected
- Whether equals was just pressed
- Current expression
- Error state
- Calculation history

The calculator handles important transitions:

- Pressing an operator repeatedly replaces the pending operator.
- Pressing equals without entering another operand does not perform an incomplete operation.
- Entering a digit after equals starts a new calculation.
- Pressing AC resets the calculator state.
- Pressing multiple decimal points in one operand does not create an invalid number.

### 3. Calculation History

- Completed calculations are saved in history.
- Users can open history using the history icon.
- Previous calculations can be reviewed.
- Tapping a history entry reuses its result.
- History can be cleared.

### 4. Backspace / Delete

- The backspace button (⌫) removes the last digit.
- Users can correct input without restarting the calculation.
- A long press provides the clear action.

### 5. Advanced Error Handling

- Division by zero displays a meaningful error message.
- Invalid or overflowing results are handled.
- The calculator supports recovery from errors without restarting the application.

## Calculator State Contract

| User Action | Expected Behavior |
|---|---|
| Enter digit | Updates the current operand |
| Enter decimal | Adds a decimal point if one is not already present |
| Press operator | Stores the operator and prepares for the next operand |
| Press another operator | Replaces the pending operator |
| Press equals | Evaluates a complete pending operation |
| Press equals without next operand | Keeps the existing value |
| Enter digit after equals | Starts a new calculation |
| Press AC | Resets the calculator state |
| Press backspace | Removes the last digit |
| Divide by zero | Displays an error message |
| Select history entry | Reuses the saved result |

## Example Test Cases

| Test | Input | Expected Result |
|---|---|---|
| Left-to-right evaluation | 2 + 3 × 4 = | 20 |
| Operator replacement | 9 + × 2 = | 18 |
| Equals without operand | 7 + = | 7 |
| Decimal addition | 1.5 + 2.5 = | 4 |
| Decimal subtraction | 5.5 − 2.2 = | 3.3 |
| Decimal multiplication | 1.5 × 2 = | 3 |
| Decimal division | 7.5 ÷ 2 = | 3.75 |
| Repeated decimal | 1.2.3 | 1.23 |
| Division by zero | 8 ÷ 0 = | Cannot divide by zero |
| Backspace | 98 ⌫ | 9 |
| New calculation after equals | 5 + 2 =, then 8 | 8 |
| History reuse | 6 ÷ 2 =, select history | 3 |

## Automated Testing

The project includes Flutter widget tests in:

`test/widget_test.dart`

The automated test suite verifies:

1. Initial calculator state
2. Left-to-right arithmetic
3. Repeated operator replacement
4. Equals without a second operand
5. Decimal addition
6. Decimal subtraction
7. Decimal multiplication
8. Decimal division
9. Repeated decimal prevention
10. Division-by-zero handling
11. Clear-all functionality
12. Backspace functionality
13. New input after equals
14. History storage and result reuse

**Latest verified test results:**

- Flutter analyze: No issues found
- Flutter widget tests: 14/14 passed

## Technology Stack

- Flutter
- Dart
- Material Design
- Flutter Widget Testing
- Android Emulator

## Running the Application

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android emulator or physical Android device

### Setup

Clone the repository:

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd calculator_app
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Running Tests

Check the code:

```bash
flutter analyze
```

Run automated tests:

```bash
flutter test
```

## Building the Android APK

Generate a release APK:

```bash
flutter build apk --release
```

The generated APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Rename the APK for assignment submission:

```bash
cp build/app/outputs/flutter-apk/app-release.apk Sanagarapu_Akshitha_CalculatorApp.apk
```

## Project Structure

```text
calculator_app/
├── android/
├── ios/
├── lib/
│   └── main.dart
├── test/
│   └── widget_test.dart
├── README.md
└── pubspec.yaml
```

## Assignment Deliverables

- GitHub repository containing the source code
- `github_link.txt` containing the repository URL
- `Sanagarapu_Akshitha_CalculatorApp.apk`
- Graduate implementation document (`.docx`)

## AI Assistance Disclosure

AI assistance was used to help develop and refine the calculator implementation, improve Flutter layout behavior, and create automated widget tests.

The application was manually tested using an Android emulator. The automated test suite was executed using `flutter test`, and the code was checked using `flutter analyze`.

Additional AI Test Drive comparisons and reflections are documented separately in the graduate implementation report.

## Conclusion

Calculator State Lab demonstrates state-driven UI development in Flutter through arithmetic operations, controlled state transitions, history management, input correction, and error handling.

The project passed all 14 automated widget tests and Flutter static analysis.
