import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/login_page.dart'; // Import the interfaces

class ProfilePage extends StatefulWidget {
  final IAccount userProfile;

  const ProfilePage({Key? key, required this.userProfile}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late IAccount _userProfile;
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: _userProfile.name);
    _phoneController = TextEditingController(text: _userProfile.phoneNumber);
    _addressController = TextEditingController(text: _userProfile.address);
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _userProfile.auth.email,
          'passkey': _userProfile.auth.passkey,
          'Name': _nameController.text,
          'phoneNumber': _phoneController.text,
          'address': _addressController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        setState(() {
          _userProfile = IAccount(
            centerId: _userProfile.centerId,
            name: _nameController.text,
            phoneNumber: _phoneController.text,
            userName: _userProfile.userName,
            auth: _userProfile.auth,
            address: _addressController.text,
            paymentMethod: _userProfile.paymentMethod,
            previouslyRegisteredCenters:
                _userProfile.previouslyRegisteredCenters,
            activeSubscriptions: _userProfile.activeSubscriptions,
            previousSubscriptions: _userProfile.previousSubscriptions,
          );
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  responseBody['message'] ?? 'Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseBody['message'] ?? 'Error updating profile')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleLogout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(
            'userToken'); // Remove specific token instead of clearing all
        await prefs.remove('userEmail');

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        print('Logout error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              _isEditing ? _buildEditProfileForm() : _buildProfileActions(),
              _buildSubscriptionSection(),
              ..._buildOtherMenuItems(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.orange,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          _userProfile.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          _userProfile.auth.email,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildEditProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Save'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _isEditing = true),
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    return ExpansionTile(
      title: const Text('Subscriptions & Centers'),
      children: [
        ListTile(
          title: const Text('Active Subscriptions'),
          subtitle: Text(_userProfile.activeSubscriptions.join(', ')),
        ),
        ListTile(
          title: const Text('Previously Registered Centers'),
          subtitle: Text(_userProfile.previouslyRegisteredCenters.join(', ')),
        ),
      ],
    );
  }

  List<Widget> _buildOtherMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.shopping_bag_outlined,
        title: 'My Orders',
        onTap: () {},
      ),
      _buildMenuItem(
        icon: Icons.location_on_outlined,
        title: 'Delivery Address',
        onTap: () {},
      ),
      _buildMenuItem(
        icon: Icons.payment_outlined,
        title: 'Payment Methods',
        onTap: () {},
      ),
    ];
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _handleLogout,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Logout'),
    );
  }
}
