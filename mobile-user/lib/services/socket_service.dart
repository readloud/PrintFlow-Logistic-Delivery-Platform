import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SocketService with ChangeNotifier {
  static SocketService? _instance;
  static SocketService get instance => _instance ??= SocketService._();
  SocketService._();
  
  IO.Socket? _socket;
  bool _isConnected = false;
  Map<String, dynamic> _currentLocation = {};
  List<Map<String, dynamic>> _pendingOrders = [];
  Map<String, dynamic>? _optimizedRoute;
  
  bool get isConnected => _isConnected;
  List<Map<String, dynamic>> get pendingOrders => _pendingOrders;
  Map<String, dynamic>? get optimizedRoute => _optimizedRoute;
  
  Future<void> connect(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    _socket = IO.io('https://api.printflow.com', {
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': 'Bearer $token'},
      'auth': {'token': token}
    });
    
    _setupListeners(role);
    _socket!.connect();
  }
  
  void _setupListeners(String role) {
    _socket!.onConnect((_) {
      print('Socket connected');
      _isConnected = true;
      notifyListeners();
      
      // Register based on role
      if (role == 'DRIVER') {
        _socket!.emit('driver:register');
        _startLocationTracking();
      } else if (role == 'ADMIN') {
        _socket!.emit('admin:start-monitoring');
        _socket!.emit('admin:get-live-drivers');
      }
    });
    
    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
      notifyListeners();
    });
    
    // Driver listeners
    _socket!.on('driver:pending-orders', (data) {
      _pendingOrders = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    });
    
    _socket!.on('driver:optimized-route', (data) {
      _optimizedRoute = data;
      notifyListeners();
    });
    
    // User listeners
    _socket!.on('order:tracking-data', (data) {
      print('Tracking data received: $data');
      _onTrackingData?.call(data);
    });
    
    _socket!.on('order:status-update', (data) {
      print('Status update: ${data['status']}');
      _onStatusUpdate?.call(data);
    });
    
    _socket!.on('order:eta-update', (data) {
      print('ETA update: ${data['etaMinutes']} minutes');
      _onEtaUpdate?.call(data);
    });
    
    _socket!.on('order:completed', (data) {
      print('Order completed!');
      _onOrderCompleted?.call(data);
    });
    
    // Admin listeners
    _socket!.on('admin:live-drivers', (drivers) {
      _onLiveDrivers?.call(drivers);
    });
    
    _socket!.on('admin:delivery-completed', (data) {
      _onDeliveryCompleted?.call(data);
    });
    
    // Error listener
    _socket!.on('error', (error) {
      print('Socket error: $error');
      _onError?.call(error);
    });
  }
  
  void _startLocationTracking() {
    // Get location using Geolocator
    // Send every 3 seconds
    // Implementation with geolocator package
  }
  
  // Driver methods
  void updateLocation(double lat, double lng, {double? heading, double? speed}) {
    if (!_isConnected) return;
    _socket!.emit('driver:location', {
      'lat': lat,
      'lng': lng,
      'heading': heading ?? 0,
      'speed': speed ?? 0,
      'accuracy': 10.0,
      'timestamp': DateTime.now().toIso8601String()
    });
  }
  
  void startDelivery(String orderId) {
    _socket!.emit('driver:start-delivery', {'orderId': orderId});
  }
  
  void completeDelivery(String orderId, {String? deliveryPhoto, String? signature, double? amountReceived}) {
    _socket!.emit('driver:complete-delivery', {
      'orderId': orderId,
      'deliveryPhoto': deliveryPhoto,
      'signature': signature,
      'amountReceived': amountReceived
    });
  }
  
  void updateDriverStatus(String status) { // ONLINE, OFFLINE, BUSY
    _socket!.emit('driver:status', {'status': status});
  }
  
  // User methods
  void trackOrder(String orderId) {
    _socket!.emit('user:track-order', {'orderId': orderId});
  }
  
  void stopTracking(String orderId) {
    _socket!.emit('user:stop-tracking', {'orderId': orderId});
  }
  
  // Admin methods
  void getLiveDrivers() {
    _socket!.emit('admin:get-live-drivers');
  }
  
  // Callbacks
  Function(Map<String, dynamic>)? _onTrackingData;
  Function(Map<String, dynamic>)? _onStatusUpdate;
  Function(Map<String, dynamic>)? _onEtaUpdate;
  Function(Map<String, dynamic>)? _onOrderCompleted;
  Function(List<dynamic>)? _onLiveDrivers;
  Function(Map<String, dynamic>)? _onDeliveryCompleted;
  Function(Map<String, dynamic>)? _onError;
  
  void set onTrackingData(Function(Map<String, dynamic>) callback) => _onTrackingData = callback;
  void set onStatusUpdate(Function(Map<String, dynamic>) callback) => _onStatusUpdate = callback;
  void set onEtaUpdate(Function(Map<String, dynamic>) callback) => _onEtaUpdate = callback;
  void set onOrderCompleted(Function(Map<String, dynamic>) callback) => _onOrderCompleted = callback;
  void set onLiveDrivers(Function(List<dynamic>) callback) => _onLiveDrivers = callback;
  void set onDeliveryCompleted(Function(Map<String, dynamic>) callback) => _onDeliveryCompleted = callback;
  
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}