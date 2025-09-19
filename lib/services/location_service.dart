import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app_mvp/main.dart';
import 'package:travel_app_mvp/models/location.dart';

class LocationService {
  static Future<List<Location>> getBrazilTop20() async {
    final response = await supabase
        .from('Location_Features')
        .select('position,*, Locations(*)')
        .eq('feature_id', 1);

    return response.map((data) {
      final locationData = Map<String, dynamic>.from(data['Locations']);
      locationData['position'] = data['position'];
      return Location.fromJson(locationData);
    }).toList();
  }

  static Future<List<Location>> getRioTop10() async {
    final response = await supabase
        .from('Location_Features')
        .select('position,*, Locations(*)')
        .eq('feature_id', 2); // Changed from 1 to 2 for cities

    return response.map((data) {
      final locationData = Map<String, dynamic>.from(data['Locations']);
      locationData['position'] = data['position'];
      return Location.fromJson(locationData);
    }).toList();
  }
}
