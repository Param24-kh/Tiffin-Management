import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class TiffinServicePage extends StatefulWidget {
  final String centerId;
  const TiffinServicePage({Key? key, required this.centerId}) : super(key: key);

  @override
  _TiffinServicePageState createState() => _TiffinServicePageState();
}

class ValueAddedService {
  final String serviceId;
  final String centerId;
  final List<Item> services;

  ValueAddedService({
    required this.serviceId,
    required this.centerId,
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

  static const String _baseWebUrl = 'http://localhost:3000/api';
  static const String _baseAndroidUrl = 'http://10.0.2.2:3000/api';
  static const String _baseIOSUrl = 'http://127.0.0.1:3000/api';

  String get baseUrl {
    if (kIsWeb) return _baseWebUrl;
    if (Platform.isAndroid) return _baseAndroidUrl;
    if (Platform.isIOS) return _baseIOSUrl;
    return _baseWebUrl;
  }

  Future<void> _fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vas/getServices?centerId=${widget.centerId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          setState(() {
            _valueAddedServices =
                (responseData['data'] as List).map((serviceData) {
              return ValueAddedService(
                serviceId: serviceData['seviceId'],
                centerId: serviceData['centerId'],
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

  Future<void> _deleteService(String serviceId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/vas/deleteService?centerId=${widget.centerId}&serviceId=$serviceId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service deleted successfully')),
        );
        _fetchServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete service')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while deleting: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Value Added Services'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Service ${index + 1}',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: Colors.orange),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditServicePage(
                                                      centerId: widget.centerId,
                                                      service: service,
                                                    ),
                                                  ),
                                                ).then((_) => _fetchServices());
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () => _deleteService(
                                                  service.serviceId),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    ...service.services.map((item) => ListTile(
                                          title: Text(item.itemName),
                                          subtitle: Text(item.itemDescription),
                                          trailing: Text(
                                            '\$${item.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddServicePage(centerId: widget.centerId),
                              ),
                            ).then((_) => _fetchServices());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Add New Service',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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

  static const String _baseWebUrl = 'http://localhost:3000/api';
  static const String _baseAndroidUrl = 'http://10.0.2.2:3000/api';
  static const String _baseIOSUrl = 'http://127.0.0.1:3000/api';

  String get baseUrl {
    if (kIsWeb) return _baseWebUrl;
    if (Platform.isAndroid) return _baseAndroidUrl;
    if (Platform.isIOS) return _baseIOSUrl;
    return _baseWebUrl;
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
          Uri.parse('$baseUrl/vas/addService'),
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
        backgroundColor: Colors.orange,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            ...List.generate(_nameControllers.length, (index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item ${index + 1}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _nameControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Service Name',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a service name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Service Description',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a service description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _priceControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                        ),
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
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _addServiceItem,
              icon: Icon(Icons.add),
              label: Text('Add Another Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitService,
              child: Text('Submit Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditServicePage extends StatefulWidget {
  final String centerId;
  final ValueAddedService service;

  const EditServicePage({
    Key? key,
    required this.centerId,
    required this.service,
  }) : super(key: key);

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _descriptionControllers;
  late List<TextEditingController> _priceControllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing service data
    _nameControllers = widget.service.services
        .map((item) => TextEditingController(text: item.itemName))
        .toList();
    _descriptionControllers = widget.service.services
        .map((item) => TextEditingController(text: item.itemDescription))
        .toList();
    _priceControllers = widget.service.services
        .map((item) => TextEditingController(text: item.price.toString()))
        .toList();
  }

  @override
  void dispose() {
    // Clean up controllers
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addServiceItem() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _descriptionControllers.add(TextEditingController());
      _priceControllers.add(TextEditingController());
    });
  }

  void _removeServiceItem(int index) {
    setState(() {
      _nameControllers.removeAt(index);
      _descriptionControllers.removeAt(index);
      _priceControllers.removeAt(index);
    });
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

  Future<void> _updateService() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<Map<String, dynamic>> updatedServices = [];
        for (int i = 0; i < _nameControllers.length; i++) {
          updatedServices.add({
            'ItemName': _nameControllers[i].text,
            'itemDescription': _descriptionControllers[i].text,
            'price': double.parse(_priceControllers[i].text),
          });
        }

        final response = await http.put(
          Uri.parse(
              '$baseUrl/vas/updateService?centerId=${widget.centerId}&serviceId=${widget.service.serviceId}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'service': updatedServices,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Failed to update service');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating service: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Service'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  ...List.generate(
                    _nameControllers.length,
                    (index) => Card(
                      margin: EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Item ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                if (_nameControllers.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeServiceItem(index),
                                  ),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _nameControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Item Name',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an item name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _descriptionControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                              maxLines: 3,
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _priceControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: _addServiceItem,
                    icon: Icon(Icons.add),
                    label: Text('Add New Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _updateService,
                    child: Text(
                      'Update Service',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
