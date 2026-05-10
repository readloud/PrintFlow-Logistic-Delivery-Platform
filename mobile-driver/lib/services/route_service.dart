import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteService {
  static const String baseUrl = String.fromEnvironment('API_URL');
  
  Future<OptimizedRoute> getOptimizedRoute(
    List<LatLng> waypoints,
    LatLng startPoint,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/optimize-route'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'startPoint': {
          'lat': startPoint.latitude,
          'lng': startPoint.longitude,
        },
        'waypoints': waypoints.map((wp) => {
          'lat': wp.latitude,
          'lng': wp.longitude,
        }).toList(),
      }),
    );
    
    final data = json.decode(response.body);
    
    return OptimizedRoute.fromJson(data);
  }
  
  Future<Duration> getEstimatedTime(LatLng origin, LatLng destination) async {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json')
          .replace(queryParameters: {
        'origins': '${origin.latitude},${origin.longitude}',
        'destinations': '${destination.latitude},${destination.longitude}',
        'key': const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
        'departure_time': 'now',
        'traffic_model': 'best_guess',
      }),
    );
    
    final data = json.decode(response.body);
    final duration = data['rows'][0]['elements'][0]['duration_in_traffic']['value'];
    
    return Duration(seconds: duration);
  }
}

class OptimizedRoute {
  final List<RouteStop> stops;
  final double totalDistance;
  final int totalDuration;
  final int estimatedSavings;
  
  OptimizedRoute({
    required this.stops,
    required this.totalDistance,
    required this.totalDuration,
    required this.estimatedSavings,
  });
  
  factory OptimizedRoute.fromJson(Map<String, dynamic> json) {
    return OptimizedRoute(
      stops: (json['route'] as List)
          .map((stop) => RouteStop.fromJson(stop))
          .toList(),
      totalDistance: json['totalDistance'].toDouble(),
      totalDuration: json['totalDuration'].toInt(),
      estimatedSavings: json['estimatedSavings']?.toInt() ?? 0,
    );
  }
}

class RouteStop {
  final String orderId;
  final LatLng location;
  final int order;
  final int eta;
  final String address;
  final double codAmount;
  
  RouteStop({
    required this.orderId,
    required this.location,
    required this.order,
    required this.eta,
    required this.address,
    required this.codAmount,
  });
  
  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      orderId: json['orderId'],
      location: LatLng(json['lat'], json['lng']),
      order: json['order'],
      eta: json['eta'],
      address: json['address'],
      codAmount: json['codAmount']?.toDouble() ?? 0,
    );
  }
}