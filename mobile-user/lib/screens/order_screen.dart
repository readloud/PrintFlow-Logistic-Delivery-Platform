import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../providers/order_provider.dart';
import '../providers/hub_provider.dart';
import '../models/delivery_method.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _pages = 1;
  int _copies = 1;
  DeliveryMethodType _selectedMethod = DeliveryMethodType.COURIER_COD;
  String? _selectedHubPointId;
  String? _address;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    Provider.of<HubProvider>(context, listen: false).fetchHubPoints();
  }

  @override
  Widget build(BuildContext context) {
    final hubProvider = Provider.of<HubProvider>(context);
    final totalPrice = _pages * 500 * _copies;
    
    return Scaffold(
      appBar: AppBar(title: Text('Detail Pesanan')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Preview
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                    SizedBox(height: 8),
                    Text('document.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Quantity Controls
            Text('Jumlah Halaman', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(onPressed: () => setState(() => _pages = _pages > 1 ? _pages - 1 : 1), icon: Icon(Icons.remove)),
                Text('$_pages', style: TextStyle(fontSize: 18)),
                IconButton(onPressed: () => setState(() => _pages++), icon: Icon(Icons.add)),
                SizedBox(width: 32),
                Text('Copy ke-', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => setState(() => _copies = _copies > 1 ? _copies - 1 : 1), icon: Icon(Icons.remove)),
                Text('$_copies', style: TextStyle(fontSize: 18)),
                IconButton(onPressed: () => setState(() => _copies++), icon: Icon(Icons.add)),
              ],
            ),
            SizedBox(height: 16),
            
            // Delivery Method
            Text('Metode Pengiriman', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            RadioListTile(
              title: Text('Kurir COD', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('Bayar tunai saat sampai'),
              value: DeliveryMethodType.COURIER_COD,
              groupValue: _selectedMethod,
              onChanged: (v) => setState(() => _selectedMethod = v!),
            ),
            RadioListTile(
              title: Text('Ambil di Hub Point', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('Lebih hemat ongkir'),
              value: DeliveryMethodType.HUB_POINT,
              groupValue: _selectedMethod,
              onChanged: (v) => setState(() => _selectedMethod = v!),
            ),
            
            if (_selectedMethod == DeliveryMethodType.HUB_POINT) ...[
              SizedBox(height: 12),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Pilih Lokasi Hub', border: OutlineInputBorder()),
                items: hubProvider.hubPoints.map((hub) => DropdownMenuItem(
                  value: hub.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${hub.name} (${hub.type})'),
                      Text('Rp ${hub.flatFee.toInt()}', style: TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  ),
                )).toList(),
                onChanged: (value) => setState(() => _selectedHubPointId = value),
              ),
            ],
            
            if (_selectedMethod == DeliveryMethodType.COURIER_COD) ...[
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(labelText: 'Alamat Lengkap', border: OutlineInputBorder()),
                maxLines: 3,
                onChanged: (val) => _address = val,
              ),
            ],
            
            SizedBox(height: 32),
            
            // Price Summary
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Biaya Cetak'), 
                    Text('Rp ${(_pages * 500 * _copies).toInt()}')
                  ]),
                  SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Ongkos Kirim'), 
                    Text(_selectedMethod == DeliveryMethodType.HUB_POINT ? 'Rp 5.000' : 'Rp 10.000')
                  ]),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rp ${(totalPrice + (_selectedMethod == DeliveryMethodType.HUB_POINT ? 5000 : 10000)).toInt()}', 
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _createOrder(totalPrice),
                child: _isProcessing ? CircularProgressIndicator() : Text('Buat Pesanan', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _createOrder(int totalPrice) async {
    setState(() => _isProcessing = true);
    
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final file = ModalRoute.of(context)!.settings.arguments as Map?['file'];
    
    await orderProvider.createOrder(
      file: File(file.path),
      pages: _pages,
      copies: _copies,
      totalPrice: totalPrice + (_selectedMethod == DeliveryMethodType.HUB_POINT ? 5000 : 10000),
      deliveryMethod: _selectedMethod.toString().split('.').last,
      paymentMethod: 'COD',
      address: _address,
      hubPointId: _selectedHubPointId,
    );
    
    setState(() => _isProcessing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pesanan berhasil dibuat!')));
    Navigator.pushReplacementNamed(context, '/tracking', arguments: {'orderId': orderProvider.currentOrder?.id});
  }
}