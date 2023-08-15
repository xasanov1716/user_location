import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w300),
        shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        shadowColor: Colors.lightBlue,
      ),
      onPressed: onTap,
      child: const Text('Save'),
    );
  }
}





// RaisedGradientButton(
//       gradient: const LinearGradient(
//         colors: [Color(0xff00bcd4), Color(0xff2196f3)],
//         stops: [0, 1],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       onPressed: onTap,
//       height: 50,
//       width: 200,
//       child: const Text('Save'),
//     );