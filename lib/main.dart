import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315C50)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F4EF),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double? _firstNumber;
  String? _operator;
  bool _startNewNumber = true;

  void _clear() {
    _display = '0';
    _expression = '';
    _firstNumber = null;
    _operator = null;
    _startNewNumber = true;
  }

  String _format(double number) =>
      double.parse(number.toStringAsPrecision(12))
          .toString()
          .replaceFirst(RegExp(r'\.0$'), '');

  // Keep one pending operation; choosing another evaluates it left to right.
  bool _calculate() {
    final secondNumber = double.parse(_display);
    final double result;
    switch (_operator) {
      case '+':
        result = _firstNumber! + secondNumber;
      case '−':
        result = _firstNumber! - secondNumber;
      case '×':
        result = _firstNumber! * secondNumber;
      case '÷':
        result = _firstNumber! / secondNumber;
      default:
        return true;
    }
    if (!result.isFinite) {
      final dividedByZero = secondNumber == 0 && _operator == '÷';
      _clear();
      _display = 'Error';
      _expression = dividedByZero
          ? 'Cannot divide by zero'
          : 'Cannot calculate this result';
      return false;
    }
    _display = _format(result);
    return true;
  }

  void _press(String key) {
    setState(() {
      if (key == 'AC') {
        _clear();
        return;
      }
      if (_display == 'Error') _clear();

      if ('0123456789.'.contains(key)) {
        if (_startNewNumber) {
          _display = key == '.' ? '0.' : key;
          _startNewNumber = false;
          if (_operator == null) _expression = '';
        } else if (key == '.') {
          if (!_display.contains('.')) _display += '.';
        } else if (_display.replaceAll(RegExp(r'[^0-9]'), '').length < 12) {
          _display = _display == '0' ? key : _display + key;
        }
      } else if (key == '⌫') {
        if (_startNewNumber) return;
        _display = _display.substring(0, _display.length - 1);
        if (_display.isEmpty || _display == '-') _display = '0';
      } else if (key == '±') {
        if (double.parse(_display) != 0) {
          _display = _display.startsWith('-')
              ? _display.substring(1)
              : '-$_display';
          if (_operator == null) _expression = '';
        }
      } else if (key == '=') {
        if (_operator == null || _startNewNumber) return;
        final expression = '${_format(_firstNumber!)} $_operator $_display =';
        if (!_calculate()) return;
        _expression = expression;
        _firstNumber = null;
        _operator = null;
        _startNewNumber = true;
      } else {
        if (_operator != null && !_startNewNumber && !_calculate()) return;
        _firstNumber = double.parse(_display);
        _operator = key;
        _expression = '${_format(_firstNumber!)} $key';
        _startNewNumber = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['AC', '±', '⌫', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Calculator',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text('A little space for everyday math.'),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EBE3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _expression.isEmpty ? ' ' : _expression,
                          key: const ValueKey('expression'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          label: 'Result',
                          child: SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _display,
                                key: const ValueKey('display'),
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final row in rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          for (var i = 0; i < row.length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: row[i] == '0' ? 2 : 1,
                              child: _button(row[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _button(String label) {
    final isOperator = ['÷', '×', '−', '+'].contains(label);
    final isUtility = ['AC', '±', '⌫'].contains(label);
    final isSelected = isOperator && label == _operator;
    final isDark = label == '=' || isSelected;
    return SizedBox(
      height: 64,
      child: FilledButton(
        onPressed: () => _press(label),
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isDark
              ? const Color(0xFF315C50)
              : isOperator || isUtility
              ? const Color(0xFFE4E8DF)
              : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF23392F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Semantics(
          label: switch (label) {
            '⌫' => 'Backspace',
            '±' => 'Change sign',
            'AC' => 'All clear',
            _ => label,
          },
          excludeSemantics: true,
          child: Text(label, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
