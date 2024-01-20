import '../models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transaction;
  final Function deleteTx;
  TransactionList(this.transaction,this.deleteTx);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: transaction.isEmpty
          ? Column(
              children: <Widget>[
                Text(
                  'No transactions added yet!',
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 150,
                ),
                Container(
                    height: 200,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    )),
              ],
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      radius: 30,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: FittedBox(
                            child: Text('\$${transaction[index].amount}')),
                      ),
                    ),
                    title: Text(
                      transaction[index].title,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                        DateFormat.yMMMd().format(transaction[index].date)),
                    trailing: IconButton(
                      color: Colors.red,
                      icon: Icon(
                        Icons.delete,
                      ),
                      onPressed: ()=> deleteTx(transaction[index].id),
                    ),
                  ),
                );
              },
              itemCount: transaction.length,
            ),
    );
  }
}
