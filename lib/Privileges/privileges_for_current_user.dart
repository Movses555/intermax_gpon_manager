class PrivilegesForCurrentUser{

  static var ADD_OLT = true;
  static var ADD_USERS = true;
  static var CHANGE_CATV = true;
  static var DELETE_GPON = true;
  static var CHANGE_REASONS = true;
  static var SEE_OLT_DEVICES = true;
  static var CHANGE_PASSWORDS = true;
  static var CHANGE_PRIVILEGES = true;
  static var CHANGE_PORT_DESCRIPTION = true;

  static void clear(){
    ADD_OLT = true;
    ADD_USERS = true;
    CHANGE_CATV = true;
    DELETE_GPON = true;
    CHANGE_REASONS = true;
    SEE_OLT_DEVICES = true;
    CHANGE_PASSWORDS = true;
    CHANGE_PRIVILEGES = true;
    CHANGE_PORT_DESCRIPTION = true;
  }
}