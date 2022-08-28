// ignore_for_file: prefer_const_constructors
import 'package:calculator/buttons.dart';
import 'package:calculator/caculationHistory.dart';
import 'package:calculator/database/dbhelper.dart';
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

  var tempUserInput;
  var tempResult;

  // List<Map<String,dynamic>> _lastTenHistory = [];
  List<Map<String, dynamic>> _lastTenHistory = [];

  // refresh the last 10 history
  void _refreshHistory() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _lastTenHistory = data;
    });
  }

// load the last 10 history at the start
  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

// insert a new hisotry to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(userInput, result);
    _refreshHistory();
  }

  Future<void> _deleteItem(id) async {
    await SQLHelper.deleteItem(id);
    _refreshHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                _lastTenHistory.isEmpty? showHistoryClearToast(context):Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: ListView.builder(
                itemCount: _lastTenHistory.length,
                itemBuilder: (context, index) {
                  return Card(
                      color: Colors.deepPurple[100],
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _lastTenHistory[index]['result'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _lastTenHistory[index]['query'],
                                textAlign: TextAlign.left,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ));
                  ;
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.deepPurple.withOpacity(0.7),
                child: Center(
                  child: InkWell(
                    onTap: () => {
                      for (int i = 0; i < _lastTenHistory.length; i++)
                        {_deleteItem(_lastTenHistory[i]['id'])},
                        showHistoryClearToast(context)
                        
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.green),
                      child: Text(
                        "Clear",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                // margin: EdgeInsets.all(12.0),
                // child: Text("Clear",style: TextStyle(color: Colors.white),),
                // padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 16.0),
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.green),
              ),
            )
          ],
        ),
      ),
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
                                  // condition to store data based on whether user has updated the previous data or not
                                  if (tempUserInput != userInput &&
                                      tempResult != result) {
                                    tempUserInput = userInput;
                                    tempResult = result;

                                    _addItem();
                                  }
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
      if (operationSymbol == '%') {
        percentageCalculate();
      }
    }
  }

  void invertInput() {
    if (!userInput.startsWith("-")) {
      userInput = "-" + userInput;
    } else {
      userInput = userInput.substring(1, userInput.length);
    }
  }

  void percentageCalculate() {
    var count = userInput.replaceAll("=", "").replaceAll("", "").split("%");
    if (count.length == 2) {
      if (count[1].isNotEmpty) {
        var s = (int.parse(count[0]) / 100) * int.parse(count[1]);
        setState(() {
          result = s.toString();
        });
      } else {
        var s = int.parse(count[0]) / 100;
        setState(() {
          result = s.toString();
        });
      }
    } else if (count.length == 1 || count.length == 2) {
      var s = int.parse(count[0]) / 100;
      setState(() {
        result = s.toString();
      });
    }
  }

  void showHistoryClearToast(BuildContext context){
    final scaffold = ScaffoldMessenger.of(context);
    // final scaffoldclose = Scaffold.of(context).closeDrawer();
    scaffold.showSnackBar(
      SnackBar(content:_lastTenHistory.isEmpty?Text("History is Empty"):Text("History has been cleared"),
      )
    );
    
  }
}
