import 'package:flutter/material.dart';
import 'package:saving_goals_app/pages/archived_page.dart';
import 'package:saving_goals_app/pages/home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTab = 0;
  List<Widget> screens = [
    const HomePage(),
    const ArchivedPage(),
  ];
  Color onPressed = Colors.blue.shade700;
  Color notPressed = Colors.grey;
  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  Widget currentScreen = const HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      currentScreen = screens[0];
                      currentTab = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: currentTab == 0 ? onPressed : notPressed,
                        size: 20,
                      ),
                      Text(
                        'Home',
                        style: TextStyle(
                            color: currentTab == 0 ? onPressed : notPressed,
                            fontSize: 11),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      currentScreen = screens[1];
                      currentTab = 1;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive_outlined,
                          color: currentTab == 1 ? onPressed : notPressed,
                          size: 20),
                      Text(
                        'Archived',
                        style: TextStyle(
                            color: currentTab == 1 ? onPressed : notPressed,
                            fontSize: 11),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white70.withOpacity(0.95),
      body: PageStorage(
        bucket: pageStorageBucket,
        child: currentScreen,
      ),
    );
  }
}
