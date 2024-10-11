import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelink/pages/storageresult.dart';

class FindStoragePage extends StatefulWidget {
  const FindStoragePage({super.key});

  @override
  _FindStoragePageState createState() => _FindStoragePageState();
}

class _FindStoragePageState extends State<FindStoragePage> {
  final TextEditingController _zipcodeController = TextEditingController();
  int _smallBoxCount = 0;
  int _mediumBoxCount = 0;
  int _largeBoxCount = 0;
  DateTimeRange? _selectedDateRange;

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) return 'Select Date Range';
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return '${formatter.format(dateRange.start)} - ${formatter.format(dateRange.end)}';
  }

  void _searchStorage() {
    String zipcode = _zipcodeController.text.trim();
    DateTimeRange? dateRange = _selectedDateRange;

    if (zipcode.isEmpty || dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    int requiredVolume = _calculateRequiredVolume();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorageResultsPage(
          zipcode: zipcode,
          dateRange: dateRange,
          requiredVolume: requiredVolume,
        ),
      ),
    );
  }

  int _calculateRequiredVolume() {
    // Volume in cubic feet
    const int smallBoxVolume = 2;
    const int mediumBoxVolume = 3;
    const int largeBoxVolume = 5;

    return (_smallBoxCount * smallBoxVolume) +
        (_mediumBoxCount * mediumBoxVolume) +
        (_largeBoxCount * largeBoxVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Storage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          SizedBox(
          height: 100,),
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
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBoxCounter('Small Boxes', _smallBoxCount, (value) {
                  setState(() {
                    _smallBoxCount = value;
                  });
                }),
                _buildBoxCounter('Medium Boxes', _mediumBoxCount, (value) {
                  setState(() {
                    _mediumBoxCount = value;
                  });
                }),
                _buildBoxCounter('Large Boxes', _largeBoxCount, (value) {
                  setState(() {
                    _largeBoxCount = value;
                  });
                }),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _pickDateRange(context),
              child: Text(_formatDateRange(_selectedDateRange)),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _searchStorage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.white
              ),
              child: const Text('Search'),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxCounter(String label, int count, ValueChanged<int> onCountChanged) {
    return Column(
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (count > 0) {
                  onCountChanged(count - 1);
                }
              },
            ),
            Text('$count'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onCountChanged(count + 1);
              },
            ),
          ],
        ),
      ],
    );
  }
}