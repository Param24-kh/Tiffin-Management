import 'package:flutter/material.dart';
import 'home_page.dart';
import 'PoolingSystemPage.dart';
import 'profile_page.dart';
import 'services_page.dart';

class MainWrapperService extends StatefulWidget {
  const MainWrapperService({Key? key}) : super(key: key);

  @override
  State<MainWrapperService> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapperService> {
  int _selectedIndex = 0;

  // Pages in the order they appear in bottom nav
  final List<Widget> _pages = [
    const ServiceProviderHomePage(),
    const PollSystem(),
    const TiffinServicePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6B00),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: 'Poll',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
