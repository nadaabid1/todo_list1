// ignore_for_file: avoid_print,, unnecessary_string_interpolations, curly_braces_in_flow_control_structures, body_might_complete_normally_nullable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_list/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_list/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_list/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database? database;
  List<Map> newtasks = [];
  List<Map> donetasks = [];
  List<Map> archivetasks = [];
  void createDatabase() async {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('databse created');
        database
            .execute(
                'create table tasks( id INTEGER PRIMARY KEY , title TEXT , date TEXT , time TEXT , status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print("error when creating table${error.toString()}");
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title,date,time,status) Values ("$title","$date","$time","NEW")')
          .then((value) {
        print('$value inserted successfully');

        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      }).catchError((error) {
        print('error when inserting new record ${error.toString()}');
      });
    });
  }

  void getDataFromDatabase(database) {
    newtasks = [];
    donetasks = [];
    archivetasks = [];
    emit(AppGetDatabaseLoadingState());
    database.rawQuery('select * From tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newtasks.add(element);
        else if (element['status'] == 'done')
          donetasks.add(element);
        else
          archivetasks.add(element);
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    database!.rawUpdate('UPDATE tasks SET status = ?, WHERE id = ?',
        ['$status', '$id'],).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  }) async {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }
}
