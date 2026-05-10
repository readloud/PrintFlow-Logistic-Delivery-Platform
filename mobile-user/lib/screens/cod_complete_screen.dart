import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class CODCompleteScreen extends StatefulWidget {
  final String orderId;
  CODCompleteScreen({required this.orderId});

  @override
  _CODCompleteScreenState createState() => _CODCompleteScreenState();
}

class _CODCompleteScreenState extends State<CODCompleteScreen> {
  final TextEditingController amountController = TextEditingController();
  String? photoPath;
  final picker = ImagePicker();

  Future<void> takePhoto() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => photoPath = picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete COD Delivery')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount Received (Rp)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: takePhoto,
              child: Text(photoPath == null ? 'Take Delivery Photo' : 'Photo Taken ✓'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                orderProvider.completeCOD(widget.orderId, double.parse(amountController.text), photoPath!);
                Navigator.pop(context);
              },
              child: Text('Complete Delivery'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}