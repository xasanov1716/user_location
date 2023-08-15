import 'package:flutter/cupertino.dart';

import '../data/local/local_db.dart';
import '../model/user_address.dart';

class UserLocationsProvider with ChangeNotifier {
  List<UserAddress> addresses = [];

  UserLocationsProvider() {
    getUserAddresses();
  }

  getUserAddresses() async {
    addresses = await LocalDatabase.getAllUserAddresses();
    print("CURRENT LENGTH:${addresses.length}");
    notifyListeners();
  }

  insertUserAddress(UserAddress userAddress) async {
    await LocalDatabase.insertUserAddress(userAddress);
    getUserAddresses();
    notifyListeners();
  }

  deleteUserAddress(int id) async {
    await LocalDatabase.deleteUserAddress(id);
    getUserAddresses();
    print(getUserAddresses());
  }
}
