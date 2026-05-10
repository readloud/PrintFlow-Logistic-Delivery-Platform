import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/ai_service.dart';
import '../widgets/delivery_method_card.dart';
import '../widgets/recent_order_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  File? _selectedFile;
  String? _aiValidationResult;
  bool _isUploading = false;

  final List<Widget> _pages = [
    HomeContent(),
    OrderHistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _pickFile(),
              icon: Icon(Icons.cloud_upload),
              label: Text('Print Now'),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _isUploading = true;
      });
      
      // AI Validation
      final aiService = AIService();
      final validation = await aiService.validatePrintFile(_selectedFile!);
      setState(() {
        _aiValidationResult = validation['isValid'] ? 'File siap cetak' : validation['issues'].join(', ');
        _isUploading = false;
      });
      
      if (validation['isValid']) {
        Navigator.pushNamed(context, '/order', arguments: {
          'file': _selectedFile,
          'suggestions': validation['suggestedFix'],
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ $_aiValidationResult'), backgroundColor: Colors.orange),
        );
      }
    }
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text('Hi, User!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Print dokumenmu, kami antar sampai tujuan', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 24),
          
          // Promo Banner
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Free Ongkir!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Minimal cetak Rp50.000', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                Icon(Icons.local_printshop, size: 60, color: Colors.white54),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          Text('Pesanan Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          orderProvider.recentOrders.isEmpty
              ? Center(child: Text('Belum ada pesanan'))
              : Column(
                  children: orderProvider.recentOrders.map((order) => RecentOrderCard(order: order)).toList(),
                ),
        ],
      ),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Pesanan'), backgroundColor: Colors.white),
      body: ListView.builder(
        itemCount: orderProvider.orders.length,
        itemBuilder: (ctx, i) {
          final order = orderProvider.orders[i];
          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              leading: Icon(Icons.receipt, color: order.deliveryStatus == 'DELIVERED' ? Colors.green : Colors.orange),
              title: Text(order.fileName),
              subtitle: Text('${order.pages} halaman • ${order.copies} copy'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Rp ${order.totalPrice.toInt()}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(order.deliveryStatus, style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              onTap: () => Navigator.pushNamed(context, '/tracking', arguments: {'orderId': order.id}),
            ),
          );
        },
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Profile'), backgroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            SizedBox(height: 16),
            Text(auth.user?.name ?? 'User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(auth.user?.email ?? 'email@example.com'),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => auth.logout(),
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}