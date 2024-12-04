import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      home: ExpenseTrackerScreen(),
    );
  }
}

class ExpenseTrackerScreen extends StatefulWidget {
  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final List<Map<String, dynamic>> _expenses = [];
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _incomeController = TextEditingController();
  double _income = 0.0;

  bool _showMoneyAnimation = false;

  void _addExpense() {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text);

    if (description.isNotEmpty && amount != null && amount > 0) {
      setState(() {
        _expenses.add({'description': description, 'amount': amount});
        _showMoneyAnimation = true;
      });

      // Hide money animation after a delay
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _showMoneyAnimation = false;
        });
      });

      _descriptionController.clear();
      _amountController.clear();
      Navigator.of(context).pop();
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  double get _totalExpense {
    return _expenses.fold(0.0, (sum, item) => sum + item['amount']);
  }

  void _calculateIncome() {
    final income = double.tryParse(_incomeController.text);
    if (income != null && income >= 0) {
      setState(() {
        _income = income;
      });
    }
  }

  String _getBalanceStatus() {
    final balance = _income - _totalExpense;
    if (balance > 0) return 'Profit';
    if (balance < 0) return 'Loss';
    return 'Tally';
  }

  String _getBalanceAnimation() {
    final balance = _income - _totalExpense;
    if (balance > 0) return 'assets/profit.json';
    if (balance < 0) return 'assets/sad.json';
    return 'assets/tally.json';
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingAmount = _income - _totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Income Input
                TextField(
                  controller: _incomeController,
                  decoration: InputDecoration(
                    labelText: 'Enter your Income',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _calculateIncome,
                  child: Text('Set Income'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                ),
                SizedBox(height: 20),

                // Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Expense:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${_totalExpense.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining Amount:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${remainingAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: remainingAmount > 0
                            ? Colors.green
                            : remainingAmount < 0
                                ? Colors.red
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Lottie Animation for Status
                Lottie.asset(
                  _getBalanceAnimation(),
                  height: 150,
                  width: 150,
                  repeat: true,
                ),
                Divider(thickness: 1, height: 30),

                // Expense List
                Expanded(
                  child: _expenses.isEmpty
                      ? Center(
                          child: Text(
                            'No expenses added yet!',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _expenses.length,
                          itemBuilder: (ctx, index) {
                            final expense = _expenses[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(expense['description']),
                                subtitle: Text(
                                  '₹${expense['amount'].toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteExpense(index),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (_showMoneyAnimation)
            Center(
              child: Lottie.asset(
                'assets/money falling.json',
                height: 200,
                width: 200,
                repeat: false,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
