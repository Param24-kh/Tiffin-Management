import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'serviceProvider_page.dart';

class ServiceProviderDetailsPopup extends StatelessWidget {
  final ServiceProvider provider;

  const ServiceProviderDetailsPopup({Key? key, required this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.orange.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Center Name
              Center(
                child: Text(
                  provider.centerName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Detailed Information Sections
              _buildInfoSection(
                title: 'Description',
                content: provider.description ?? 'No description available',
                icon: Icons.description,
              ),

              _buildInfoSection(
                title: 'Pricing',
                content: '\$${provider.price?.toStringAsFixed(2) ?? 'N/A'}',
                icon: Icons.attach_money,
              ),

              // Additional Details (you can expand these)
              _buildInfoSection(
                title: 'Location',
                content: provider.location ?? 'Location not specified',
                icon: Icons.location_on,
              ),

              _buildInfoSection(
                title: 'Contact',
                content: provider.contactNumber ?? 'Contact not available',
                icon: Icons.phone,
              ),

              const SizedBox(height: 20),

              // Subscribe Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement subscription logic
                    _showSubscriptionConfirmation(context);
                  },
                  icon: Icon(Icons.subscriptions, color: Colors.white),
                  label: Text(
                    'Subscribe to Service',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              // Close Button
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable method to build info sections
  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange.shade600, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Subscription Confirmation Dialog
  void _showSubscriptionConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Subscription',
              style: TextStyle(color: Colors.orange.shade800)),
          content: Text(
              'Are you sure you want to subscribe to ${provider.centerName}?'),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
              ),
              child: Text('Confirm', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // TODO: Implement actual subscription logic
                Navigator.of(context).pop();
                _showSubscriptionSuccess(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Subscription Success Dialog
  void _showSubscriptionSuccess(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 80),
                SizedBox(height: 20),
                Text(
                  'Subscription Successful!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800),
                ),
                SizedBox(height: 10),
                Text(
                  'You have subscribed to ${provider.centerName}.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                child:
                    Text('OK', style: TextStyle(color: Colors.orange.shade700)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }
}
