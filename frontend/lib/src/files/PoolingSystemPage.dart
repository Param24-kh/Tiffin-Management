import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PoolingSystemPage extends StatefulWidget {
  const PoolingSystemPage({Key? key}) : super(key: key);

  @override
  _PoolingSystemPageState createState() => _PoolingSystemPageState();
}

class _PoolingSystemPageState extends State<PoolingSystemPage> {
  File? _image;
  final picker = ImagePicker();

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pooling System'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Pools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPoolCard(
                'Vegetarian Delight',
                'A wholesome vegetarian meal for health enthusiasts.',
                'assets/lunchDelight.png',
              ),
              const SizedBox(height: 16),
              _buildPoolCard(
                'Non-Veg Feast',
                'A feast for lovers with a variety of dishes.',
                'assets/lunchDelight.png',
              ),
              const SizedBox(height: 24),
              const Text(
                'Create New Pool',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildCreatePoolForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoolCard(String title, String description, String imagePath) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Join Pool'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Leave Pool'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePoolForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: 'Meal Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Number of Participants',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => getImage(ImageSource.camera),
              child: const Text('Take Photo'),
            ),
            ElevatedButton(
              onPressed: () => getImage(ImageSource.gallery),
              child: const Text('Choose from Gallery'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_image != null)
          Image.file(
            _image!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        else
          const Text('No image selected'),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Implement the logic to create a pool with the selected image
            },
            child: const Text('Create Pool'),
          ),
        ),
      ],
    );
  }
}
