import 'package:flutter/material.dart';

import '../drawer/drawer_screen.dart';
import '../map/map_screen_.dart';



class TabBox extends StatefulWidget {
  const TabBox({Key? key}) : super(key: key);

  @override
  State<TabBox> createState() => _TabBoxState();
}

class _TabBoxState extends State<TabBox> {

  List<Widget> screens = [DrawerScreen(), MapScreen()];

  int currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
