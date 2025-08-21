import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/src/auth/login_page.dart';
import 'dart:async';
import 'dart:io' show Platform; // Add this line
import 'package:flutter/foundation.dart'; // Add this line
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/src/serviceProvider/PoolingSystemPage.dart';

class PollResultsSection extends StatefulWidget {
  final String centerId;

  const PollResultsSection({
    super.key,
    required this.centerId,
  });

  @override
  State<PollResultsSection> createState() => _PollResultsSectionState();
}

class _PollResultsSectionState extends State<PollResultsSection> {
  List<dynamic> _pollItems = [];
  bool _isLoading = true;
  String _pollName = 'Current Poll';
  static const String _baseWebUrl = 'http://localhost:3000/api';
  static const String _baseAndroidUrl = 'http://10.0.2.2:3000/api';
  static const String _baseIOSUrl = 'http://127.0.0.1:3000/api';

  String get baseUrl {
    if (kIsWeb) return _baseWebUrl;
    if (Platform.isAndroid) return _baseAndroidUrl;
    if (Platform.isIOS) return _baseIOSUrl;
    return _baseWebUrl;
  }

  @override
  void initState() {
    super.initState();
    _fetchPollData();
  }

  Future<void> _fetchPollData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/poll/view?centerId=${widget.centerId}'),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (mounted) {
          setState(() {
            if (decodedData['data'] != null && decodedData['data'].isNotEmpty) {
              final pollData = decodedData['data'][0];
              _pollName = pollData['pollName'] ?? 'Current Poll';

              // Safely process items with default vote of 0
              _pollItems = (pollData['items'] as List? ?? [])
                  .map((item) => {
                        ...item,
                        'itemVote':
                            (item['itemVote'] as num?)?.toDouble() ?? 0.0
                      })
                  .toList();
            } else {
              _pollItems = [];
              _pollName = 'Current Poll';
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _pollItems = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching poll data: $e');
      if (mounted) {
        setState(() {
          _pollItems = [];
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPollOption(
      String itemName, double votes, double totalVotes, Color color) {
    final double percentage = totalVotes > 0 ? (votes / totalVotes) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              '${votes.toStringAsFixed(0)} votes (${percentage.toStringAsFixed(1)}%)',
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
              widthFactor: totalVotes > 0 ? votes / totalVotes : 0,
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

  Widget _buildContainerBox({required Widget child}) {
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
      child: child,
    );
  }

  Widget _buildNoActivePoll() {
    return _buildContainerBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.poll_outlined,
            size: 48,
            color: Color(0xFFFF6B00),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Active Poll',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B00),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are currently no active polls for this center',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildContainerBox(
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
          ),
        ),
      );
    }

    if (_pollItems.isEmpty) {
      return _buildNoActivePoll();
    }

    final totalVotes = _pollItems.fold(
        0.0, (sum, item) => sum + (item['itemVote'] as num).toDouble());

    final colors = [
      Colors.orange.shade400,
      Colors.orange.shade300,
      Colors.orange.shade200,
    ];

    return _buildContainerBox(
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

          // Poll Name
          Text(
            _pollName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Poll Options
          ...List.generate(_pollItems.length, (index) {
            final item = _pollItems[index];
            return Column(
              children: [
                _buildPollOption(
                  item['itemName'],
                  (item['itemVote'] as num).toDouble(),
                  totalVotes,
                  colors[index % colors.length],
                ),
                const SizedBox(height: 12),
              ],
            );
          }),

          const SizedBox(height: 12),

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
                  'Total Votes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  totalVotes.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceProviderHomePage extends StatefulWidget {
  final ICenterAccount userProfile; // Add this line

  const ServiceProviderHomePage({super.key, required this.userProfile});

  @override
  State<ServiceProviderHomePage> createState() =>
      _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState extends State<ServiceProviderHomePage> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  late PageController _bannerController;
  int _currentBannerIndex = 0;
  final int totalPages = 3; // Define the totalPages variable

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _bannerController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients && mounted) {
        int nextPage =
            (((_pageController.page?.toInt() ?? 0) + 1) % totalPages).toInt();
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _currentBannerIndex = (_currentBannerIndex + 1) % 2;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
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
    _pageController.dispose();
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
              const Icon(Icons.waving_hand, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Welcome ${widget.userProfile.centerName}', // Update this line
                style: const TextStyle(
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
    const totalVotes = 120 + 90 + 60;

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
                style: const TextStyle(
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
            PollResultsSection(centerId: widget.userProfile.centerId),
            _buildMessagesSection(),
            _buildShortcutButtons(),
          ],
        ),
      ),
    );
  }
}
