import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:convert';

class States {
  final int id;
  final int countryId;
  final String name;
  final String description;
  final String coordinate;
  final String geometry;
  final String? imageUrl;

  States({
    required this.id,
    required this.countryId,
    required this.name,
    required this.description,
    required this.coordinate,
    required this.geometry,
    this.imageUrl,
  });

  Position get positionCoordinates {
    final coords = coordinate.split(',');
    return Position(
      double.parse(coords[1].trim()), // longitude
      double.parse(coords[0].trim()), // latitude
    );
  }

  List<List<Position>> get boundaries {
    try {
      final Map<String, dynamic> geoJson = json.decode(geometry);
      final String type = geoJson['type'] ?? '';
      final dynamic coordinates = geoJson['coordinates'];

      if (coordinates == null) return [];

      if (type == 'Polygon') {
        // Simplify polygon by taking every nth point to reduce complexity
        return [_simplifyCoordinates(coordinates[0])];
      } else if (type == 'MultiPolygon') {
        List<List<Position>> allPolygons = [];
        for (var polygon in coordinates) {
          if (polygon.isNotEmpty && polygon[0] != null) {
            allPolygons.add(_simplifyCoordinates(polygon[0]));
          }
        }
        return allPolygons;
      }
      return [];
    } catch (e) {
      print('Error parsing geometry for ${name}: $e');
      return [];
    }
  }

  // Add this helper method to reduce coordinate points
  List<Position> _simplifyCoordinates(List coordinates) {
    if (coordinates.length <= 50)
      return coordinates
          .map<Position>(
            (coord) => Position(coord[0].toDouble(), coord[1].toDouble()),
          )
          .toList();

    // Take every 3rd point to reduce complexity by ~66%
    List<Position> simplified = [];
    for (int i = 0; i < coordinates.length; i += 3) {
      simplified.add(
        Position(coordinates[i][0].toDouble(), coordinates[i][1].toDouble()),
      );
    }
    return simplified;
  }

  factory States.fromJson(Map<String, dynamic> json) {
    // Handle the Center field that comes as separate numbers
    String centerString = '';
    final center = json['Center'];
    if (center != null) {
      centerString = center.toString().replaceAll(' ', '');
    } else {
      centerString = '0,0';
    }

    return States(
      id: json['id'],
      countryId: json['Countries_id'],
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      coordinate: centerString,
      geometry: jsonEncode(json['geometry']), // Convert Map to JSON string
      imageUrl: json['Image_url'],
    );
  }
}
