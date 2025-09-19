import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/map_screen.dart';
import 'providers/location_provider.dart';
import "utils/constants.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this

  await Supabase.initialize(
    // Add this block
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
  );

  String ACCESS_TOKEN = Constants.mapboxAccessToken;
  MapboxOptions.setAccessToken(ACCESS_TOKEN);

  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationProvider(),
      child: MaterialApp(
        title: 'Brazil Travel Guide',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter', // We'll add this later
        ),
        home: MapScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
