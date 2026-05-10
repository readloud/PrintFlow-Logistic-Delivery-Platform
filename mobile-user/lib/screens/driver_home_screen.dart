import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';

class DriverHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Available Orders'), actions: [
        IconButton(icon: Icon(Icons.logout), onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout()),
      ]),
      body: RefreshIndicator(
        onRefresh: () => orderProvider.fetchAvailableOrders(),
        child: orderProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: orderProvider.availableOrders.length,
                itemBuilder: (ctx, i) => OrderCard(order: orderProvider.availableOrders[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: () => orderProvider.updateCurrentLocation(),
      ),
    );
  }
}