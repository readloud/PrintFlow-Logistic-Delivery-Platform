import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteService {
  final String baseUrl = 'http://localhost:3000/api';
  
  Future<List<LatLng>> getOptimizedRoute(List<LatLng> waypoints) async {
    final response = await http.post(
      Uri.parse('$baseRoute/optimize-route'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'waypoints': waypoints.map((wp) => {'lat': wp.latitude, 'lng': wp.longitude}).toList(),
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['optimizedRoute'] as List)
          .map((point) => LatLng(point['lat'], point['lng']))
          .toList();
    }
    return waypoints;
  }
  
  Future<Map<String, dynamic>> getRouteFromGoogle(
    LatLng origin, 
    List<LatLng> destinations
  ) async {
    // Google Maps Directions API
    final apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    final originStr = '${origin.latitude},${origin.longitude}';
    final destinationsStr = destinations
        .map((d) => '${d.latitude},${d.longitude}')
        .join('|');
    
    final url = 'https://maps.googleapis.com/maps/api/directions/json?' +
        'origin=$originStr&destination=${destinations.last}&waypoints=optimize:true|$destinationsStr&key=$apiKey';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final polylinePoints = route['overview_polyline']['points'];
        return {
          'polyline': polylinePoints,
          'distance': route['legs'][0]['distance']['text'],
          'duration': route['legs'][0]['duration']['text'],
          'waypointOrder': route['waypoint_order'],
        };
      }
    }
    return {};
  }
}