import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class Location {
  final int id;
  final int countryId;
  final int stateId;
  final int? cityId;
  final String name;
  final String coordinate;
  final String description;
  final String category;
  final String? imageUrl;
  final int? position;

  Location({
    required this.id,
    required this.countryId,
    required this.stateId,
    this.cityId,
    required this.name,
    required this.coordinate,
    required this.description,
    required this.category,
    this.imageUrl,
    this.position,
  });

  Position get positionCoordinates {
    final coords = coordinate.split(',');
    return Position(
      double.parse(coords[1].trim()), // longitude
      double.parse(coords[0].trim()), // latitude
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      countryId: json['Countries_id'],
      stateId: json['States_id'],
      cityId: json['Cities_id'],
      name: json['Name'],
      coordinate: json['Center'],
      description: json['Description'],
      category: json['Category'],
      imageUrl: json['Image_url'],
      position: json['position'],
    );
  }
}
