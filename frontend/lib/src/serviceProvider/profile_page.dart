import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart'; // Import the file with ICenterAccount definition

class ServiceProviderProfilePage extends StatefulWidget {
  final ICenterAccount userProfile;

  const ServiceProviderProfilePage({Key? key, required this.userProfile})
      : super(key: key);

  @override
  _ServiceProviderProfilePageState createState() =>
      _ServiceProviderProfilePageState();
}

class _ServiceProviderProfilePageState
    extends State<ServiceProviderProfilePage> {
  late ICenterAccount _userProfile;
  bool _isEditing = false;

  // Editing controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _centerNameController;
  late TextEditingController _centerAddressController;

  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: _userProfile.centerName);
    _phoneController = TextEditingController(text: _userProfile.phoneNumber);
    _centerNameController =
        TextEditingController(text: _userProfile.centerName);
    _centerAddressController =
        TextEditingController(text: _userProfile.address);
  }

  Future<void> _updateProfile() async {
    try {
      // TODO: Implement actual backend update logic
      setState(() {
        _userProfile = ICenterAccount(
          centerId: _userProfile.centerId,
          centerName: _centerNameController.text,
          phoneNumber: _phoneController.text,
          centerUserName: _userProfile.centerUserName,
          auth: _userProfile.auth,
          address: _centerAddressController.text,
          centerFeedback: _userProfile.centerFeedback,
          centerRating: _userProfile.centerRating,
        );
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
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
      // Clear SharedPreferences and navigate to login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(),
              if (!_isEditing)
                _buildMenuItem(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  iconColor: Colors.orange,
                  onTap: () => setState(() {
                    _initControllers();
                    _isEditing = true;
                  }),
                )
              else
                _buildEditProfileForm(),

              // Center Details Section
              _buildCenterDetailsSection(),

              // Service Statistics (placeholder)
              _buildServiceStatisticsSection(),

              // Other menu items
              ..._buildOtherMenuItems(),

              const SizedBox(height: 20),
              _buildLogoutButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.business, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _userProfile.centerName.isNotEmpty
              ? _userProfile.centerName
              : 'Service Provider Name',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          _userProfile.auth.email,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEditProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _centerNameController,
            decoration: InputDecoration(
              labelText: 'Center Name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _centerAddressController,
            decoration: InputDecoration(
              labelText: 'Center Address',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() {
                  _isEditing = false;
                }),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterDetailsSection() {
    return ExpansionTile(
      title: const Text('Center Details'),
      children: [
        ListTile(
          title: const Text('Center Name'),
          subtitle: Text(_userProfile.centerName ?? 'Not specified'),
        ),
        ListTile(
          title: const Text('Center Address'),
          subtitle: Text(_userProfile.address ?? 'Not specified'),
        ),
        ListTile(
          title: const Text('Operational Status'),
          subtitle: Text(_userProfile.centerRating?.toString() ?? 'Active'),
        ),
      ],
    );
  }

  Widget _buildServiceStatisticsSection() {
    return ExpansionTile(
      title: const Text('Service Statistics'),
      children: [
        ListTile(
          title: const Text('Active Subscriptions'),
          subtitle: Text('0'), // Placeholder value or replace with actual field
        ),
        ListTile(
          title: const Text('Monthly Revenue'),
          subtitle: Text(_userProfile.centerFeedback?.toString() ?? 'N/A'),
        ),
      ],
    );
  }

  List<Widget> _buildOtherMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.assignment_outlined,
        title: 'My Services',
        iconColor: Colors.blue,
        onTap: () {},
      ),
      _buildMenuItem(
        icon: Icons.analytics_outlined,
        title: 'Performance Analytics',
        iconColor: Colors.green,
        onTap: () {},
      ),
      _buildMenuItem(
        icon: Icons.payment_outlined,
        title: 'Payment Details',
        iconColor: Colors.purple,
        onTap: () {},
      ),
      _buildMenuItem(
        icon: Icons.feedback_outlined,
        title: 'Customer Feedback',
        iconColor: Colors.orange,
        onTap: () {},
      ),
      _buildMenuItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        iconColor: Colors.grey,
        onTap: () {},
      ),
      _buildMenuItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        iconColor: Colors.blue,
        onTap: () {},
      ),
    ];
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Log out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
