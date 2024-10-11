import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

class LendStoragePage extends StatefulWidget {
  const LendStoragePage({super.key});

  @override
  _LendStoragePageState createState() => _LendStoragePageState();
}

class _LendStoragePageState extends State<LendStoragePage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTimeRange? _preferredDateRange;
  Uint8List? _imageData;

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _preferredDateRange) {
      setState(() {
        _preferredDateRange = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile;

      if (kIsWeb) {
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final Uint8List bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageData = bytes;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  String _formatDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) return 'Select Date Range';
    final DateFormat formatter = DateFormat('yyyy-MM-dd'); // Date format for displaying only the date
    return '${formatter.format(dateRange.start)} - ${formatter.format(dateRange.end)}';
  }

  Future<void> _uploadData() async {
    if (_addressController.text.isEmpty ||
        _zipcodeController.text.isEmpty ||
        _lengthController.text.isEmpty ||
        _widthController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields and upload a photo')),
      );
      return;
    }

    try {
      // Upload the photo to Firebase Storage
      final User? user = FirebaseAuth.instance.currentUser;
      String fileName = 'storage_spaces/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      SettableMetadata metadata = SettableMetadata(
        customMetadata: {'ownerId': user!.uid},
      );
      UploadTask uploadTask = storageRef.putData(_imageData!, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Upload the data to Firestore
      await FirebaseFirestore.instance.collection('storage_spaces').add({
        'address': _addressController.text.trim(),
        'zipcode': _zipcodeController.text.trim(),
        'length': double.parse(_lengthController.text.trim()),
        'width': double.parse(_widthController.text.trim()),
        'height': double.parse(_heightController.text.trim()),
        'price_per_month': double.parse(_priceController.text.trim()),
        'preferred_dates': _preferredDateRange != null
            ? {
          'start': _preferredDateRange!.start,
          'end': _preferredDateRange!.end,
        }
            : null,
        'image_url': imageUrl,
        'owner_id': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage listing added successfully')),
      );

      // Clear fields after successful upload
      setState(() {
        _addressController.clear();
        _zipcodeController.clear();
        _lengthController.clear();
        _widthController.clear();
        _heightController.clear();
        _priceController.clear();
        _preferredDateRange = null;
        _imageData = null;
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add storage listing')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lend Storage'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Enter Address',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _zipcodeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Zipcode',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _lengthController,
                    decoration: const InputDecoration(
                      labelText: 'Length (ft)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'Width (ft)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (ft)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Month (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickDateRange(context),
              child: Text(_formatDateRange(_preferredDateRange))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Photo of Space'),
            ),
            const SizedBox(height: 10),
            if (_imageData != null)
              Image.memory(
                _imageData!,
                height: 150,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: const Text('Submit Storage Details'),
            ),
          ],
        ),
      ),
    );
  }
}