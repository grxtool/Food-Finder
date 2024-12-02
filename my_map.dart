import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key, required this.title});

  final String title;

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: const RestaurantMap(),
    );
  }
}

class RestaurantMap extends StatelessWidget {
  const RestaurantMap({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(8.482727, 123.806390), // Initial center point
        initialZoom: 15, // Initial zoom level
        interactionOptions: InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleatflet.flutter_map.example',
        ),
        const MarkerLayer(
          markers: [
            Marker(
              point: LatLng(8.482727, 123.806390),
              width: 100,
              height: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sweet Marias Pizza House',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Icon(
                    Icons.location_pin,
                    size: 40,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
