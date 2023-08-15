import 'package:flutter/material.dart';

import '../map/map_screen_.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({
    super.key,
  });

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green[700],
          title: const Text('Drawer screen')),
      backgroundColor: Colors.white,
      body: const Center(
          child: Text(
        'Drawer screen',
        style: TextStyle(color: Colors.black),
      )),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[700],
              ),
              child: const Text(
                'Map',
                style: TextStyle(color: Colors.white),
              ),
            ),

            // Container(
            //   child: Text('Home'),
            // ),
            ListTile(
              title: const Text('Home'),
              // selected: _selectedIndex == 0,

              onTap: () {

                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Map'),
              // selected: _selectedIndex == 1,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
                //   _onItemTapped(1);

                //  Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Save'),
              onTap: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}
