import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageResultsPage extends StatefulWidget {
  final String zipcode;
  final DateTimeRange dateRange;
  final int requiredVolume;

  const StorageResultsPage({super.key, required this.zipcode, required this.dateRange, required this.requiredVolume});

  @override
  _StorageResultsPageState createState() => _StorageResultsPageState();
}

class _StorageResultsPageState extends State<StorageResultsPage> {
  List<Map<String, dynamic>> _storageResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStorageResults();
  }

  Future<void> _fetchStorageResults() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('storage_spaces')
          .where('zipcode', isEqualTo: widget.zipcode)
          .where('preferred_dates.start', isLessThanOrEqualTo: widget.dateRange.start)
          .where('preferred_dates.end', isGreaterThanOrEqualTo: widget.dateRange.end)
          .get();

      setState(() {
        _storageResults = querySnapshot.docs
            .map((doc) {
          int length = doc['length'];
          int width = doc['width'];
          int height = doc['height'];
          int storageVolume = length * width * height;

          if (storageVolume >= widget.requiredVolume) {
            return {
              'address': doc['address'],
              'price_per_month': doc['price_per_month'],
              'length': length,
              'width': width,
              'height': height,
              'image_url': doc['image_url'],
              'volume': storageVolume,
            };
          }
          return null;
        })
            .where((element) => element != null)
            .cast<Map<String, dynamic>>()
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching storage results: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch storage listings')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Results'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _storageResults.isEmpty
          ? const Center(child: Text('No storage spaces found for the given criteria.'))
          : ListView.builder(
        itemCount: _storageResults.length,
        itemBuilder: (context, index) {
          final storage = _storageResults[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              minVerticalPadding: 20,
              leading: storage['image_url'] != null
                  ? Image.network(storage['image_url'], width: 100, height: 100, fit: BoxFit.cover)
                  : const Icon(Icons.home),
              title: Text('Address: ${storage['address']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price per Month: \$${storage['price_per_month']}'),
                  Text('Dimensions: ${storage['length']} ft x ${storage['width']} ft x ${storage['height']} ft'),
                  Text('Volume: ${storage['volume']} cubic feet'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConfirmationPage(),
                        ),
                      );
                    },
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Thanks! We will let you know once the owner confirms.',
              style: TextStyle(fontSize: 60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Results'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('Back to Homepage'),
            ),
          ],
        ),
      ),
    );
  }
}