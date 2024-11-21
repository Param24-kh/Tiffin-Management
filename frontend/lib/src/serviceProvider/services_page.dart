import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TiffinServicePage extends StatefulWidget {
  final String centerId;
  const TiffinServicePage({Key? key, required this.centerId}) : super(key: key);

  @override
  _TiffinServicePageState createState() => _TiffinServicePageState();
}

class ValueAddedService {
  final String serviceId;
  final String providerName;
  final List<Item> services;

  ValueAddedService({
    required this.serviceId,
    required this.providerName,
    required this.services,
  });
}

class Item {
  final String itemId;
  final String itemName;
  final String itemDescription;
  final double price;

  Item({
    required this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.price,
  });
}

class _TiffinServicePageState extends State<TiffinServicePage> {
  List<ValueAddedService> _valueAddedServices = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/api/vas/getServices?centerId=${widget.centerId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          setState(() {
            _valueAddedServices =
                (responseData['data'] as List).map((serviceData) {
              return ValueAddedService(
                serviceId: serviceData['seviceId'],
                providerName:
                    'Tiffin Service Provider', // You might want to add this to your backend model
                services:
                    (serviceData['service'] as List).map<Item>((itemData) {
                  return Item(
                    itemId: itemData['ItemId'],
                    itemName: itemData['ItemName'],
                    itemDescription: itemData['itemDescription'],
                    price: (itemData['price'] as num).toDouble(),
                  );
                }).toList(),
              );
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                responseData['message'] ?? 'Failed to load services';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load services';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Value Added Services'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigation to add new service page (for service providers)
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddServicePage(centerId: widget.centerId),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: _fetchServices,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _valueAddedServices.length,
                    itemBuilder: (context, index) {
                      final service = _valueAddedServices[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.providerName,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              ...service.services
                                  .map((item) => ListTile(
                                        title: Text(item.itemName),
                                        subtitle: Text(item.itemDescription),
                                        trailing: Text(
                                            '\$${item.price.toStringAsFixed(2)}'),
                                      ))
                                  .toList(),
                              SizedBox(height: 16.0),
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

class AddServicePage extends StatefulWidget {
  final String centerId;
  const AddServicePage({Key? key, required this.centerId}) : super(key: key);

  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _descriptionControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _priceControllers = [
    TextEditingController()
  ];

  void _addServiceItem() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _descriptionControllers.add(TextEditingController());
      _priceControllers.add(TextEditingController());
    });
  }

  Future<void> _submitService() async {
    if (_formKey.currentState!.validate()) {
      List<Map<String, dynamic>> services = [];
      for (int i = 0; i < _nameControllers.length; i++) {
        services.add({
          'ItemName': _nameControllers[i].text,
          'itemDescription': _descriptionControllers[i].text,
          'price': double.parse(_priceControllers[i].text),
        });
      }

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/vas/addService'),
          body: json.encode({
            'centerId': widget.centerId,
            'service': services,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Service added successfully!')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add service')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Service'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            ...List.generate(_nameControllers.length, (index) {
              return Column(
                children: [
                  TextFormField(
                    controller: _nameControllers[index],
                    decoration: InputDecoration(labelText: 'Service Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a service name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionControllers[index],
                    decoration:
                        InputDecoration(labelText: 'Service Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a service description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceControllers[index],
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                ],
              );
            }),
            ElevatedButton(
              onPressed: _addServiceItem,
              child: Text('Add Another Service Item'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitService,
              child: Text('Submit Service'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
