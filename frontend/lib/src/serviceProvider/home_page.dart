import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/src/auth/login_page.dart';
import 'dart:async';

import 'package:frontend/src/serviceProvider/PoolingSystemPage.dart';

class PollResultsSection extends StatelessWidget {
  const PollResultsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Poll Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B00),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Poll Question
          const Text(
            'People voted for their favorite cuisine.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Poll Options
          _buildPollOption('North Indian', 120, 270, Colors.orange.shade400),
          const SizedBox(height: 12),
          _buildPollOption('South Indian', 90, 270, Colors.orange.shade300),
          const SizedBox(height: 12),
          _buildPollOption('Continental', 60, 270, Colors.orange.shade200),

          const SizedBox(height: 24),

          // Total Participants
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Participants',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Text(
                  '270',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B00),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Poll Duration
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Poll ends in 2 hours',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollOption(String option, int votes, int total, Color color) {
    final percentage = (votes / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              option,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            Text(
              '$votes votes ($percentage%)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: votes / total,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ServiceProviderHomePage extends StatefulWidget {
  final ICenterAccount userProfile; // Add this line

  const ServiceProviderHomePage({Key? key, required this.userProfile})
      : super(key: key);

  @override
  State<ServiceProviderHomePage> createState() =>
      _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState extends State<ServiceProviderHomePage> {
  late PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final nextPage = (_currentBannerIndex + 1) % 2;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Widget _buildWelcomeBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waving_hand, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Welcome ${widget.userProfile.centerName}', // Update this line
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Manage your services, track polls, and stay updated with customer preferences.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPollResultsCard() {
    // Total votes calculation
    final totalVotes = 120 + 90 + 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Food Poll Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B00),
            ),
          ),
          const SizedBox(height: 16),
          _buildPollResultListItem(
            'North Indian',
            120,
            totalVotes,
            Colors.orange.shade400,
          ),
          _buildPollResultListItem(
            'South Indian',
            90,
            totalVotes,
            Colors.orange.shade300,
          ),
          _buildPollResultListItem(
            'Continental',
            60,
            totalVotes,
            Colors.orange.shade200,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Participants',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$totalVotes',
                style: TextStyle(
                  color: Color(0xFFFF6B00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollResultListItem(
      String option, int votes, int totalVotes, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              option,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: votes / totalVotes,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$votes votes',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Messages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFFFF6B00)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMessageItem('John Doe', 'Can we modify tomorrow\'s menu?'),
          _buildMessageItem('Jane Smith', 'Regarding subscription renewal'),
        ],
      ),
    );
  }

  Widget _buildMessageItem(String sender, String preview) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFF6B00),
            radius: 20,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  preview,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButtons() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildShortcutButton(
            'Employee Management \n (coming soon)',
            Icons.people,
            () {},
          ),
          _buildShortcutButton(
            'Create New Poll',
            Icons.poll,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PollSystem(centerId: widget.userProfile.centerId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF6B00),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const PollResultsSection(),
            _buildMessagesSection(),
            _buildShortcutButtons(),
          ],
        ),
      ),
    );
  }
}
