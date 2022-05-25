import 'dart:convert';
import 'dart:ffi';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapgoogle/directions_model.dart';
import 'package:mapgoogle/directions_repository.dart';
import 'package:mapgoogle/latlngrepository.dart';
import'package:flutter/services.dart'as rootBundle;


class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-17.783043629108434, -63.18211937034582),
    // target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  GoogleMapController? _googleMapController;

  Marker? _origin;
  Marker? _destination;

  Directions? _info; 
  List<LatLng> latlng = []; //list for lat and long values 




  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text('mapa', style: TextStyle(color: Colors.black)),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: _originCenter,
              style: TextButton.styleFrom(
                  primary: Colors.green,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600)),
              child: const Text('Origen'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: _destinationCenter,
              style: TextButton.styleFrom(
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600)),
              child: const Text('Destino'),
            )
        ],
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _googleMapController = controller,
        markers: {
          if (_origin != null) _origin!,
          if (_destination != null) _destination!
        },
        polylines: {
          if(_info !=null)
          Polyline(
            polylineId: const PolylineId('overview_polyline'),
            color:  Colors.red,
            width: 5,
            points: _info!.polylinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
          )
        },
        onLongPress: _addMarker,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centermap,
        child: Icon(Icons.map_outlined),
      ),
    );
  }

  void _centermap() {
    _googleMapController?.animateCamera(
      //CameraUpdate.newCameraPosition(_initialCameraPosition),
      _info != null 
      ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
      : CameraUpdate.newCameraPosition(_initialCameraPosition),    
    );
  }

  void _addMarker(LatLng pos) async{
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origen'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        _destination = null;

        _info = null;
      });
    } else {
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });
      // Get directions
      final directions=await DirectionsRepository()
         .getDirections(origin:_origin!.position,destination:pos);
      setState(()=>_info=directions);
    }
  }

  void _originCenter() {
    if (_origin != null) {
      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          // if( _origin != null){
          CameraPosition(
            target: _origin!.position,
            zoom: 16,
            tilt: 50.0,
          ),
          //}
        ),
      );
    }
  }

  //
  void _destinationCenter() {
    if (_destination != null) {
      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _destination!.position,
            zoom: 16,
            tilt: 50.0,
          ),
        ),
      );
    }
  }

  
    void _fillList() async{//deberia cargar otra lista solo con latitud y longitud
    if(latlng.isNotEmpty){
      latlng.clear();//limpia la lista si es que tiene datos
      }
      Future<List<latilong>> jsonlist= ReadjsonData();
      List jsonlistData = await jsonlist;
      if(jsonlistData.isNotEmpty)
      
      latlng.add(jsonlistData[]);

    
    }
    Future<List<latilong>> ReadjsonData() async{ //lee losdatos del json local y los pasa a una lista
      final jsondata = await rootBundle.rootBundle.loadString('assets/L01I.json');
      final list = jsonDecode(jsondata) as List<dynamic>;
      return list.map((e) => latilong.fromJson(e)).toList();

    }












}
