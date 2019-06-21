import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as location;
import 'package:map_view/map_view.dart';

import '../../models/location.dart';
import '../../models/product.dart';
import '../../shared/global_config.dart';
import '../helpers/ensure-visible.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  Uri _staticMapUri;
  LocationData _location;
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      _getStaticMap(
        widget.product.location.address,
        geocode: false,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(
    String address, {
    bool geocode = true,
    double latitude,
    double longitude,
  }) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {
          'address': address,
          'key': apiKey,
        },
      );
      final http.Response response = await http.get(uri);
      final Map<String, dynamic> addressData = json.decode(response.body);
      final String formattedAddress =
          addressData['results'][0]['formatted_address'];
      final Map<String, dynamic> coordinates =
          addressData['results'][0]['geometry']['location'];
      _location = LocationData(
        latitude: coordinates['lat'],
        longitude: coordinates['lng'],
        address: formattedAddress,
      );
    } else if (latitude == null && longitude == null) {
      _location = widget.product.location;
    } else {
      _location = LocationData(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
    }
    final StaticMapProvider staticMapProvider =
        StaticMapProvider(apiKey);
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers(
      [
        Marker(
          'position',
          'Position',
          _location.latitude,
          _location.longitude,
        ),
      ],
      center: Location(
        _location.latitude,
        _location.longitude,
      ),
      width: 500,
      height: 300,
      maptype: StaticMapViewType.roadmap,
    );
    widget.setLocation(_location);
    setState(() {
      _addressInputController.text = _location.address;
      _staticMapUri = staticMapUri;
    });
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    final Uri uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '${latitude.toString()},${longitude.toString()}',
        'key': apiKey,
      },
    );
    final http.Response response = await http.get(uri);
    final responseData = json.decode(response.body);
    final formattedAddress = responseData['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _getUserLocation() async {
    final location.Location currentLocation = location.Location();
    try {
      final location.LocationData currentLocationData =
          await currentLocation.getLocation();
      final String address = await _getAddress(
        currentLocationData.latitude,
        currentLocationData.longitude,
      );
      _getStaticMap(
        address,
        geocode: false,
        latitude: currentLocationData.latitude,
        longitude: currentLocationData.longitude,
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Error'),
            content: Text('Please add an address manually.'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            validator: (String value) {
              if (_location == null || value.isEmpty) {
                return 'No valid location found.';
              }
            },
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        FlatButton(
          child: Text('Locate User'),
          onPressed: _getUserLocation,
        ),
        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString()),
      ],
    );
  }
}
