import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app_mvp/main.dart';
import 'package:travel_app_mvp/models/states.dart';

class StateService {
  static Future<List<States>> getBrazilStates() async {
    final response = await supabase
        .from('States')
        .select('*')
        .eq('Countries_id', 1);

    print('DEBUG: Raw response: $response'); // ADD THIS

    for (var data in response) {
      print('DEBUG: State data: $data'); // ADD THIS
    }
    return response.map((data) => States.fromJson(data)).toList();
  }
}
