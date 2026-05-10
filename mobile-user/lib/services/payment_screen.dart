import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  
  PaymentScreen({required this.orderId, required this.amount});
  
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _snapUrl;
  bool _isLoading = true;
  String _selectedMethod = 'BANK_TRANSFER';
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Bank Transfer (BCA/BNI/BRI/Mandiri)', 'value': 'BANK_TRANSFER', 'icon': Icons.account_balance},
    {'name': 'QRIS (Scan QRIS)', 'value': 'QRIS', 'icon': Icons.qr_code_scanner},
    {'name': 'E-Wallet (GoPay/ShopeePay)', 'value': 'EWALLET', 'icon': Icons.wallet},
    {'name': 'Kartu Kredit', 'value': 'CREDIT_CARD', 'icon': Icons.credit_card},
  ];
  
  Future<void> _createTransaction() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final response = await http.post(
      Uri.parse('https://api.printflow.com/api/payment/create-transaction'),
      headers: {
        'Authorization': 'Bearer ${auth.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'orderId': widget.orderId,
        'paymentMethod': _selectedMethod,
      }),
    );
    
    final data = json.decode(response.body);
    if (data['success'] == true) {
      setState(() {
        _snapUrl = data['snapUrl'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat transaksi: ${data['error']}')),
      );
    }
  }
  
  @override
  void initState() {
    super.initState();
    _createTransaction();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran'), backgroundColor: Colors.white),
      body: _isLoading
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mempersiapkan pembayaran...'),
              ],
            ))
          : _snapUrl != null
              ? WebView(
                  initialUrl: _snapUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageFinished: (url) {
                    if (url.contains('finish')) {
                      Navigator.pushReplacementNamed(context, '/success', arguments: {'orderId': widget.orderId});
                    } else if (url.contains('error')) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran gagal')));
                    }
                  },
                )
              : _buildPaymentMethodSelector(),
    );
  }
  
  Widget _buildPaymentMethodSelector() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Pembayaran', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text('Rp ${widget.amount.toInt().toString()}', 
               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
          SizedBox(height: 24),
          Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ..._paymentMethods.map((method) => RadioListTile(
            title: Text(method['name']),
            leading: Icon(method['icon']),
            value: method['value'],
            groupValue: _selectedMethod,
            onChanged: (val) => setState(() => _selectedMethod = val.toString()),
          )),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _createTransaction,
              child: Text('Bayar Sekarang', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}