import 'package:flutter/material.dart';

class TiffinServicePage extends StatefulWidget {
  const TiffinServicePage({super.key});
  @override
  _TiffinServicePageState createState() => _TiffinServicePageState();
}

class _TiffinServicePageState extends State<TiffinServicePage> {
  // Sample data for value-added services
  final List<ValueAddedService> _valueAddedServices = [
    ValueAddedService(
      provider: 'Nakoda Tiffin Center',
      services: [
        'Salad: Delicious home-cooked salad delivered to your doorstep',
        'Same-day delivery',
        'Customizable portions',
        'Dietary restrictions accommodated',
      ],
    ),
    ValueAddedService(
      provider: 'Tiffin Wala',
      services: [
        'Salad: Freshly prepared salad with a variety of options',
        'Subscription discounts',
        'Loyalty program',
        'Referral rewards',
      ],
    ),
    ValueAddedService(
      provider: 'Home Cooked Meals',
      services: [
        'Salad: Healthy and wholesome salad',
        'Eco-friendly packaging',
        'Donation program',
        'Seasonal menu updates',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiffin Services'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _valueAddedServices.length,
          itemBuilder: (context, index) {
            final service = _valueAddedServices[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.provider,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ...service.services.map((s) => Text(s)),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to payment page or handle payment logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text('Choose Plan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ValueAddedService {
  final String provider;
  final List<String> services;

  ValueAddedService({
    required this.provider,
    required this.services,
  });
}
