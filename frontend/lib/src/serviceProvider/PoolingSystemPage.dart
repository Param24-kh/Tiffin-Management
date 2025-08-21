import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PollSystem extends StatefulWidget {
  final String centerId;

  const PollSystem({super.key, required this.centerId});

  @override
  _PollSystemState createState() => _PollSystemState();
}

class _PollSystemState extends State<PollSystem> {
  List<dynamic> polls = [];
  bool isLoading = true;
  final TextEditingController _pollNameController = TextEditingController();
  final TextEditingController _pollItemController = TextEditingController();
  final TextEditingController _updatePollNameController =
      TextEditingController();
  final TextEditingController _updateItemNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPolls();
  }

  @override
  void dispose() {
    _pollNameController.dispose();
    _pollItemController.dispose();
    _updatePollNameController.dispose();
    _updateItemNameController.dispose();
    super.dispose();
  }

  static const String _baseWebUrl = 'http://localhost:3000/api';
  static const String _baseAndroidUrl = 'http://10.0.2.2:3000/api';
  static const String _baseIOSUrl = 'http://127.0.0.1:3000/api';

  String get baseUrl {
    if (kIsWeb) return _baseWebUrl;
    if (Platform.isAndroid) return _baseAndroidUrl;
    if (Platform.isIOS) return _baseIOSUrl;
    return _baseWebUrl;
  }

  Future<void> _fetchPolls() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/poll/view?centerId=${widget.centerId}'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (!mounted) return;
        final responseData = json.decode(response.body);
        setState(() {
          polls = responseData['poll'] ?? responseData['data'] ?? [];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        _showErrorDialog('Failed to fetch polls: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Network error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deletePoll(String pollId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/poll/delete?centerId=${widget.centerId}&pollId=$pollId'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _fetchPolls(); // Refresh data from server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll deleted successfully')),
        );
      } else {
        _showErrorDialog('Failed to delete poll: ${response.statusCode}');
        await _fetchPolls(); // Refresh to ensure UI matches server state
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Network error: $e');
      await _fetchPolls(); // Refresh to ensure UI matches server state
    }
  }

  Future<void> _deleteItem(String pollId, String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/poll/deleteItem?centerId=${widget.centerId}&pollId=$pollId&itemId=$itemId'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _fetchPolls(); // Refresh data from server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      } else {
        _showErrorDialog('Failed to delete item: ${response.statusCode}');
        await _fetchPolls(); // Refresh to ensure UI matches server state
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Network error: $e');
      await _fetchPolls(); // Refresh to ensure UI matches server state
    }
  }

  Future<void> _updatePollName(String pollId, String newName) async {
    if (newName.trim().isEmpty) {
      _showErrorDialog('Poll name cannot be empty');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/poll/update?centerId=${widget.centerId}&pollId=$pollId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pollName': newName.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _updatePollNameController.clear();
        await _fetchPolls(); // Refresh data from server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll updated successfully')),
        );
      } else {
        _showErrorDialog('Failed to update poll: ${response.statusCode}');
        await _fetchPolls(); // Refresh to ensure UI matches server state
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Network error: $e');
      await _fetchPolls(); // Refresh to ensure UI matches server state
    }
  }

  Future<void> _updateItem(String pollId, String itemId, String newName) async {
    if (newName.trim().isEmpty) {
      _showErrorDialog('Item name cannot be empty');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/poll/updateItem?centerId=${widget.centerId}&pollId=$pollId&itemId=$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'itemName': newName.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _updateItemNameController.clear();
        await _fetchPolls(); // Refresh data from server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully')),
        );
      } else {
        _showErrorDialog('Failed to update item: ${response.statusCode}');
        await _fetchPolls(); // Refresh to ensure UI matches server state
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Network error: $e');
      await _fetchPolls(); // Refresh to ensure UI matches server state
    }
  }

  void _showUpdatePollDialog(dynamic poll) {
    _updatePollNameController.text = poll['pollName'] ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Poll Name'),
        content: TextField(
          controller: _updatePollNameController,
          decoration: const InputDecoration(
            hintText: 'Enter New Poll Name',
            labelText: 'Poll Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updatePollName(poll['pollId'], _updatePollNameController.text);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdateItemDialog(String pollId, dynamic item) {
    _updateItemNameController.text = item['itemName'] ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Item Name'),
        content: TextField(
          controller: _updateItemNameController,
          decoration: const InputDecoration(
            hintText: 'Enter New Item Name',
            labelText: 'Item Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateItem(
                  pollId, item['itemId'], _updateItemNameController.text);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String pollId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Poll'),
        content: const Text('Are you sure you want to delete this poll?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePoll(pollId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _createPoll() async {
    if (_pollNameController.text.trim().isEmpty) {
      _showErrorDialog('Poll name cannot be empty');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/poll/create?centerId=${widget.centerId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pollName': _pollNameController.text.trim(),
          'centerName': _pollNameController.text.trim(),
          'items': []
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        _pollNameController.clear();
        await _fetchPolls(); // Refresh data from server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll created successfully')),
        );
      } else if (response.statusCode == 400) {
        _showErrorDialog('Poll already exists for this center');
      } else {
        _showErrorDialog('Failed to create poll: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _addPollItem(String pollId) async {
    if (_pollItemController.text.trim().isEmpty) {
      _showErrorDialog('Item name cannot be empty');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/poll/addItem?centerId=${widget.centerId}&pollId=$pollId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': _pollItemController.text.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _pollItemController.clear();
        await _fetchPolls(); // Refresh data from server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully')),
        );
      } else {
        _showErrorDialog('Failed to add poll item: ${response.statusCode}');
        await _fetchPolls(); // Refresh to ensure UI matches server state
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Network error: $e');
      await _fetchPolls(); // Refresh to ensure UI matches server state
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCreatePollDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Poll'),
        content: TextField(
          controller: _pollNameController,
          decoration: const InputDecoration(
            hintText: 'Enter Poll Name',
            labelText: 'Poll Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createPoll();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(String pollId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Poll Item'),
        content: TextField(
          controller: _pollItemController,
          decoration: const InputDecoration(
            hintText: 'Enter Item Name',
            labelText: 'Item Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addPollItem(pollId);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Management'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPolls,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePollDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPolls,
              child: polls.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('No Polls Created'),
                                ElevatedButton(
                                  onPressed: _showCreatePollDialog,
                                  child: const Text('Create First Poll'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: polls.length,
                      itemBuilder: (context, index) {
                        var poll = polls[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ExpansionTile(
                            title: Text(
                              poll['pollName'] ?? 'Unnamed Poll',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                'Center: ${poll['centerName'] ?? 'No Center'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _showUpdatePollDialog(poll),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteConfirmation(poll['pollId']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.orange),
                                  onPressed: () =>
                                      _showAddItemDialog(poll['pollId']),
                                ),
                              ],
                            ),
                            children: [
                              if (poll['items'] != null &&
                                  poll['items'].isNotEmpty)
                                ...poll['items'].map<Widget>((item) => ListTile(
                                      title: Text(
                                          item['itemName'] ?? 'Unnamed Item'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Rating: ${item['itemVote'] ?? 0}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                _showUpdateItemDialog(
                                                    poll['pollId'], item),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _deleteItem(
                                                poll['pollId'], item['itemId']),
                                          ),
                                        ],
                                      ),
                                    ))
                              else
                                const ListTile(
                                  title: Text('No items in this poll'),
                                  subtitle:
                                      Text('Add items using the + button'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
