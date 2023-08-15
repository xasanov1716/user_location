import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_locations/ui/map/widgets/address_kind_selector.dart';
import 'package:user_locations/ui/map/widgets/address_lang_selector.dart';
import 'package:user_locations/ui/map/widgets/save_button.dart';
import 'package:user_locations/utils/utilitiy_function.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../model/user_address.dart';
import '../../provider/address_call_provider.dart';
import '../../provider/location_provider.dart';
import '../../provider/user_locations_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

Set<Marker> markers = {};



class MapScreenState extends State<MapScreen> {
  late CameraPosition initralCamreaPosition;
  late CameraPosition currentCameraPosition;
  bool onCameraMoveStarted = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  MapType _type = MapType.none;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _counter;

  // ignore: unused_field
  static const LatLng _center = LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _mapControll({required double lat, required double lot}) {
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    initralCamreaPosition = CameraPosition(target: LatLng(lat, lot), zoom: 15);
    currentCameraPosition = CameraPosition(target: LatLng(lat, lot), zoom: 15);

    locationProvider.updateLatLong(LatLng(lot, lat));
    _followDateMove(cameraPosition: currentCameraPosition);
    setState(() {});
  }

  Future<void> _mapType(int count) async {
    final SharedPreferences prefs = await _prefs;
    int mapTypeInt = (prefs.getInt('maptype') ?? 0);
    mapTypeInt = count;
    debugPrint(mapTypeInt.toString());

    setState(() {
      _counter = prefs.setInt('maptype', mapTypeInt).then((bool success) {
        return mapTypeInt;
      });
    });
  }

  initLocation(){
    context.read<LocationProvider>().getLocation();
  }

  @override
  void initState() {
    initLocation();
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    initralCamreaPosition =
        CameraPosition(target: locationProvider.latLong!, zoom: 13);
    currentCameraPosition =
        CameraPosition(target: locationProvider.latLong!, zoom: 13);
    super.initState();
    late int maytypeint;
    _counter = _prefs.then((SharedPreferences prefs) {
      maytypeint = prefs.getInt('maptype') ?? 0;
      if (maytypeint == 0) {
        setState(() {
          _type = MapType.hybrid;
        });
      } else if (maytypeint == 1) {
        setState(() {
          _type = MapType.terrain;
        });
      } else {
        setState(() {
          _type = MapType.normal;
        });
      }
      return _counter;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<UserAddress> userAddresses =
        Provider.of<UserLocationsProvider>(context).addresses;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Map',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(children: [
        GoogleMap(

            // onCameraMove: (CameraPosition cameraPosition) {
            //   currentCameraPosition = cameraPosition;
            // },
            onCameraIdle: () {
              debugPrint(
                  "CURRENT CAMERA POSITION : ${currentCameraPosition.target.latitude}");
              context
                  .read<AddressCallProvider>()
                  .getAddressByLatLong(latLng: currentCameraPosition.target);
              setState(() {
                onCameraMoveStarted = false;
              });
              debugPrint('Move finished');
            },
            onLongPress: (latLng) {
              addMarker(latLng);
            },
            markers: markers,
            onCameraMove: (CameraPosition cameraPosition) {
              currentCameraPosition = cameraPosition;
            },
            liteModeEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            mapType: _type,
            onCameraMoveStarted: () {
              setState(() {
                onCameraMoveStarted = true;
              });
              debugPrint('Move Started');
            },
            onMapCreated: _onMapCreated,
            initialCameraPosition: initralCamreaPosition),
        Align(
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: onCameraMoveStarted ? 50 : 32,
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          top: 10,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),

              color: Colors.transparent,
            ),
            child: Center(
              child: Text(
                context.watch<AddressCallProvider>().scrolledAddressText,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 100,
          right: 100,
          child: Visibility(
            visible: context.watch<AddressCallProvider>().canSaveAddress(),
            child: SaveButton(onTap: () {
              AddressCallProvider adp =
                  Provider.of<AddressCallProvider>(context, listen: false);
              context.read<UserLocationsProvider>().insertUserAddress(
                  UserAddress(
                      lat: currentCameraPosition.target.latitude,
                      long: currentCameraPosition.target.longitude,
                      address: adp.scrolledAddressText,
                      created: DateTime.now().toString()));
            }),
          ),
        ),
      ]),
      endDrawer: Container(
        height: double.infinity,
        width: 300,
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
             Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                AddressKindSelector(),
                SizedBox(
                  width: 20,
                ),
                AddressLangSelector(),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  if (userAddresses.isEmpty) const Text("EMPTY!!!"),
                  ...List.generate(userAddresses.length, (index) {
                    UserAddress userAddress = userAddresses[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (v) {
                              setState(() {
                                context
                                    .read<UserLocationsProvider>()
                                    .deleteUserAddress(userAddresses[index].id!.toInt());
                              });
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_sharp,
                            label: 'Delate',
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ZoomTapAnimation(
                            onTap: () {
                              context
                                  .read<AddressCallProvider>()
                                  .getAddressByLatLong(
                                      latLng: LatLng(
                                          userAddress.lat, userAddress.long));

                              context.read<LocationProvider>().updateLatLong(
                                  LatLng(userAddress.lat, userAddress.long));
                              _mapControll(
                                  lat: userAddress.lat, lot: userAddress.long);
                              _followDateMove(
                                  cameraPosition: currentCameraPosition);
                              Navigator.pop(context);
                            },
                            child: Center(
                              child: Container(
                                height: 90,
                                width: 260,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        userAddress.address,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _followMe(cameraPosition: initralCamreaPosition);
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.fmd_good_sharp),
      ),
    );
  }

  Future<void> _followMe({required CameraPosition cameraPosition}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> _followDateMove({required CameraPosition cameraPosition}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  addMarker(LatLng latLng) async {
    Uint8List uint8list = await getBytesFromAsset("assets/images/google_pin.png", 150);
    markers.add(Marker(
        markerId: MarkerId(
          'marker1',
        ),
        position: latLng,
        icon: BitmapDescriptor.fromBytes(uint8list),
        //BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(
            title: 'Toshkent', snippet: "Falonchi Ko'chasi 45-uy ")));
    setState(() {});
  }


}
