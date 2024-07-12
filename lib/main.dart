// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:expense_planner/helpers/db_helper.dart';
import './screens/splash_screen.dart';
import 'package:intl/intl.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './models/transaction.dart';
import 'package:flutter/material.dart';
import './widgets/chart.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData theme = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expenses',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(secondary: Colors.amberAccent),
      ),
      home:SplashScreen(),
      routes: {
        MyHomePage.routeName:(ctx) => MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const routeName = '/first';
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];
   bool _isLoading = false;
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchAndSetTransactions();
  }

  Future<void> _fetchAndSetTransactions() async {
     setState(() {
      _isLoading = true; // Set loading flag to true when fetching starts
    });
    final dataList = await DbHelper.getData('user_transactions');
    setState(() {
      _userTransactions = dataList
          .map(
            (item) => Transaction(
              id: item['id'],
              title: item['title'],
              amount: item['amount'],
              date: DateTime.parse(
                  item['date'].toString().replaceAll(' – ', 'T')),
            ),
          )
          .toList();
    });
     _isLoading = false;
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) async {
    String time = DateTime.now().toString();
    String formattedDate = chosenDate.toIso8601String(); // Use ISO 8601 format
    final newTx = Transaction(
        id: time, title: txTitle, amount: txAmount, date: chosenDate);

    await DbHelper.insert('user_transactions', {
      'id': time,
      'title': txTitle,
      'amount': txAmount,
      'date': formattedDate,
    });

    _fetchAndSetTransactions();
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return NewTransaction(_addNewTransaction);
        });
  }

  void _deleteTransaction(String id) async {
    await DbHelper.delete('user_transactions', id);
    _fetchAndSetTransactions(); // Refresh the transactions from the database
  }

  List<Widget> _buildLandscapeContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Show Chart'),
          Switch.adaptive(
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(_recentTransactions))
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

  @override
  Widget build(BuildContext context) {
    // print('build() MyHomePageState'); // To check the flow of code...
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final appBar = AppBar(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      title: Text(
        'Personal Expenses',
        style: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
      ],
    );
    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
    return Scaffold(
      appBar: appBar,
      body:  _isLoading // Show CircularProgressIndicator if loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              ..._buildLandscapeContent(
                mediaQuery,
                appBar,
                txListWidget,
              ),
            if (!isLandscape)
              ..._buildPortraitContent(
                mediaQuery,
                appBar,
                txListWidget,
              ),
          ],
        ),
      ),
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.black,
              onPressed: () => _startAddNewTransaction(context),
              child: Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
