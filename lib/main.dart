import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const BrightCalcApp());

class BrightCalcApp extends StatefulWidget {
  const BrightCalcApp({super.key});
  @override
  State<BrightCalcApp> createState() => _BrightCalcAppState();
}

class _BrightCalcAppState extends State<BrightCalcApp> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7C5CFC);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bright Calculator',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF5F3FC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF101018),
      ),
      home: CalculatorPage(
        isDark: isDark,
        onThemeChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, required this.isDark, required this.onThemeChanged});
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = '';
  String result = '0';
  final List<String> history = [];

  final List<List<String>> keys = const [
    ['AC', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['±', '0', '.', '='],
  ];

  void tap(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'AC') {
        expression = '';
        result = '0';
      } else if (key == '⌫') {
        if (expression.isNotEmpty) expression = expression.substring(0, expression.length - 1);
        _preview();
      } else if (key == '=') {
        _calculate();
      } else if (key == '±') {
        if (expression.isEmpty) {
          expression = '-';
        } else if (expression.startsWith('-')) {
          expression = expression.substring(1);
        } else {
          expression = '-$expression';
        }
        _preview();
      } else {
        if (key == '.') {
          final last = expression.split(RegExp(r'[+\−×÷()]')).last;
          if (last.contains('.')) return;
          if (last.isEmpty) expression += '0';
        }
        if ('+−×÷'.contains(key) && expression.isNotEmpty &&
            '+−×÷'.contains(expression[expression.length - 1])) {
          expression = expression.substring(0, expression.length - 1);
        }
        expression += key;
        _preview();
      }
    });
  }

  void _preview() {
    if (expression.isEmpty || expression == '-') {
      result = '0';
      return;
    }
    try {
      result = _format(ExpressionParser(expression).parse());
    } catch (_) {
      // Keep the last valid preview while the user is still typing.
    }
  }

  void _calculate() {
    if (expression.isEmpty) return;
    try {
      final answer = ExpressionParser(expression).parse();
      final formatted = _format(answer);
      history.insert(0, '$expression = $formatted');
      if (history.length > 30) history.removeLast();
      expression = formatted;
      result = formatted;
    } catch (_) {
      result = 'Error';
    }
  }

  String _format(double value) {
    if (!value.isFinite) return 'Error';
    if (value.abs() < 1e-10) return '0';
    if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
    return value.toStringAsPrecision(10).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Color _keyColor(String key, ColorScheme scheme) {
    if (key == '=') return scheme.primary;
    if ('÷×−+'.contains(key) || key == '%') return scheme.tertiaryContainer;
    if (key == 'AC' || key == '⌫' || key == '±') return scheme.secondaryContainer;
    return widget.isDark ? const Color(0xFF242431) : Colors.white;
  }

  Color _keyTextColor(String key, ColorScheme scheme) {
    if (key == '=') return scheme.onPrimary;
    if ('÷×−+'.contains(key) || key == '%') return scheme.onTertiaryContainer;
    if (key == 'AC' || key == '⌫' || key == '±') return scheme.onSecondaryContainer;
    return scheme.onSurface;
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 360,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Calculation history', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: history.isEmpty
                    ? const Center(child: Text('No calculations yet'))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (_, i) => ListTile(
                          title: Text(history[i], textAlign: TextAlign.end),
                          onTap: () {
                            setState(() {
                              final parts = history[i].split(' = ');
                              expression = parts.first;
                              result = parts.last;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => history.clear());
                  Navigator.pop(context);
                },
                child: const Text('Clear history'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bright Calculator', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(tooltip: 'History', onPressed: _showHistory, icon: const Icon(Icons.history_rounded)),
          IconButton(
            tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
            onPressed: () => widget.onThemeChanged(!widget.isDark),
            icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          expression.isEmpty ? '0' : expression,
                          style: TextStyle(fontSize: 30, color: scheme.onSurface.withOpacity(.65)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          result,
                          style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w700, letterSpacing: -1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  children: keys.map((row) => Expanded(
                    child: Row(
                      children: row.map((key) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Material(
                            color: _keyColor(key, scheme),
                            borderRadius: BorderRadius.circular(22),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => tap(key),
                              child: Center(
                                child: Text(
                                  key,
                                  style: TextStyle(
                                    fontSize: key == 'AC' ? 20 : 27,
                                    fontWeight: FontWeight.w600,
                                    color: _keyTextColor(key, scheme),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 5),
              Text('Simple • Smart • Bright', style: TextStyle(color: scheme.onSurface.withOpacity(.45), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpressionParser {
  ExpressionParser(String input) : tokens = _tokenize(input);
  final List<String> tokens;
  int index = 0;

  static List<String> _tokenize(String input) {
    final normalized = input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('−', '-');
    final out = <String>[];
    final number = StringBuffer();
    void flush() {
      if (number.isNotEmpty) {
        out.add(number.toString());
        number.clear();
      }
    }
    for (final rune in normalized.runes) {
      final c = String.fromCharCode(rune);
      if ('0123456789.'.contains(c)) {
        number.write(c);
      } else if ('+-*/()%'.contains(c)) {
        flush();
        out.add(c);
      } else if (c.trim().isNotEmpty) {
        throw const FormatException('Invalid character');
      }
    }
    flush();
    return out;
  }

  double parse() {
    final value = _expression();
    if (index != tokens.length) throw const FormatException('Unexpected token');
    return value;
  }

  double _expression() {
    var value = _term();
    while (index < tokens.length && (tokens[index] == '+' || tokens[index] == '-')) {
      final op = tokens[index++];
      final rhs = _term();
      value = op == '+' ? value + rhs : value - rhs;
    }
    return value;
  }

  double _term() {
    var value = _unary();
    while (index < tokens.length && (tokens[index] == '*' || tokens[index] == '/')) {
      final op = tokens[index++];
      final rhs = _unary();
      if (op == '/' && rhs == 0) throw const FormatException('Divide by zero');
      value = op == '*' ? value * rhs : value / rhs;
    }
    return value;
  }

  double _unary() {
    if (index < tokens.length && tokens[index] == '-') {
      index++;
      return -_unary();
    }
    if (index < tokens.length && tokens[index] == '+') {
      index++;
      return _unary();
    }
    var value = _primary();
    while (index < tokens.length && tokens[index] == '%') {
      index++;
      value /= 100;
    }
    return value;
  }

  double _primary() {
    if (index >= tokens.length) throw const FormatException('Missing number');
    if (tokens[index] == '(') {
      index++;
      final value = _expression();
      if (index >= tokens.length || tokens[index] != ')') throw const FormatException('Missing )');
      index++;
      return value;
    }
    final token = tokens[index++];
    final value = double.tryParse(token);
    if (value == null) throw const FormatException('Invalid number');
    return value;
  }
}
