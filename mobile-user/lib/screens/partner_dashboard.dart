import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../providers/partner_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/order_queue_card.dart';
import '../widgets/printer_status_card.dart';

class PartnerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final partnerProvider = Provider.of<PartnerProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('PrintFlow Partner'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: Icon(Icons.printer), onPressed: () => partnerProvider.checkPrinters()),
          IconButton(icon: Icon(Icons.notifications), onPressed: () => _showNotifications(context)),
          IconButton(icon: Icon(Icons.logout), onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => partnerProvider.fetchDashboard(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Antrian', partnerProvider.queueCount.toString(), Icons.queue, Colors.orange),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Diproses', partnerProvider.processingCount.toString(), Icons.print, Colors.blue),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Selesai', partnerProvider.completedCount.toString(), Icons.check_circle, Colors.green),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Printer Status
              Text('Printer Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: partnerProvider.printers.map((printer) => PrinterStatusCard(printer: printer)).toList(),
                ),
              ),
              SizedBox(height: 24),
              
              // Order Queue
              Text('Order Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...partnerProvider.queueOrders.map((order) => OrderQueueCard(order: order)),
              
              // Quick Actions
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: [
                          _buildQuickAction('Print All', Icons.print, () => partnerProvider.printAllQueue()),
                          _buildQuickAction('Request Pickup', Icons.local_shipping, () => partnerProvider.requestPickup()),
                          _buildQuickAction('Stock Report', Icons.assessment, () => partnerProvider.generateStockReport()),
                          _buildQuickAction('Scanner', Icons.scanner, () => _openScanner(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Drivers'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Reports'),
        ],
        currentIndex: partnerProvider.currentTab,
        onTap: (index) => partnerProvider.setTab(index),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
    );
  }
  
  void _openScanner(BuildContext context) {
    // Open document scanner
    Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentScannerScreen()));
  }
  
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => NotificationPanel(),
    );
  }
}