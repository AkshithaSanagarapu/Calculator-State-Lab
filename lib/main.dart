import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator State Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6555D8),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF11121B),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class HistoryEntry {
  final String expression;
  final String result;

  const HistoryEntry(this.expression, this.result);
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '0';
  double? _accumulator;
  String? _operator;
  bool _awaitingOperand = false;
  bool _afterEquals = false;
  String? _error;
  String _expression = '';
  final List<HistoryEntry> _history = [];

  static const Color accent = Color(0xFF9D8CFF);
  static const Color surface = Color(0xFF202231);

  String _format(double value) {
    if (!value.isFinite) return 'Error';
    if (value == 0) return '0';
    final text = value.toStringAsPrecision(12);
    final number = double.parse(text);
    if (number.abs() < 1e15 && number == number.truncateToDouble()) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  String get _display => _error ?? _input;

  void _clear() {
    setState(() {
      _input = '0';
      _accumulator = null;
      _operator = null;
      _awaitingOperand = false;
      _afterEquals = false;
      _error = null;
      _expression = '';
    });
  }

  void _digit(String digit) {
    setState(() {
      if (_error != null || _afterEquals) {
        _input = '0';
        _accumulator = null;
        _operator = null;
        _error = null;
        _expression = '';
        _afterEquals = false;
        _awaitingOperand = false;
      }

      if (_awaitingOperand) {
        _input = digit;
        _awaitingOperand = false;
      } else if (_input == '0') {
        _input = digit;
      } else if (_input == '-0') {
        _input = digit == '0' ? '-0' : '-$digit';
      } else if (_input.length < 16) {
        _input += digit;
      }
    });
  }

  void _decimal() {
    setState(() {
      if (_error != null || _afterEquals) {
        _input = '0';
        _accumulator = null;
        _operator = null;
        _error = null;
        _expression = '';
        _afterEquals = false;
        _awaitingOperand = false;
      }

      if (_awaitingOperand) {
        _input = '0.';
        _awaitingOperand = false;
      } else if (!_input.contains('.')) {
        _input += '.';
      }
    });
  }

  double? _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return null;
        return a / b;
      default:
        return null;
    }
  }

  void _setError(String message) {
    _error = message;
    _input = '0';
    _accumulator = null;
    _operator = null;
    _awaitingOperand = false;
    _afterEquals = false;
    _expression = '';
  }

  void _chooseOperator(String op) {
    setState(() {
      if (_error != null) return;

      if (_afterEquals) {
        _afterEquals = false;
      }

      final current = double.tryParse(_input);
      if (current == null) {
        _setError('Invalid number');
        return;
      }

      if (_operator != null && _awaitingOperand) {
        _operator = op;
        _expression = '${_format(_accumulator!)} $op';
        return;
      }

      if (_accumulator != null && _operator != null) {
        final result = _calculate(_accumulator!, current, _operator!);

        if (result == null) {
          _setError('Cannot divide by zero');
          return;
        }
        if (!result.isFinite) {
          _setError('Number overflow');
          return;
        }

        _accumulator = result;
        _input = _format(result);
      } else {
        _accumulator = current;
      }

      _operator = op;
      _awaitingOperand = true;
      _expression = '${_format(_accumulator!)} $op';
    });
  }

  void _equals() {
    setState(() {
      if (_error != null || _operator == null) return;
      if (_awaitingOperand) return;

      final second = double.tryParse(_input);
      if (second == null || _accumulator == null) {
        _setError('Invalid input');
        return;
      }

      final first = _accumulator!;
      final op = _operator!;
      final result = _calculate(first, second, op);

      if (result == null) {
        _setError('Cannot divide by zero');
        return;
      }
      if (!result.isFinite) {
        _setError('Number overflow');
        return;
      }

      final formatted = _format(result);
      final expression = '${_format(first)} $op ${_format(second)}';

      _history.insert(0, HistoryEntry(expression, formatted));

      _input = formatted;
      _expression = '$expression =';
      _accumulator = null;
      _operator = null;
      _awaitingOperand = false;
      _afterEquals = true;
    });
  }

  void _backspace() {
    setState(() {
      if (_error != null) {
        _setError('');
        _error = null;
        return;
      }

      if (_afterEquals) {
        _afterEquals = false;
        _expression = '';
      }

      if (_awaitingOperand) {
        _operator = null;
        _awaitingOperand = false;
        _expression = '';
        return;
      }

      if (_input.length <= 1 ||
          (_input.length == 2 && _input.startsWith('-'))) {
        _input = '0';
      } else {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _reuseResult(HistoryEntry entry) {
    setState(() {
      _input = entry.result;
      _accumulator = null;
      _operator = null;
      _awaitingOperand = false;
      _afterEquals = false;
      _error = null;
      _expression = '';
    });
    Navigator.pop(context);
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF202231),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, refreshSheet) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Calculation History',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(_history.clear);
                              refreshSheet(() {});
                            },
                            child: const Text('Clear history'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _history.isEmpty
                          ? const Center(child: Text('No calculations yet'))
                          : ListView.builder(
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                final entry = _history[index];
                                return ListTile(
                                  title: Text(entry.expression),
                                  subtitle: Text(
                                    '= ${entry.result}',
                                    style: const TextStyle(
                                      color: accent,
                                      fontSize: 20,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.north_west),
                                  onTap: () => _reuseResult(entry),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _press(String value) {
    if (RegExp(r'^[0-9]$').hasMatch(value)) {
      _digit(value);
    } else if (value == '.') {
      _decimal();
    } else if (value == 'AC') {
      _clear();
    } else if (value == '⌫') {
      _backspace();
    } else if (value == '=') {
      _equals();
    } else {
      _chooseOperator(value);
    }
  }

  Widget _button(String label, {int flex = 1}) {
    final isOperator = ['+', '−', '×', '÷', '='].contains(label);
    final isAction = ['AC', '⌫'].contains(label);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: label == '='
              ? accent
              : isOperator
              ? const Color(0xFF383052)
              : isAction
              ? const Color(0xFF343747)
              : surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _press(label),
            onLongPress: label == '⌫' ? _clear : null,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: label == '='
                      ? const Color(0xFF151322)
                      : isOperator
                      ? accent
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonRow(List<String> labels) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final label in labels) _button(label)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'STATE LAB',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Calculation history',
            onPressed: _showHistory,
            icon: const Icon(Icons.history, size: 28),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'LEFT-TO-RIGHT MODE',
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _expression,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _display,
                          style: TextStyle(
                            color: _error != null
                                ? Colors.redAccent
                                : Colors.white,
                            fontSize: _error != null ? 28 : 62,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    _buttonRow(['AC', '⌫', '÷']),
                    _buttonRow(['7', '8', '9', '×']),
                    _buttonRow(['4', '5', '6', '−']),
                    _buttonRow(['1', '2', '3', '+']),
                    _buttonRow(['0', '.', '=']),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Long-press ⌫ to reset • Tap history to reuse',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
