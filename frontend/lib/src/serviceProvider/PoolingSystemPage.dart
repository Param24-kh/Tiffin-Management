import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart' as Lucide;
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PollSystem extends StatefulWidget {
  final String centerId;

  const PollSystem({Key? key, required this.centerId}) : super(key: key);

  @override
  _PollSystemState createState() => _PollSystemState();
}

class _PollSystemState extends State<PollSystem> {
  List<dynamic> polls = [];
  bool isLoading = true;
  final TextEditingController _pollNameController = TextEditingController();
  final TextEditingController _pollItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPolls();
  }

  Future<void> _fetchPolls() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/api/poll/view?centerId=${widget.centerId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          polls = json.decode(response.body)['poll'];
          isLoading = false;
        });
      } else {
        _showErrorDialog('Failed to fetch polls');
      }
    } catch (e) {
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _createPoll() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/api/poll/create?centerId=${widget.centerId}'),
        headers: {'Content-Type': 'application/json'},
        body: '{"name": "${_pollNameController.text}"}',
      );

      if (response.statusCode == 201) {
        _pollNameController.clear();
        _fetchPolls();
      } else if (response.statusCode == 400) {
        _showErrorDialog('Poll already exists');
      } else if (response.statusCode == 404) {
        _showErrorDialog('Center not found');
      } else {
        _showErrorDialog('Failed to create poll');
      }
    } catch (e) {
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _addPollItem(String pollId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/api/poll/addItem?centerId=${widget.centerId}&pollId=$pollId'),
        body: {'name': _pollItemController.text},
      );

      if (response.statusCode == 200) {
        _pollItemController.clear();
        _fetchPolls();
      } else {
        _showErrorDialog('Failed to add poll item');
      }
    } catch (e) {
      _showErrorDialog('Network error: $e');
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
            icon: const Icon(Icons.add),
            onPressed: _showCreatePollDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : polls.isEmpty
              ? Center(
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
                )
              : ListView.builder(
                  itemCount: polls.length,
                  itemBuilder: (context, index) {
                    var poll = polls[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text(
                          poll['centerName'] ?? 'Unnamed Poll',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add, color: Colors.orange),
                          onPressed: () => _showAddItemDialog(poll['pollId']),
                        ),
                        children: [
                          if (poll['items'] != null)
                            ...poll['items'].map<Widget>((item) => ListTile(
                                  title:
                                      Text(item['itemName'] ?? 'Unnamed Item'),
                                  subtitle: Text(
                                      'Rating: ${item['itemRating'] ?? 0}'),
                                )),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
