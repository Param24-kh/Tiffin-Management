import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import 'home_page.dart';
import './PoolingSystemPage.dart';
import 'package:frontend/src/serviceProvider/profile_page.dart';
import './services_page.dart';

class MainWrapperService extends StatefulWidget {
  final ICenterAccount userProfile;
  final String? userToken;

  const MainWrapperService(
      {Key? key, required this.userProfile, this.userToken})
      : super(key: key);

  @override
  State<MainWrapperService> createState() => _MainWrapperServiceState();
}

class _MainWrapperServiceState extends State<MainWrapperService> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ServiceProviderHomePage(userProfile: widget.userProfile),
      PollSystem(centerId: widget.userProfile.centerId),
      TiffinServicePage(
        centerId: widget.userProfile.centerId,
      ),
      ServiceProviderProfilePage(userProfile: widget.userProfile)
    ];
  }

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
