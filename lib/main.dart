// ignore_for_file: prefer_const_constructors
import 'package:calculator/buttons.dart';
import 'package:calculator/caculationHistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> buttons = [
    'C',
    'DEL',
    '%',
    '/',
    '7',
    '8',
    '9',
    'x',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '+/-',
    '0',
    '.',
    '=',
  ];

  var userInput = '0';
  var result = '0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.history
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(),
      backgroundColor: Colors.deepPurple[100],
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        userInput,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.centerRight,
                      child: Text(
                        result,
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
            ),
          ),
          Expanded(
              child: Container(
                child: Center(
                    child: GridView.builder(
                        itemCount: buttons.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            return MyButton(
                                buttonTapped: () {
                                  setState(() {
                                    userInput = '0';
                                    result = '0';
                                  });
                                },
                                buttonText: buttons[index],
                                color: Colors.green,
                                textColor: Colors.white);
                          } else if (index == 1) {
                            return MyButton(
                                buttonTapped: () {
                                  setState(() {
                                    if (userInput.length > 1) {
                                      userInput = userInput.substring(
                                          0, userInput.length - 1);
                                    } else {
                                      userInput = '0';
                                    }
                                  });
                                },
                                buttonText: buttons[index],
                                color: Colors.red,
                                textColor: Colors.white);
                          } else if (index == 19) {
                            return MyButton(
                                buttonTapped: () {
                                  setState(() {
                                    equalPressed();
                                  });
                                },
                                buttonText: buttons[index],
                                color: isOperator(buttons[index])
                                    ? Colors.deepPurple
                                    : Colors.deepPurple[50],
                                textColor: Colors.white);
                          } else {
                            return MyButton(
                                buttonTapped: () {
                                  setState(() {
                                    if (buttons[index] == '%' ||
                                        buttons[index] == '/' ||
                                        buttons[index] == 'x' ||
                                        buttons[index] == '-' ||
                                        buttons[index] == '+' ||
                                        buttons[index] == '=' ||
                                        buttons[index] == '.') {
                                      validateOperations(index);
                                    } else if (buttons[index] == '+/-') {
                                      invertInput();
                                    } else {
                                      validateNumbers(index);
                                    }
                                  });
                                },
                                buttonText: buttons[index],
                                color: isOperator(buttons[index])
                                    ? Colors.deepPurple
                                    : Colors.deepPurple[50],
                                textColor: isOperator(buttons[index])
                                    ? Colors.white
                                    : Colors.deepPurple);
                          }
                        })),
              ),
              flex: 2)
        ],
      ),
    );
  }

  bool isOperator(String x) {
    if (x == '%' || x == '/' || x == 'x' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

  void equalPressed() {
    String finalUserInput = userInput;
    finalUserInput = userInput.replaceAll('x', '*');
    Parser p = Parser();
    Expression exp = p.parse(finalUserInput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    result = eval.toString();
  }

  void validateNumbers(index) {
    if (userInput == '0') {
      userInput = buttons[index];
    } else {
      userInput += buttons[index];
    }
  }

  void validateOperations(index) {
    var operationSymbol = buttons[index];
    final List<String> symbols = ['+', '-', 'x', '/', '%'];

    // only display the operation symbol if userInput is not 0 or the last element of userInput is not operationsSymbol itself
    if (!userInput.endsWith(operationSymbol) && userInput != '0') {
      userInput += operationSymbol;
    }
  }

  void invertInput() {}
}
