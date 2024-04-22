import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:saving_goals_app/database/savings.dart';
import 'package:saving_goals_app/models/saving_model.dart';
import 'package:saving_goals_app/pages/create_goals.dart';
import 'package:intl/intl.dart';

enum Actions { archive, delete }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class ItemController {
  final Function(BuildContext context) onArchive;
  final Function(BuildContext context) onDelete;

  ItemController({required this.onArchive, required this.onDelete});

  void handleArchive(BuildContext context) {
    onArchive(context);
  }

  void handleDelete(BuildContext context) {
    onDelete(context);
  }
}

class _HomePageState extends State<HomePage> {
  late DatabaseHelper handler;
  late Future<List<SavingModel>> goals;
  final db = DatabaseHelper();

  final title = TextEditingController();
  final total = TextEditingController();
  final deadline = TextEditingController();
  final saved = TextEditingController();

  final itemController = ItemController(
    onArchive: (context) {
      // Implement your archive logic here (e.g., update data model, call an API)
      print('Archiving item...');
    },
    onDelete: (context) {
      // Implement your delete logic here (e.g., remove from data model, call an API)
      print('Deleting item...');
    },
  );

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    goals = handler.getGoals();

    handler.initDB().then((_) {
      getAllGoals().then((goalList) {
        setState(() {
          goals = Future.value(goalList);
          totalAmountSaved = calculateTotalAmountSaved(goalList);
        });
      });
    });
  }

  double calculateTotalAmountSaved(List<SavingModel> goals) {
    return goals.fold<double>(
        0, (previousValue, element) => previousValue + element.amountSaved);
  }

  Future<List<SavingModel>> getAllGoals() {
    return handler.getGoals();
  }

  //refresh method
  Future<void> _refresh() async {
    setState(() {
      goals = getAllGoals();
      goals.then((goalList) {
        totalAmountSaved = calculateTotalAmountSaved(goalList);
      });
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String formatCurrency(int amount) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return currencyFormat.format(amount);
  }

  void onArchive(BuildContext context, int index) async {
    final database = await DatabaseHelper().initDB();

    try {
      // Mengubah status tujuan menjadi diarsipkan
      await database.update(
        'savings',
        {'isArchived': 1},
        where: "savingId = ?",
        whereArgs: [index],
      );

      print('Goal with ID $index archived successfully.');

      // Merefresh tampilan untuk memperbarui daftar tujuan
      _refresh();
    } catch (e) {
      print('Error archiving goal: $e');
    }
  }

  String calculateEstimation(SavingModel goal) {
    int remainingCost = goal.totalAmount - goal.amountSaved;
    String frequency = goal.frequency ?? '';
    int nominal = goal.nominal ?? 0;

    if (frequency == 'Daily') {
      int daysLeft = remainingCost ~/ nominal;
      return '$daysLeft day${daysLeft != 1 ? 's' : ''} left';
    } else if (frequency == 'Monthly') {
      int monthsLeft = remainingCost ~/ nominal;
      return '$monthsLeft month${monthsLeft != 1 ? 's' : ''} left';
    } else if (frequency == 'Yearly') {
      int yearsLeft = remainingCost ~/ nominal;
      return '$yearsLeft year${yearsLeft != 1 ? 's' : ''} left';
    } else {
      return 'Estimation not available';
    }
  }

  double totalAmountSaved = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SavingGoals',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGoal()),
          ).then((value) {
            if (value) {
              _refresh();
            }
          });
        },
        backgroundColor: Colors.blue.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: Colors.white, width: 3.0),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          _cardTotalAmount(),
          const SizedBox(
            height: 15,
          ),
          Container(
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Your goals",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SavingModel>>(
              future: goals,
              builder: (BuildContext context,
                  AsyncSnapshot<List<SavingModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No Data'),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  final items = snapshot.data ?? <SavingModel>[];
                  totalAmountSaved = calculateTotalAmountSaved(snapshot.data!);

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      // Periksa apakah tujuan tersebut diarsipkan
                      if (items[index].isArchived) {
                        // Jika diarsipkan, jangan tampilkan item tersebut
                        return const SizedBox.shrink();
                      }

                      // Jika tidak diarsipkan, tampilkan item tersebut
                      int remainingCost =
                          items[index].totalAmount - items[index].amountSaved;
                      String formattedDeadline =
                          formatDate(items[index].deadline);
                      String formattedCost =
                          formatCurrency(items[index].totalAmount);
                      String formattedSaved =
                          formatCurrency(items[index].amountSaved);
                      String formattedGap = formatCurrency(remainingCost);
                      String formattedEstimation =
                          calculateEstimation(items[index]);
                      String formattedFrequency =
                          items[index].frequency ?? 'Frequency not specified';

                      return Slidable(
                        startActionPane:
                            ActionPane(motion: const DrawerMotion(), children: [
                          SlidableAction(
                            icon: Icons.archive,
                            label: "Archive",
                            onPressed: (context) {
                              onArchive(context, items[index].savingId!);
                            },
                          ),
                          SlidableAction(
                            icon: Icons.delete,
                            label: "Delete",
                            onPressed: (context) {
                              onDelete(context, items[index].savingId!);
                              _refresh();
                            },
                          )
                        ]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                                title: Text(
                                  items[index].goalTitle,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Cost: $formattedCost",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Saved: $formattedSaved",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Cost Remaining: $formattedGap",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Deadline: $formattedDeadline",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Estimation: $formattedEstimation",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Frequency: $formattedFrequency",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Nominal Frequency: ${formatCurrency(items[index].nominal ?? 0)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    title.text = items[index].goalTitle;
                                    total.text =
                                        items[index].totalAmount.toString();
                                    deadline.text =
                                        items[index].deadline.toString();
                                    saved.text = ''.toString();
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          actions: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    db
                                                        .updateGoal(
                                                            title.text,
                                                            total.text,
                                                            deadline.text,
                                                            saved.text,
                                                            items[index]
                                                                .savingId)
                                                        .whenComplete(
                                                            () => _refresh());
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Update"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                              ],
                                            ),
                                          ],
                                          title: const Text("Update goal"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                controller: title,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Please enter a title of your goal";
                                                  }
                                                  return null;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        label: Text("Goal")),
                                              ),
                                              TextFormField(
                                                controller: total,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Please enter a title of your goal";
                                                  }
                                                  return null;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        label: Text("Cost")),
                                              ),
                                              TextFormField(
                                                controller: deadline,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Please enter a deadline of your goal";
                                                  }
                                                  return null;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        label:
                                                            Text("Deadline")),
                                              ),
                                              TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: saved,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Please enter the amount of money you want to save";
                                                  }
                                                  return null;
                                                },
                                                decoration: const InputDecoration(
                                                    hintText:
                                                        "Enter the amount of money you want to save",
                                                    label: Text("Saving")),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                }),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  AspectRatio _cardTotalAmount() {
    return AspectRatio(
      aspectRatio: 336 / 130,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade700,
              Colors.blue.shade600,
              Colors.blue.shade500,
              Colors.blue.shade400,
              Colors.blue.shade300,
              Colors.blue.shade200,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You've already saved:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                formatCurrency(totalAmountSaved.toInt()),
                style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void onDelete(BuildContext context, int index) async {
  final database = await DatabaseHelper().initDB();

  try {
    final deleteCount = await database.delete(
      'savings',
      where: "savingId = ?",
      whereArgs: [index],
    );

    if (deleteCount > 0) {
      print('Goal with ID $index deleted successfully.');
    } else {
      print('Error deleting goal: No item found with ID $index.');
    }
  } catch (e) {
    print('Error deleting goal: $e');
  }
}
