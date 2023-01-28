
import 'package:intermax_gpon_manager/API/gpon_manager_api.dart';
import 'package:intermax_gpon_manager/Data%20Models/Privileges%20Data%20Model/privileges_data_model.dart';
import 'package:intermax_gpon_manager/Privileges/privileges_constants.dart';
import 'package:intermax_gpon_manager/Privileges/privileges_for_current_user.dart';
import 'package:intermax_gpon_manager/Shared%20Preferences/sh_prefs.dart';

class Privileges{

  static var privileges;
  static var _ip;

  static Privileges createInstance(){
    privileges ??= Privileges();

    return privileges;
  }

  Future getPrivileges(String ip, String name) async {
    _ip = ip;
    var data = {'ip' : ip, 'name' : name};
    return Future.wait([
      _getPrivileges(data)
    ]);
  }


  Future getPrivilegesForCurrentUser(String name) async {
    var data = {'ip' : SavedUserData.getIP(), 'name' : name};
    return Future.wait([
      API.create(SavedUserData.getIP()!, 6).getPrivileges(data)
    ]).then((value){
      PrivilegesModel? privilegesModel = value[0].body;
      if(privilegesModel != null){
        PrivilegesForCurrentUser.ADD_OLT = privilegesModel.addOlt;
        PrivilegesForCurrentUser.ADD_USERS = privilegesModel.addUsers;
        PrivilegesForCurrentUser.CHANGE_CATV = privilegesModel.changeCATV;
        PrivilegesForCurrentUser.DELETE_GPON = privilegesModel.deleteGPON;
        PrivilegesForCurrentUser.CHANGE_REASONS = privilegesModel.changeReasons;
        PrivilegesForCurrentUser.SEE_OLT_DEVICES = privilegesModel.seeOLTDevices;
        PrivilegesForCurrentUser.CHANGE_PASSWORDS = privilegesModel.changePasswords;
        PrivilegesForCurrentUser.CHANGE_PRIVILEGES = privilegesModel.changePrivileges;
        PrivilegesForCurrentUser.CHANGE_PORT_DESCRIPTION = privilegesModel.changePortDescription;
      }else{
        PrivilegesForCurrentUser.clear();
      }
    });
  }


  Future _getPrivileges(var data) async {
    return Future.wait([
      API.create(SavedUserData.getIP()!, 6).getPrivileges(data)
    ]).then((value){
      PrivilegesModel? privilegesModel = value[0].body;
      if(privilegesModel != null){
        PrivilegesConstants.ADD_OLT = privilegesModel.addOlt;
        PrivilegesConstants.ADD_USERS = privilegesModel.addUsers;
        PrivilegesConstants.CHANGE_CATV = privilegesModel.changeCATV;
        PrivilegesConstants.DELETE_GPON = privilegesModel.deleteGPON;
        PrivilegesConstants.CHANGE_REASONS = privilegesModel.changeReasons;
        PrivilegesConstants.SEE_OLT_DEVICES = privilegesModel.seeOLTDevices;
        PrivilegesConstants.CHANGE_PASSWORDS = privilegesModel.changePasswords;
        PrivilegesConstants.CHANGE_PRIVILEGES = privilegesModel.changePrivileges;
        PrivilegesConstants.CHANGE_PORT_DESCRIPTION = privilegesModel.changePortDescription;
      }
    });
  }
}