import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saving_goals_app/database/savings.dart';
import 'package:saving_goals_app/models/saving_model.dart';

class CreateGoal extends StatefulWidget {
  const CreateGoal({Key? key}) : super(key: key);

  @override
  State<CreateGoal> createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
  final title = TextEditingController();
  final total = TextEditingController();
  final deadline = TextEditingController();
  final frequency = TextEditingController();
  final nominal = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final db = DatabaseHelper();

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        deadline.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
  }

  String frequencyValue = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Goal"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                controller: title,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a title of your goal";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Goal",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: total,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a cost of your goal";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Cost",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: frequencyValue,
                      onChanged: (newValue) {
                        setState(() {
                          frequencyValue = newValue!;
                        });
                      },
                      items: <String>['Daily', 'Monthly', 'Yearly']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "Frequency",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: nominal,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter the saving nominal";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Nominal",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Deadline',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      icon: const Icon(Icons.calendar_today),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                    child: TextFormField(
                      controller: deadline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please select a deadline for your goal";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Membuat objek SavingModel dan menyimpannya ke dalam database
                    db
                        .createGoal(SavingModel(
                          goalTitle: title.text,
                          totalAmount: int.parse(total.text),
                          deadline: _selectedDate!,
                          amountSaved: 0,
                          frequency: frequencyValue,
                          nominal: int.parse(nominal.text),
                        ))
                        .whenComplete(() => Navigator.of(context).pop(true));
                  }
                },
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}