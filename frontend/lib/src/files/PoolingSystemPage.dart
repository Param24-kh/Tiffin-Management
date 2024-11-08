import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart' as Lucide;
import 'dart:math';

class PollSystem extends StatefulWidget {
  const PollSystem({Key? key}) : super(key: key);
  @override
  _PollSystemState createState() => _PollSystemState();
}

class _PollSystemState extends State<PollSystem> {
  Map<String, Map<String, int>> voteCount = {
    'Service Provider A': {
      'Vegetarian Delight': 0,
      'Mediterranean Mix': 0,
      'Asian Fusion': 0,
    },
    'Service Provider B': {
      'Salad Bar': 0,
      'Burgers': 0,
      'Sushi': 0,
    },
    'Service Provider C': {
      'Pizza': 0,
      'Pasta': 0,
      'Sandwiches': 0,
    },
  };

  Map<String, String?> selectedOptions = {
    'Service Provider A': null,
    'Service Provider B': null,
    'Service Provider C': null,
  };

  bool showAlert = false;
  String? alertMessage;

  void handleVote(String serviceProvider, String option, bool interested) {
    setState(() {
      if (selectedOptions[serviceProvider] == null && interested) {
        selectedOptions[serviceProvider] = option;
        voteCount[serviceProvider]?[option] =
            (voteCount[serviceProvider]?[option] ?? 0) + 1;
      } else if (selectedOptions[serviceProvider] == option && !interested) {
        selectedOptions[serviceProvider] = null;
        voteCount[serviceProvider]?[option] =
            (voteCount[serviceProvider]?[option] ?? 0) - 1;
      } else {
        showAlert = true;
        alertMessage =
            'You have already voted for this service provider. You cannot vote multiple times.';
      }
      submitVote(serviceProvider, option, interested);
    });
  }

  void clearVote(String serviceProvider) {
    setState(() {
      selectedOptions[serviceProvider] = null;
      voteCount[serviceProvider]?.forEach((key, value) {
        voteCount[serviceProvider]?[key] = 0;
      });
    });
  }

  void submitVote(String serviceProvider, String option, bool interested) {
    // TODO: Connect to backend and submit the vote
    print(
        'Submitted vote for "$option" from "$serviceProvider" with interested = $interested');
  }

  double getProgressWidth(String serviceProvider, String option) {
    int maxVotes = voteCount[serviceProvider]?.values.reduce(max) ?? 0;
    int votes = voteCount[serviceProvider]?[option] ?? 0;
    return maxVotes == 0 ? 0 : (votes / maxVotes) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomorrow\'s Lunch Poll'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your preferred lunch options from each service provider',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...voteCount.entries.map((serviceProvider) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceProvider.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...serviceProvider.value.entries.map((option) =>
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Lucide.LucideIcons.utensils,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            option.key,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Lucide.LucideIcons.users,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${option.value} votes',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: getProgressWidth(
                                            serviceProvider.key, option.key) /
                                        100,
                                    backgroundColor:
                                        Colors.orange.withOpacity(0.2),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.orange),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Lucide.LucideIcons.check,
                                          color: selectedOptions[
                                                      serviceProvider.key] ==
                                                  option.key
                                              ? Colors.orange
                                              : Colors.grey,
                                          size: 18,
                                        ),
                                        onPressed: selectedOptions[
                                                    serviceProvider.key] ==
                                                null
                                            ? () => handleVote(
                                                serviceProvider.key,
                                                option.key,
                                                true)
                                            : null,
                                        disabledColor: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: Icon(
                                          Lucide.LucideIcons.x,
                                          color: selectedOptions[
                                                      serviceProvider.key] ==
                                                  option.key
                                              ? Colors.grey
                                              : Colors.grey,
                                          size: 18,
                                        ),
                                        onPressed: selectedOptions[
                                                    serviceProvider.key] ==
                                                option.key
                                            ? () => handleVote(
                                                serviceProvider.key,
                                                option.key,
                                                false)
                                            : null,
                                        disabledColor: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed:
                                selectedOptions[serviceProvider.key] != null
                                    ? () => clearVote(serviceProvider.key)
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Clear Vote'),
                          ),
                        ],
                      ),
                    ),
                  )),
              if (showAlert)
                AlertDialog(
                  title: const Text('Oops!'),
                  content: Text(alertMessage ?? ''),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAlert = false;
                          alertMessage = null;
                        });
                      },
                      child: const Text('OK'),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
