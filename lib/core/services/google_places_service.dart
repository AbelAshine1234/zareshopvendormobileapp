import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  static const String apiKey = 'AIzaSyDr7hZhsJ7UM_5BJ9f6cl02Ypfp-iUPnd0';
  static const String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // Search for places based on input
  static Future<List<Map<String, dynamic>>> searchPlaces(String input) async {
    if (input.isEmpty) return [];
    
    try {
      final url = '$baseUrl/autocomplete/json?input=$input&key=$apiKey&components=country:et';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((p) => {
            'place_id': p['place_id'],
            'description': p['description'],
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
  
  // Get place details by place_id
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = '$baseUrl/details/json?place_id=$placeId&key=$apiKey&fields=address_components,formatted_address,geometry';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          final addressComponents = result['address_components'] as List;
          
          // Parse address components
          String? street = '';
          String? city = '';
          String? state = '';
          String? postalCode = '';
          String? country = '';
          
          for (var component in addressComponents) {
            final types = component['types'] as List;
            
            if (types.contains('route') || types.contains('street_address')) {
              street = component['long_name'];
            }
            if (types.contains('locality')) {
              city = component['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              state = component['long_name'];
            }
            if (types.contains('postal_code')) {
              postalCode = component['long_name'];
            }
            if (types.contains('country')) {
              country = component['long_name'];
            }
          }
          
          return {
            'formatted_address': result['formatted_address'],
            'street': street,
            'city': city,
            'state': state,
            'postal_code': postalCode,
            'country': country,
            'latitude': result['geometry']['location']['lat'],
            'longitude': result['geometry']['location']['lng'],
          };
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }
}
