import 'package:path/path.dart';
import 'package:saving_goals_app/models/saving_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "savings.db";
  String savingsTable =
      "CREATE TABLE savings (savingId INTEGER PRIMARY KEY AUTOINCREMENT, goalTitle TEXT NOT NULL, totalAmount INTEGER NOT NULL, deadline TEXT NOT NULL, amountSaved INTEGER NOT NULL, frequency TEXT NOT NULL, nominal INTEGER NOT NULL, isArchived INTEGER NOT NULL DEFAULT 0)";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(savingsTable);
      },
    );
  }

  //create goal
  Future<int> createGoal(SavingModel saveModel) async {
    final Database db = await initDB();
    return await db.insert(
      'savings',
      saveModel.toMap(),
    );
  }

  //get goal
  Future<List<SavingModel>> getGoals() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('savings', where: "isArchived = ?", whereArgs: [0]);
    return result.map((e) => SavingModel.fromMap(e)).toList();
  }

  //delete goal
  Future<int> deleteGoal(int id) async {
    final Database db = await initDB();
    return await db.delete(
      'savings',
      where: "savingId =?",
      whereArgs: [id],
    );
  }

  //update goal
  Future<int> updateGoal(title, total, deadline, saved, savingId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        "UPDATE savings SET goalTitle =?, totalAmount =?, deadline =?, amountSaved =? WHERE savingId =?",
        [title, total, deadline, saved, savingId]);
  }

  Future<int> archiveGoal(int id) async {
    final Database db = await initDB();
    return await db.rawUpdate(
      "UPDATE savings SET isArchived = 1 WHERE savingId = ?",
      [id],
    );
  }

  Future<List<SavingModel>> getArchivedGoals() async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result = await db.query(
      'savings',
      where: "isArchived = ?",
      whereArgs: [1],
    );
    return result.map((e) => SavingModel.fromMap(e)).toList();
  }

  Future<void> restoreGoal(int id) async {
    final Database db = await initDB();
    await db.update(
      'savings',
      {'isArchived': 0},
      where: "savingId = ?",
      whereArgs: [id],
    );
  }
}
