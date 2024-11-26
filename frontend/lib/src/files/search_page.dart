import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import './searchPage/SearchResultCard_page.dart';
import './searchPage/serviceProvider_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  List<ServiceProvider> _serviceProviders = [];
  List<ServiceProvider> _filteredServiceProviders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Network URLs for different platforms
  static const String _baseWebUrl = 'http://localhost:3000/api';
  static const String _baseAndroidUrl = 'http://10.0.2.2:3000/api';
  static const String _baseIOSUrl = 'http://127.0.0.1:3000/api';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchServiceProviders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dynamic base URL based on platform
  String get baseUrl {
    if (kIsWeb) return _baseWebUrl;
    if (Platform.isAndroid) return _baseAndroidUrl;
    if (Platform.isIOS) return _baseIOSUrl;
    return _baseWebUrl;
  }

  // Fetch service providers from backend
  Future<void> _fetchServiceProviders() async {
    // Defensive check to prevent multiple simultaneous calls
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await http.get(
        Uri.parse('$baseUrl/auth/search'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(response.body)['serviceProviders'];

        // Defensive null check and conversion
        final providers = data
            .map((e) => e != null ? ServiceProvider.fromJson(e) : null)
            .whereType<ServiceProvider>()
            .toList();

        if (mounted) {
          setState(() {
            _serviceProviders = providers;
            _filteredServiceProviders = providers;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Failed to load service providers: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Search and filter service providers
  void _searchServiceProviders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredServiceProviders = _serviceProviders;
      } else {
        _filteredServiceProviders = _serviceProviders.where((provider) {
          final searchTerms = [
            provider.centerName.toLowerCase(),
            provider.description?.toLowerCase() ?? '',
            provider.location?.toLowerCase() ?? '',
          ];
          return searchTerms.any((term) => term.contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiffin Service Search'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSearchBar(
              controller: _searchController,
              onChanged: _searchServiceProviders,
              onClear: () {
                _searchController.clear();
                _searchServiceProviders('');
              },
            ),
            const SizedBox(height: 16.0),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const Text(
              'Tiffin Service Providers',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                  : _filteredServiceProviders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 100, color: Colors.orange.shade300),
                              Text(
                                'No matching service providers found',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredServiceProviders.length,
                          itemBuilder: (context, index) {
                            final provider = _filteredServiceProviders[index];
                            return SearchResultCard(provider: provider);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Search Bar Widget
class AnimatedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const AnimatedSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search tiffin services...',
          hintStyle: TextStyle(color: Colors.orange.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.orange.shade600),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.orange.shade600),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        onChanged: onChanged,
        style: TextStyle(color: Colors.orange.shade800),
      ),
    );
  }
}
