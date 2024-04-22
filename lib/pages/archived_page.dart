import 'package:flutter/material.dart';
import 'package:saving_goals_app/database/savings.dart';
import 'package:saving_goals_app/models/saving_model.dart';
import 'package:intl/intl.dart';

class ArchivedPage extends StatefulWidget {
  const ArchivedPage({Key? key}) : super(key: key);

  @override
  State<ArchivedPage> createState() => _ArchivedPageState();
}

class _ArchivedPageState extends State<ArchivedPage> {
  late Future<List<SavingModel>> _archivedGoals;

  @override
  void initState() {
    super.initState();
    _archivedGoals = _fetchArchivedGoals();
  }

  Future<List<SavingModel>> _fetchArchivedGoals() async {
    final List<SavingModel> archivedGoals = await DatabaseHelper().getArchivedGoals();
    return archivedGoals;
  }

  void _deleteGoal(int id) async {
    try {
      await DatabaseHelper().deleteGoal(id);
      // Perbarui tampilan setelah penghapusan
      setState(() {
        _archivedGoals = _fetchArchivedGoals();
      });
    } catch (e) {
      print('Error deleting goal: $e');
      // Tampilkan pesan kesalahan jika terjadi kesalahan saat menghapus
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting goal: $e'),
      ));
    }
  }

  void _restoreGoal(int id) async {
    try {
      await DatabaseHelper().restoreGoal(id);
      // Perbarui tampilan setelah mengembalikan
      setState(() {
        _archivedGoals = _fetchArchivedGoals();
      });
    } catch (e) {
      print('Error restoring goal: $e');
      // Tampilkan pesan kesalahan jika terjadi kesalahan saat mengembalikan
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error restoring goal: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ArchivedGoals',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: FutureBuilder<List<SavingModel>>(
        future: _archivedGoals,
        builder: (BuildContext context, AsyncSnapshot<List<SavingModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No archived goals.'));
          } else {
            final List<SavingModel> archivedGoals = snapshot.data!;
            return ListView.builder(
              itemCount: archivedGoals.length,
              itemBuilder: (BuildContext context, int index) {
                final SavingModel goal = archivedGoals[index];
                final String formattedDeadline = DateFormat('dd MMMM yyyy').format(goal.deadline);
                final int remainingCost = goal.totalAmount - goal.amountSaved;
                final String formattedCost = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(goal.totalAmount);
                final String formattedSaved = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(goal.amountSaved);
                final String formattedGap = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(remainingCost);

                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20.0),
                    child: const Icon(
                      Icons.unarchive,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Konfirmasi penghapusan
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text("Are you sure you want to restore this goal?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("Restore"),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (direction == DismissDirection.startToEnd) {
                      // Konfirmasi mengembalikan
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text("Are you sure you want to delete this goal?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _restoreGoal(goal.savingId!);
                    } else if (direction == DismissDirection.startToEnd) {
                      _deleteGoal(goal.savingId!);
                    }
                  },
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
                          goal.goalTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cost: $formattedCost',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Saved: $formattedSaved',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Cost Remaining: $formattedGap',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Deadline: $formattedDeadline',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
