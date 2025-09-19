import 'package:flutter/material.dart';
import 'package:travel_app_mvp/main.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../utils/constants.dart';
import 'package:travel_app_mvp/models/location.dart';
import 'package:travel_app_mvp/services/location_service.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_mvp/widgets/location_marker.dart';
import 'package:travel_app_mvp/widgets/state_marker.dart';
import 'package:travel_app_mvp/widgets/info_card.dart';
import 'package:travel_app_mvp/widgets/state_info_card.dart';
import 'package:travel_app_mvp/widgets/toggle_bar.dart';
import 'package:travel_app_mvp/models/states.dart';
import 'package:travel_app_mvp/services/state_service.dart';
import 'package:travel_app_mvp/widgets/rio_location_marker.dart';
import 'package:travel_app_mvp/widgets/attraction_detail_page.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Location> locations = [];
  bool isLoading = true;
  String? errorMessage;
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  Map<String, Location> markerToLocationMap = {};
  String currentToggle = 'top20';
  Map<String, Uint8List> _markerCache = {};
  List<States> states = [];
  List<States> _cachedStates = []; // Add this
  bool _statesLoaded = false;
  PolygonAnnotationManager? polygonAnnotationManager;
  Map<String, States> polygonToStateMap = {};
  String? selectedStateAnnotationId;
  States? selectedState;
  Map<String, PolygonAnnotation> _polygonAnnotations = {};
  double currentZoom = 4.0;
  bool showRioToggle = false;
  static const double rioMinLat = -23.1;
  static const double rioMaxLat = -22.8;
  static const double rioMinLng = -43.8;
  static const double rioMaxLng = -43.1;
  bool _isZoomedIn = false;
  Location? _currentZoomedLocation;
  States? _currentZoomedState;

  @override
  void initState() {
    super.initState();
    _loadLocations('top20');
  }

  @override
  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    pointAnnotationManager = await mapboxMap.annotations
        .createPointAnnotationManager();
    polygonAnnotationManager = await mapboxMap
        .annotations // ADD THIS
        .createPolygonAnnotationManager(); // ADD THIS

    if (locations.isNotEmpty) {
      _addMarkersToMap();
    }
    if (states.isNotEmpty) {
      // ADD THIS
      _addStatesToMap(); // ADD THIS
    } // ADD THIS
  }

  void _onToggleChanged(String newToggle) {
    if (currentToggle == newToggle) {
      // Clicking the same button again - deselect and clear markers
      setState(() {
        currentToggle = 'none';
      });
      _clearAllMarkers();
    } else {
      // Clicking a different button - switch to new toggle
      setState(() {
        currentToggle = newToggle;
      });
      if (newToggle == 'states') {
        // ADD THIS
        _loadStates(); // ADD THIS
      } else {
        // ADD THIS
        _loadLocations(newToggle);
      } // ADD THIS
    }
  }

  Future<void> _clearMarkers() async {
    if (pointAnnotationManager != null) {
      await pointAnnotationManager!.deleteAll();
      markerToLocationMap.clear();
    }
  }

  Future<void> _clearAllMarkers() async {
    setState(() {
      locations = [];
      states = [];
    });
    await _clearMarkers();
    await _clearPolygons();
  }

  Future<void> _clearPolygons() async {
    if (polygonAnnotationManager != null) {
      await polygonAnnotationManager!.deleteAll();
      polygonToStateMap.clear();
    }
  }

  Future<void> _loadStates() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Use cached data if available
      if (_statesLoaded && _cachedStates.isNotEmpty) {
        setState(() {
          states = _cachedStates;
          locations = [];
          isLoading = false;
        });
      } else {
        // Load from database and cache
        final fetchedStates = await StateService.getBrazilStates();

        _cachedStates = fetchedStates;
        _statesLoaded = true;

        setState(() {
          states = fetchedStates;
          locations = [];
          isLoading = false;
        });
      }

      if (mapboxMap != null) {
        await _clearMarkers();
        await _clearPolygons();
        _addStatesToMap();
      }
    } catch (error) {
      print('DEBUG: Error in _loadStates(): $error');
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadLocations(String toggle) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      List<Location> fetchedLocations;

      switch (toggle) {
        case 'top20':
          fetchedLocations = await LocationService.getBrazilTop20();
          break;
        case 'rio': // Add this case
          fetchedLocations = await LocationService.getRioTop10();
          break;
        default:
          fetchedLocations = await LocationService.getBrazilTop20();
      }

      setState(() {
        locations = fetchedLocations;
        states = [];
        isLoading = false;
      });

      if (mapboxMap != null) {
        await _clearMarkers();
        await _clearPolygons();
        _addMarkersToMap();
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  void _addMarkersToMap() async {
    if (pointAnnotationManager == null || locations.isEmpty) return;

    for (final location in locations) {
      if (currentToggle == 'rio') {
        // CHANGE 1: Replace text-only with heart markers
        final position = location.position ?? 1;
        final cacheKey = '${currentToggle}_$position';

        if (!_markerCache.containsKey(cacheKey)) {
          _markerCache[cacheKey] =
              await RioLocationMarker.createSoftSquareMarker(
                position,
              ); // CHANGE 2: Use RioLocationMarker
        }

        final marker = _markerCache[cacheKey]!;

        PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
          geometry: Point(coordinates: location.positionCoordinates),
          textColor: Color(0xFF111827).toARGB32(),
          textOffset: [0.0, -2.0],
          image: marker,
          iconSize: 2.0,
        );

        final annotation = await pointAnnotationManager!.create(
          pointAnnotationOptions,
        );
        markerToLocationMap[annotation.id] = location;
      } else {
        // For top20: show markers as before (unchanged)
        final position = location.position ?? 1;
        final cacheKey = '${currentToggle}_$position';

        if (!_markerCache.containsKey(cacheKey)) {
          _markerCache[cacheKey] =
              await Top20LocationMarker.createSoftSquareMarker(position);
        }

        final marker = _markerCache[cacheKey]!;

        PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
          geometry: Point(coordinates: location.positionCoordinates),
          textColor: Color(0xFF111827).toARGB32(),
          textOffset: [0.0, -2.0],
          image: marker,
          iconSize: 2.0,
        );

        final annotation = await pointAnnotationManager!.create(
          pointAnnotationOptions,
        );
        markerToLocationMap[annotation.id] = location;
      }
    }

    pointAnnotationManager!.tapEvents(
      onTap: (annotation) {
        final location = markerToLocationMap[annotation.id];
        if (location != null) {
          _showLocationCard(location);
        }
      },
    );

    print('Added ${locations.length} locations to map');
  }

  void _addStatesToMap() async {
    if (polygonAnnotationManager == null ||
        pointAnnotationManager == null ||
        states.isEmpty)
      return;

    for (final state in states) {
      final polygonRings = state.boundaries;

      if (polygonRings.isNotEmpty) {
        PolygonAnnotationOptions polygonOptions = PolygonAnnotationOptions(
          geometry: Polygon(coordinates: polygonRings),
          fillColor: Color(
            0xFF10B981,
          ).withOpacity(0.4).value, // Success Green, more visible
          fillOpacity: 0.4,
          fillOutlineColor: Color(0xFF065F46).value, // Darker green border
        );

        final annotation = await polygonAnnotationManager!.create(
          polygonOptions,
        );
        polygonToStateMap[annotation.id] = state;
        _polygonAnnotations[annotation.id] = annotation;

        final cacheKey = '${currentToggle}_${state.name}';

        // Check cache first, create if not found
        if (!_markerCache.containsKey(cacheKey)) {
          _markerCache[cacheKey] = await StateMarker.createSoftSquareMarker(
            stateName: state.name,
          );
        }
        final stateMarkerBytes = _markerCache[cacheKey]!;

        // Add state name text OFFSET BELOW the icon
        PointAnnotationOptions textOptions = PointAnnotationOptions(
          geometry: Point(coordinates: state.positionCoordinates),
          textField: state.name,
          textSize: 14.0, // Slightly smaller
          textColor: Color(0xFF1F2937).value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 3,
        );

        await pointAnnotationManager!.create(textOptions);
      }
    }

    polygonAnnotationManager!.tapEvents(
      onTap: (annotation) async {
        final state = polygonToStateMap[annotation.id];
        if (state != null) {
          await _handleStateSelection(annotation.id, state);
          // TODO: _showStateCard(state); // Add this later
        }
      },
    );
  }

  Future<void> _handleStateSelection(String annotationId, States state) async {
    // If clicking the same state, deselect it and zoom back out
    if (selectedStateAnnotationId == annotationId) {
      await _resetState(annotationId, state);
      return;
    }

    // Reset previous selection
    if (selectedStateAnnotationId != null && selectedState != null) {
      await _resetState(selectedStateAnnotationId!, selectedState!);
    }

    // Highlight new selection and zoom in
    await _highlightState(annotationId, state);
    _showStateCard(state);
  }

  Future<void> _highlightState(String annotationId, States state) async {
    // Delete old polygon using tracked annotation
    final oldAnnotation = _polygonAnnotations[annotationId];
    if (oldAnnotation != null) {
      await polygonAnnotationManager!.delete(oldAnnotation);
      _polygonAnnotations.remove(annotationId);
    }

    // Create highlighted polygon
    PolygonAnnotationOptions highlightOptions = PolygonAnnotationOptions(
      geometry: Polygon(coordinates: state.boundaries),
      fillColor: Color(
        0xFF374151,
      ).withValues(alpha: 0.5).value, // Charcoal highlight
      fillOutlineColor: Color(0xFF1F2937).value, // Text Light for subtle border
    );

    final newAnnotation = await polygonAnnotationManager!.create(
      highlightOptions,
    );
    polygonToStateMap[newAnnotation.id] = state;
    _polygonAnnotations[newAnnotation.id] = newAnnotation; // Track it

    selectedStateAnnotationId = newAnnotation.id;
    selectedState = state;
    print('Selected: ${state.name}');
  }

  Future<void> _resetState(String annotationId, States state) async {
    // Delete highlighted polygon using tracked annotation
    final highlightedAnnotation = _polygonAnnotations[annotationId];
    if (highlightedAnnotation != null) {
      await polygonAnnotationManager!.delete(highlightedAnnotation);
      _polygonAnnotations.remove(annotationId);
    }

    // Create normal polygon
    PolygonAnnotationOptions normalOptions = PolygonAnnotationOptions(
      geometry: Polygon(coordinates: state.boundaries),
      fillColor: Color(
        0xFF10B981,
      ).withOpacity(0.4).value, // Success Green, more visible
      fillOpacity: 0.4,
      fillOutlineColor: Color(0xFF065F46).value, // Darker green border
    );

    final newAnnotation = await polygonAnnotationManager!.create(normalOptions);
    polygonToStateMap[newAnnotation.id] = state;
    _polygonAnnotations[newAnnotation.id] = newAnnotation;
    selectedStateAnnotationId = null;
    selectedState = null;
  }

  void _onCameraChangeListener(CameraChangedEventData data) async {
    if (mapboxMap != null) {
      try {
        final cameraState = await mapboxMap!.getCameraState();
        final zoom = cameraState.zoom;
        final center = cameraState.center;

        setState(() {
          currentZoom = zoom;
          showRioToggle =
              zoom > 9.0 &&
              center.coordinates.lat >= rioMinLat &&
              center.coordinates.lat <= rioMaxLat &&
              center.coordinates.lng >= rioMinLng &&
              center.coordinates.lng <= rioMaxLng;
        });
      } catch (e) {
        print('Error getting camera state: $e');
      }
    }
  }

  // ADD THIS METHOD - shows the info card
  void _showLocationCard(Location location) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      // No dark background
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
                    .animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: LocationInfoCard(
                  location: location,
                  listType: currentToggle == 'rio'
                      ? ListType.rioTop10
                      : ListType.brazilTop20,
                  onViewDetails: _handleViewDetails, // Add callback
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleViewDetails(Location location, ListType listType) {
    switch (listType) {
      case ListType.rioTop10:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttractionDetailPage(location: location),
          ),
        );
        break;
      case ListType.brazilTop20:
        _zoomIntoArea(location); // Your future zoom logic
        break;
    }
  }

  void _showStateCard(States state) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
                    .animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: StateInfoCard(
                  state: state,
                  onExploreLocations: _handleExploreState,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleExploreState(States state) {
    _zoomIntoState(state);
    // Later you could also load state-specific locations here
    setState(() {
      _isZoomedIn = true;
      _currentZoomedState = state;
      // You might want to track which state is zoomed for breadcrumb
    });
  }

  // Add this method to your MapScreen class
  Future<void> _zoomIntoArea(Location location) async {
    if (mapboxMap == null) return;

    try {
      // Define zoom levels based on location type
      double targetZoom;

      // You can customize zoom levels based on location characteristics
      if (location.name.toLowerCase().contains('rio')) {
        targetZoom = 11.0; // City level
      } else if (location.name.toLowerCase().contains('iguazu')) {
        targetZoom = 13.0; // Attraction level - closer
      } else if (location.name.toLowerCase().contains('pantanal')) {
        targetZoom = 8.0; // Region level - wider view
      } else {
        targetZoom = 10.0; // Default zoom
      }

      // Animate to the location
      await mapboxMap!.easeTo(
        CameraOptions(
          center: Point(coordinates: location.positionCoordinates),
          zoom: targetZoom,
          bearing: 0,
          pitch: 0,
        ),
        MapAnimationOptions(
          duration: 1500, // 1.5 second animation
        ),
      );

      print('Zoomed into ${location.name} at zoom level $targetZoom');
    } catch (e) {
      print('Error zooming to location: $e');
    }
    setState(() {
      _isZoomedIn = true;
      _currentZoomedLocation = location;
    });
  }

  Future<void> _zoomBackToOverview() async {
    if (mapboxMap == null) return;

    await mapboxMap!.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(-51.9253, -14.2350),
        ), // Brazil center
        zoom: 4.0,
        bearing: 0,
        pitch: 0,
      ),
      MapAnimationOptions(duration: 1200),
    );

    setState(() {
      _isZoomedIn = false;
      _currentZoomedLocation = null;
      _currentZoomedState = null;
    });
  }

  Future<void> _zoomIntoState(States state) async {
    if (mapboxMap == null) return;

    try {
      double targetZoom = 6.5; // State-level zoom

      await mapboxMap!.easeTo(
        CameraOptions(
          center: Point(coordinates: state.positionCoordinates),
          zoom: targetZoom,
          bearing: 0,
          pitch: 0,
        ),
        MapAnimationOptions(duration: 1500),
      );

      print('Zoomed into state: ${state.name}');
    } catch (e) {
      print('Error zooming to state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraOptions camera = CameraOptions(
      center: Point(coordinates: Position(-51.9253, -14.2350)), // Brazil center
      zoom: 4.0,
      bearing: 0,
      pitch: 0,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Brazil Travel Guide'),
        backgroundColor: Color(0xFF374151),
      ),
      body: Stack(
        // Change from just MapWidget to Stack
        children: [
          MapWidget(
            cameraOptions: camera,
            onMapCreated: _onMapCreated,
            onCameraChangeListener: _onCameraChangeListener,
          ),
          // Add toggle bar positioned in top-right
          Positioned(
            top: 0,
            right: 0,
            child: ToggleBar(
              selectedToggle: currentToggle,
              onToggleChanged: _onToggleChanged,
              showRioToggle: showRioToggle,
            ),
          ),
          if (_isZoomedIn &&
              (_currentZoomedLocation != null || _currentZoomedState != null))
            Positioned(
              top: 50,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _zoomBackToOverview,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: Color(0xFF374151),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Back to Brazil Overview",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
