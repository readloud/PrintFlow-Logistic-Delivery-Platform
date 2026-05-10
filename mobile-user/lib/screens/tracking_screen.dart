import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../providers/order_provider.dart';
import '../services/socket_service.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  LatLng _driverLocation = LatLng(-6.2088, 106.8456); // Default Jakarta
  final Set<Marker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    final orderId = (ModalRoute.of(context)!.settings.arguments as Map?)!['orderId'];
    Provider.of<OrderProvider>(context, listen: false).trackOrder(orderId);
    
    // Socket.io for realtime tracking
    final socket = SocketService().socket;
    socket.on('driver-location-update', (data) {
      setState(() {
        _driverLocation = LatLng(data['lat'], data['lng']);
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId('driver'),
          position: _driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Driver'),
        ));
        _mapController?.animateCamera(CameraUpdate.newLatLng(_driverLocation));
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.currentOrder;
    
    return Scaffold(
      appBar: AppBar(title: Text('Lacak Pesanan')),
      body: Column(
        children: [
          // Status Timeline
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusStep('Pesanan\nDibuat', order?.deliveryStatus == 'PENDING'),
                _buildStatusStep('Diproses', order?.deliveryStatus == 'PROCESSING'),
                _buildStatusStep('Diambil', order?.deliveryStatus == 'PICKED_UP'),
                _buildStatusStep('Diantar', order?.deliveryStatus == 'IN_TRANSIT'),
                _buildStatusStep('Selesai', order?.deliveryStatus == 'DELIVERED'),
              ],
            ),
          ),
          Divider(),
          
          // Map
          Container(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _driverLocation, zoom: 12),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
              myLocationEnabled: true,
            ),
          ),
          
          // Order Info
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.receipt),
                    title: Text('Order #${order?.id.substring(0,8)}'),
                    subtitle: Text('${order?.fileName} • ${order?.pages} halaman'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.local_shipping),
                    title: Text('Status: ${order?.deliveryStatus}'),
                    subtitle: Text('Estimasi sampai: ${_getETA(order?.deliveryStatus)}'),
                  ),
                ),
                if (order?.deliveryStatus == 'DELIVERED')
                  Card(
                    color: Colors.green[50],
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Pesanan Selesai'),
                      subtitle: Text('Terima kasih telah menggunakan PrintFlow'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusStep(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue : Colors.grey[300],
          ),
          child: Icon(isActive ? Icons.check : Icons.access_time, color: Colors.white, size: 20),
        ),
        SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
      ],
    );
  }
  
  String _getETA(String? status) {
    switch(status) {
      case 'PENDING': return 'belum ditentukan';
      case 'PROCESSING': return '30-60 menit';
      case 'PICKED_UP': return '15-30 menit';
      case 'IN_TRANSIT': return '5-15 menit';
      case 'DELIVERED': return 'sudah sampai';
      default: return '-';
    }
  }
}