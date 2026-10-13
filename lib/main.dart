import 'package:flutter/material.dart';

void main() {
  runApp(const CalcApp());
  } 

class CalcApp extends StatefulWidget {
  const CalcApp({super.key});

  @override
  State<CalcApp> createState() => _CalcAppState();
}

class _CalcAppState extends State<CalcApp> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: Colors.blueAccent,
        secondary: Colors.redAccent,
      ),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.red,
      ),
    );

    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: isDark ? darkTheme : lightTheme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Calculator(
          isDark: isDark,
          onToggleTheme: () {
            setState(() => isDark = !isDark);
          },
        ),
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const Calculator({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  double accumulator = 0;
  String? op;
  String buffer = "";
  bool afterEquals = false;
  String display = "0";
  bool error = false;

  void pressDigit(String d) {
    if (error) {
      _reset();
    }
    if (afterEquals) {
      _reset();
    }
    buffer += d;
    setState(() => display = buffer);
  }

  void pressOperator(String newOp) {
    if (error) return;

    setState(() {
      afterEquals = false;

      if (buffer.isEmpty && op != null) {
        op = newOp;
        return;
      }

      if (op == null && buffer.isNotEmpty) {
        accumulator = double.parse(buffer);
        buffer = "";
        op = newOp;
        display = accumulator.toString();
        return;
      }

      if (op != null && buffer.isNotEmpty) {
        final value = double.parse(buffer);

        final result = _apply(accumulator, value, op!);
        if (result == null) {
          display = "Error";
          error = true;
          return;
        }

        accumulator = result;
        buffer = "";
        op = newOp;
        display = accumulator.toString();
      }
    });
  }

  void pressEquals() {
    if (error) return;

    setState(() {
      if (buffer.isEmpty || op == null) {
        return;
      }

      final value = double.parse(buffer);
      final result = _apply(accumulator, value, op!);

      if (result == null) {
        display = "Error";
        error = true;
        return;
      }

      accumulator = result;
      display = accumulator.toString();
      buffer = "";
      op = null;
      afterEquals = true;
    });
  }

  void pressClear() {
    setState(() => _reset());
  }

  void _reset() {
    accumulator = 0;
    op = null;
    buffer = "";
    display = "0";
    afterEquals = false;
    error = false;
  }

  double? _apply(double a, double b, String op) {
    if (op == '/' && b == 0) {
      return null; 
    }
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return a / b;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      '7','8','9','/',
      '4','5','6','*',
      '1','2','3','-',
      '0','.','=','+',
      'AC'
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Calculator"),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                display,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              itemCount: keys.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (_, i) {
                final k = keys[i];
                return _button(k);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _button(String label) {
    final theme = Theme.of(context).colorScheme;

    Color color = theme.primary;
    if (label == "AC") color = theme.secondary;
    if (RegExp(r'[0-9.]').hasMatch(label)) {
      color = widget.isDark ? Colors.grey[850]! : Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: () {
        if (RegExp(r'[0-9.]').hasMatch(label)) {
          pressDigit(label);
        } else if ("+-*/".contains(label)) {
          pressOperator(label);
        } else if (label == "=") {
          pressEquals();
        } else if (label == "AC") {
          pressClear();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
