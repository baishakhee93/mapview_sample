import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_maps_webservice/places.dart' as Places;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapViewWithTracking(),
    );
  }
}

class MapViewWithTracking extends StatefulWidget {
  @override
  _MapViewWithTrackingState createState() => _MapViewWithTrackingState();
}

class _MapViewWithTrackingState extends State<MapViewWithTracking> {
  GoogleMapController? _controller;
  late Location _location;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _location = Location();
    _location.onLocationChanged.listen((LocationData currentLocation) {
      // Update marker position when the location changes
      _updateMarker(LatLng(currentLocation.latitude!, currentLocation.longitude!));
    });
  }
  //
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  Future<void> _searchPlaces(String query) async {
    final places = Places.GoogleMapsPlaces(apiKey: "YOUR_GOOGLE_MAPS_API_KEY");
    try {
      Places.PlacesSearchResponse response = await places.searchByText(query);
      if (response.isOkay) {
        print("Search results count: ${response.results.length}");
        if (response.results.isNotEmpty) {
          print("First result: ${response.results[0].name}");
          _updateMarker(
            LatLng(
              response.results[0].geometry!.location.lat,
              response.results[0].geometry!.location.lng,
            ),
          );
        } else {
          print("No results found");
        }
      } else {
        print("Error in search response: ${response.errorMessage}");
      }
    } catch (e) {
      print("Error during search: $e");
    }
  }


  void _updateMarker(LatLng latLng) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId("currentLocation"),
          position: latLng,
          infoWindow: InfoWindow(title: "Current Location"),
        ),
      );
      // Move the camera to the updated position
      _controller?.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map View"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch<String>(
                context: context,
                delegate: _SearchDelegate(),
              );
              if (query != null) {
                await _searchPlaces(query);
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 15,
        ),
        myLocationEnabled: true,
        markers: _markers,
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement the results page if needed
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement suggestions while typing if needed
    return Container();
  }
}
