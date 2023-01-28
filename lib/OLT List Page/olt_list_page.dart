import 'dart:convert';
import 'package:chopper/chopper.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:intermax_gpon_manager/API/gpon_manager_api.dart';
import 'package:intermax_gpon_manager/Data%20Models/CATV%20Data%20Model/catv_data_model.dart';
import 'package:intermax_gpon_manager/Data%20Models/GPON%20Device%20Model/GPON%20Data%20Model.dart';
import 'package:intermax_gpon_manager/Data%20Models/Note%20Data%20Model/note_data_model.dart';
import 'package:intermax_gpon_manager/Data%20Models/User%20Data%20Model/user_data_model.dart';
import 'package:intermax_gpon_manager/OLT%20API/olt_api.dart';
import 'package:intermax_gpon_manager/Privileges/privileges.dart';
import 'package:intermax_gpon_manager/Privileges/privileges_constants.dart';
import 'package:intermax_gpon_manager/Privileges/privileges_for_current_user.dart';
import 'package:intermax_gpon_manager/Shared%20Preferences/sh_prefs.dart';
import 'package:intermax_gpon_manager/main.dart';
import 'package:intl/intl.dart';

import '../Data Models/Disconnect Reason Model/disconnect_reason_model.dart';
import '../Data Models/OLT Data Model/olt_data_model.dart';

class OltListPage extends StatefulWidget{

  @override
  _OltListPageState createState() => _OltListPageState();
}

class _OltListPageState extends State<OltListPage>{

  late double height;
  late double width;

  late StateSetter oltDialogState;
  late StateSetter oltState;

  late OltDevice initialOltDevice;
  late StateSetter dataTableState;
  late StateSetter disconnectReasonsState;
  late Privileges privileges;

  final TextEditingController _oltIpController = TextEditingController();
  final TextEditingController _oltUsernameController = TextEditingController();
  final TextEditingController _oltPasswordController = TextEditingController();
  final TextEditingController _oltDescriptionController = TextEditingController();

  final TextEditingController _disconnectReasonController = TextEditingController();

  final TextEditingController _newUserIpTextController = TextEditingController();
  final TextEditingController _newUserNameTextController = TextEditingController();
  final TextEditingController _newUserPassTextController = TextEditingController();

  final TextEditingController _newPasswordTextController = TextEditingController();

  bool isOltIpFieldEmpty = false;
  bool isOltNameFieldEmpty = false;
  bool isOltPassFieldEmpty = false;

  bool incorrectOltData = false;
  bool isOltConnected = false;
  bool isOltExists = false;

  bool isDataLoaded = false;
  bool isCatvLoaded = false;

  bool isAscending = false;

  bool isFirstRun = true;

  bool noDevices = false;

  bool isConfigSaved = true;

  List<OltDevice> oltDeicesList = [];
  List<GPONDevice>? gponDevicesList = [];
  List<GPONDevice>? gponDevicesFilteredList = [];
  List<CATVDataModel>? gponCATVDataList = [];
  List<NoteDataModel>? gponNoteDataList = [];

  List<String> gponDataStringList = [];
  List<String> rxPowerStringList = [];
  List<String> catvStatusStringList = [];

  List<DisconnectReasonModel>? disconnectReasonsList = [];

  Map<String, List<GPONDevice>>? gponDevicesMap = {};

  double _x = 0.0;
  double _y = 0.0;
  double _right = 0.0;
  double _bottom = 0.0;

  double progress = 0.0;

  int? sortColumnIndex;

  var formatter = DateFormat('dd.MM.yyyy');

  @override
  void initState() {


    initialOltDevice = OltDevice();
    privileges = Privileges.createInstance();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      refreshOlt();

      if(oltDeicesList.isNotEmpty){
        initialOltDevice = oltDeicesList.first;
      }
    });


    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('Закрыть приложение ?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Нет')),

                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Да', style: TextStyle(color: Colors.red))),
                ]);
          });
    });

    super.initState();
  }

  @override
  void dispose() {
    _oltIpController.dispose();
    _oltUsernameController.dispose();
    _oltPasswordController.dispose();
    _oltDescriptionController.dispose();
    _disconnectReasonController.dispose();
    _newUserIpTextController.dispose();
    _newUserNameTextController.dispose();
    _newUserPassTextController.dispose();
    _newPasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        return Scaffold(
          appBar: AppBar(
            title: Text('INTERMAX GPON Manager'),
            centerTitle: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurpleAccent, Colors.lightBlue]),
              ),
              child: Center(
                child: StatefulBuilder(
                  builder: (context, setState){
                    oltState = setState;
                    return oltDeicesList.isNotEmpty ? DropdownButton<String>(
                        value: initialOltDevice.ip,
                        iconEnabledColor: Colors.white,
                        underline: Container(),
                        style: TextStyle(color: Colors.white),
                        dropdownColor: Colors.blueAccent,
                        onChanged: (value) async {
                          setState((){
                            initialOltDevice = OltDevice();
                            initialOltDevice.ip = value!;

                            initialOltDevice = oltDeicesList.where((element) => element.ip == value).first;
                          });

                          if(gponDevicesMap!.containsKey(initialOltDevice.ip)){
                            gponDevicesFilteredList!.clear();

                            gponDevicesFilteredList = List.from(gponDevicesMap![initialOltDevice.ip]!);
                            gponDevicesList = List.from(gponDevicesFilteredList!);

                            dataTableState((){});
                          }else{
                            refreshOlt();
                          }

                          getGPONDataFromSQL();
                        },

                        items: oltDeicesList.map<DropdownMenuItem<String>>((olt) {
                          return DropdownMenuItem(
                            value: olt.ip,
                            child: Text(olt.ip + (olt.description != '' ? "  (${olt.description})" : '')),
                          );
                        }).toList()
                    ) : Text('Нет OLT', style: TextStyle(color: Colors.white));

                  },
                )
              ),
            ),
            actions: [
              Container(
                height: 30,
                width: 400,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: TextFormField(
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: 'Поиск...',
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      )
                  ),
                  onChanged: (value) {
                    dataTableState(() {
                      gponDevicesFilteredList = gponDevicesList!.where((device) =>
                      device.gponName.toString().toLowerCase().contains(value.toLowerCase()) ||
                          device.ponName.toString().toLowerCase().contains(value.toLowerCase()) ||
                          device.sn.toString().toLowerCase().contains(value.toLowerCase()) ||
                          device.rxPower.toString().toLowerCase().contains(value.toLowerCase()) ||
                          device.portDescription.toString().toLowerCase().contains(value.toLowerCase()) ||
                          device.getReason.toString().toLowerCase().contains(value.toLowerCase()) ||
                          device.getDate.toString().toLowerCase().contains(value.toLowerCase()) ||
                          device.getAdmin.toString().toLowerCase().contains(value.toLowerCase()) ||
                          device.getNote.toString().toLowerCase().contains(value.toLowerCase())).toList();
                    });
                  },
                ),
              ),
              StatefulBuilder(
                builder: (context, setState){
                  return isConfigSaved ? IconButton(
                      icon: Icon(Icons.save, color: Colors.white),
                      onPressed: () async {
                        isConfigSaved = false;
                        setState((){});

                        String username = initialOltDevice.username;
                        String password = initialOltDevice.password;

                        String credentials = '$username:$password';
                        String encodedCredentials = 'Basic ${base64Encode(utf8.encode(credentials))}';

                        Map<String, int> data = {
                          'write' : 1
                        };
                        await OltApi.create(initialOltDevice.ip).saveAll(encodedCredentials, data).then((value){
                          print(value);
                          isConfigSaved = true;
                          setState((){});
                        });
                      }
                  ) : Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  );
                },
              ),
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AuthPage())
                    );
                  }
              ),
              IconButton(
                icon: Icon(CupertinoIcons.refresh),
                onPressed: () => refreshOlt()
              ),
              PrivilegesConstants.ADD_USERS ? IconButton(
                icon: Icon(CupertinoIcons.person_add_solid, color: Colors.white),
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (context){
                        return SimpleDialog(
                          contentPadding: const EdgeInsets.all(20),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Зарегистрировать пользователя'),
                              IconButton(
                                icon: Icon(Icons.close_sharp),
                                onPressed: () => Navigator.pop(context),
                              )
                            ],
                          ),
                          children: [
                            SizedBox(
                              height: 50,
                              width: 400,
                              child: TextFormField(
                                controller: _newUserIpTextController,
                                decoration: InputDecoration(
                                  hintText: 'IP',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey)
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 50,
                              width: 400,
                              child: TextFormField(
                                controller: _newUserNameTextController,
                                decoration: InputDecoration(
                                  hintText: 'Имя',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey)
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 50,
                              width: 400,
                              child: TextFormField(
                                controller: _newUserPassTextController,
                                decoration: InputDecoration(
                                  hintText: 'Пароль',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey)
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            FloatingActionButton.extended(
                              label: Text('Зарегистрировать'),
                              backgroundColor: Colors.blueAccent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              onPressed: () async {

                                if(_newUserIpTextController.text.isEmpty || _newUserNameTextController.text.isEmpty || _newUserPassTextController.text.isEmpty){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Заполните поля', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.red));
                                }else{
                                  var data = {
                                    'ip' : _newUserIpTextController.text,
                                    'name' : _newUserNameTextController.text,
                                    'password' : _newUserPassTextController.text
                                  };

                                  await API.create(SavedUserData.getIP()!, 0).registerUser(data).then((value){
                                    if(value.body == 'user_already_exists'){
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пользователь с таким именем уже существует', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.red));
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Успешно', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.green));
                                      Navigator.pop(context);

                                      _newUserIpTextController.clear();
                                      _newUserNameTextController.clear();
                                      _newUserPassTextController.clear();
                                    }
                                  });
                                }
                              },
                            )
                          ],
                        );
                      }
                  );
                },
              ) : SizedBox(),
              PrivilegesConstants.ADD_OLT ? IconButton(
                icon: Icon(Icons.add),
                onPressed: () => showOltSignInDialog(),
              ) : SizedBox(),
              PopupMenuButton(
                icon: Icon(Icons.settings),
                tooltip: 'Настройки',
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: PrivilegesConstants.SEE_OLT_DEVICES ? 1 : null,
                    child: Text('Устройства OLT', style: TextStyle(color: PrivilegesConstants.SEE_OLT_DEVICES ? Colors.black : Colors.grey)),
                  ),
                  PopupMenuItem(
                    value: PrivilegesConstants.CHANGE_REASONS ? 2 : null,
                    child: Text('Причины отключения', style: TextStyle(color: PrivilegesConstants.CHANGE_REASONS ? Colors.black : Colors.grey)),
                  ),
                  PopupMenuItem(
                    value: PrivilegesConstants.CHANGE_PASSWORDS ? 3 : null,
                    child: Text('Изменить пароль', style: TextStyle(color: PrivilegesConstants.CHANGE_PASSWORDS ? Colors.black : Colors.grey)),
                  ),
                  PopupMenuItem(
                    value: PrivilegesConstants.CHANGE_PRIVILEGES ? 4 : null,
                    child: Text('Изменить привилегии', style: TextStyle(color: PrivilegesConstants.CHANGE_PRIVILEGES ? Colors.black : Colors.grey)),
                  ),
                ],
                onSelected: (value) async {
                  switch(value){
                    case 1:
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context){
                            return SimpleDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Устройства OLT'),
                                  IconButton(
                                    icon: Icon(Icons.close_sharp),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              ),
                              children: [
                                SizedBox(
                                  height: 400,
                                  width: 800,
                                  child: getOltDevices(),
                                )
                              ],
                            );
                          }
                      );
                      break;
                    case 2:
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context){
                          return SimpleDialog(
                            contentPadding: const EdgeInsets.all(20),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Причины отключения'),
                                IconButton(
                                  icon: Icon(Icons.close_sharp),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _disconnectReasonController,
                                      decoration: InputDecoration(
                                        hintText: 'Причина отключения',
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey)
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  FloatingActionButton.small(
                                    onPressed: () async {

                                      var data = {
                                        'ip' : SavedUserData.getIP(),
                                        'reason' : _disconnectReasonController.text
                                      };

                                      disconnectReasonsList!.add(DisconnectReasonModel(reason: _disconnectReasonController.text));
                                      disconnectReasonsState((){});
                                      _disconnectReasonController.clear();

                                      await API.create(SavedUserData.getIP()!, 0).addDisconnectReason(data);
                                    },
                                    backgroundColor: Colors.blueAccent,
                                    child: Center(
                                      child: Icon(Icons.add),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Divider(thickness: 2),
                              SizedBox(
                                height: 400,
                                width: 400,
                                child: getDisconnectReasons(),
                              )
                            ],
                          );
                        }
                      );
                      break;
                    case 3:
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context){
                            return SimpleDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Изменить пароль'),
                                  IconButton(
                                    icon: Icon(Icons.close_sharp),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              ),
                              children: [
                                SizedBox(
                                  height: 400,
                                  width: 400,
                                  child: getUsers(0),
                                )
                              ],
                            );
                          }
                      );
                      break;
                    case 4:
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context){
                            return SimpleDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Изменить привилегии'),
                                  IconButton(
                                    icon: Icon(Icons.close_sharp),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              ),
                              children: [
                                SizedBox(
                                  height: 400,
                                  width: 400,
                                  child: getUsers(1),
                                )
                              ],
                            );
                          }
                      );
                      break;
                  }
                },
              )
            ],
          ),
          body: StatefulBuilder(
            builder: (context, setState){
              dataTableState = setState;
              return mainBody();
            },
          )
        );
      },
    );
  }


  Widget mainBody(){
    return isDataLoaded ? SizedBox.expand(
        child: DataTable2(
          sortColumnIndex: sortColumnIndex,
          sortAscending: isAscending,
          columns: [
            DataColumn2(label: Text('GPON', style: TextStyle(fontWeight: FontWeight.w600)), size: ColumnSize.L, onSort: onSort),
            DataColumn2(label: Text('PON', style: TextStyle(fontWeight: FontWeight.w600)), fixedWidth: 120, onSort: onSort),
            DataColumn2(label: Text('SN', style: TextStyle(fontWeight: FontWeight.w600)), fixedWidth: 180, onSort: onSort),
            DataColumn2(label: Text('RX', style: TextStyle(fontWeight: FontWeight.w600)), fixedWidth: 100, onSort: onSort),
            DataColumn2(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600)), fixedWidth: 120, onSort: onSort),
            DataColumn2(label: Text('Port Description', style: TextStyle(fontWeight: FontWeight.w600)), fixedWidth: 280, onSort: onSort),
            DataColumn2(label: Text('CATV', style: TextStyle(fontWeight: FontWeight.w600)), fixedWidth: 120, onSort: onSort),
            DataColumn2(label: Text('Причина откл.', style: TextStyle(fontWeight: FontWeight.w600)), size: ColumnSize.S, onSort: onSort),
            DataColumn2(label: Text('Дата откл.', style: TextStyle(fontWeight: FontWeight.w600)), size: ColumnSize.S, onSort: onSort),
            DataColumn2(label: Text('Admin', style: TextStyle(fontWeight: FontWeight.w600)), size: ColumnSize.S, onSort: onSort),
            DataColumn2(label: Text('Примечание', style: TextStyle(fontWeight: FontWeight.w600)), fixedWidth: 250, onSort: onSort),
            DataColumn2(label: Text(''), fixedWidth: 60)
          ],
          rows: List<DataRow2>.generate(gponDevicesFilteredList!.length, (index){
            progress = 0.0;

            GPONDevice gponDevice = gponDevicesFilteredList![index];

            List<TextEditingController> portDescriptionFieldsControllerList = List.generate(gponDevicesFilteredList!.length, (index) => TextEditingController());
            List<TextEditingController> descriptionFieldControllersList = List.generate(gponDevicesFilteredList!.length, (index) => TextEditingController());

            if(gponDevice.note != null){
              descriptionFieldControllersList[index].value = descriptionFieldControllersList[index].value.copyWith(text: gponDevice.note);
            }

            if(gponDevice.portDescription != ''){
              portDescriptionFieldsControllerList[index].value = portDescriptionFieldsControllerList[index].value.copyWith(text: gponDevice.portDescription);
            }

            return DataRow2(
                cells: [
                  DataCell(Row(
                    children: [
                      Text(gponDevice.gponName),
                      Text(gponDevice.portDescription != null ? ' (${gponDevice.portDescription})' : '')
                    ],
                  )),
                  DataCell(Text(gponDevice.ponName)),
                  DataCell(Text(gponDevice.sn)),
                  DataCell(Text(gponDevice.rxPower)),
                  DataCell(Text(gponDevice.rxPower == '--' ? 'Inactive' : 'Active', style: TextStyle(color: gponDevice.rxPower == '--' ? Colors.red : Colors.green))),
                  DataCell(IgnorePointer(
                    ignoring: !PrivilegesConstants.CHANGE_PORT_DESCRIPTION,
                    child: SizedBox(
                      height: 30,
                      child: TextFormField(
                        controller: portDescriptionFieldsControllerList[index],
                        cursorColor: Colors.blueAccent,
                        decoration: InputDecoration(
                            suffixIcon: TextButton(
                                child: Text('OK', style: TextStyle(color: Colors.blueAccent)),
                                onPressed: () async {
                                  if(portDescriptionFieldsControllerList[index].text.isNotEmpty){
                                    gponDevice.setPortDescription(portDescriptionFieldsControllerList[index].text);
                                  }else{
                                    gponDevice.setPortDescription(null);
                                  }
                                  dataTableState((){});

                                  Map<String, String> data = {
                                    'description': portDescriptionFieldsControllerList[index].text,
                                    'flag' : 'enable',
                                    'selectedonuintf' : gponDevice.gponName,
                                    'selectedponintf' : gponDevice.ponName,
                                  };

                                  String username = initialOltDevice.username;
                                  String password = initialOltDevice.password;

                                  String credentials = '$username:$password';
                                  String encodedCredentials = 'Basic ${base64Encode(utf8.encode(credentials))}';

                                  await OltApi.create(initialOltDevice.ip).setPortDescription(encodedCredentials, data);
                                }
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)
                            )
                        ),
                      ),
                    ),
                  )),
                  DataCell(gponDevice.getCATVSupport ? IgnorePointer(
                    ignoring: !PrivilegesConstants.CHANGE_CATV,
                    child: MouseRegion(
                      onHover: _updateCursorLocation,
                      child: CupertinoSwitch(
                        value: gponDevice.getCATVStatus,
                        activeColor: Colors.blueAccent,
                        onChanged: (value) async {
                          if(value == false){
                            showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(_x, _y, _right, _bottom),
                                items: List<PopupMenuItem>.generate(disconnectReasonsList!.length, (reasonIndex) {
                                  return PopupMenuItem(
                                    child: ListTile(
                                      title: Text('${disconnectReasonsList![reasonIndex].reason}'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        setState((){
                                          gponDevice.setCATVStatus(value);
                                          gponDevice.setReason(disconnectReasonsList![reasonIndex].reason);
                                          gponDevice.setDate(formatter.format(DateTime.now()));
                                          gponDevice.setAdmin(SavedUserData.getUserName()!);
                                        });


                                        String username = initialOltDevice.username;
                                        String password = initialOltDevice.password;

                                        String credentials = '$username:$password';
                                        String encodedCredentials = 'Basic ${base64Encode(utf8.encode(credentials))}';

                                        await OltApi.create(initialOltDevice.ip).changeCATVStatus(encodedCredentials, gponDevice.gponName, gponDevice.ponName, value ? 'enable' : 'disable');

                                        var data = {
                                          'ip' : SavedUserData.getIP(),
                                          'olt_ip' : initialOltDevice.ip,
                                          'gpon_name' : gponDevice.gponName,
                                          'reason' : disconnectReasonsList![reasonIndex].reason,
                                          'date' : formatter.format(DateTime.now()),
                                          'admin' : SavedUserData.getUserName()
                                        };

                                        await API.create(SavedUserData.getIP()!, 0).addGPONCATVData(data);
                                      },
                                    ),
                                  );
                                })
                            );
                          }else{
                            setState((){
                              gponDevice.setCATVStatus(value);
                              gponDevice.setReason('');
                              gponDevice.setDate('');
                              gponDevice.setAdmin('');
                            });

                            String username = initialOltDevice.username;
                            String password = initialOltDevice.password;

                            String credentials = '$username:$password';
                            String encodedCredentials = 'Basic ${base64Encode(utf8.encode(credentials))}';

                            var data = {
                              'ip' : SavedUserData.getIP(),
                              'olt' : initialOltDevice.ip,
                              'onu' : gponDevice.gponName,
                            };

                            await OltApi.create(initialOltDevice.ip).changeCATVStatus(encodedCredentials, gponDevice.gponName, gponDevice.ponName, value ? 'enable' : 'disable');
                            await API.create(SavedUserData.getIP()!, 0).deleteCATVData(data);
                          }
                        },
                      ),
                    ),
                  ) : Container()),
                  DataCell(Text(gponDevice.getReason(), style: TextStyle(color: Colors.red))),
                  DataCell(Text(gponDevice.getDate(), style: TextStyle(color: Colors.red))),
                  DataCell(Text(gponDevice.getAdmin(), style: TextStyle(color: Colors.red))),
                  DataCell(SizedBox(
                    height: 30,
                    child: TextFormField(
                      controller: descriptionFieldControllersList[index],
                      cursorColor: Colors.blueAccent,
                      decoration: InputDecoration(
                          suffixIcon: TextButton(
                              child: Text('OK', style: TextStyle(color: Colors.blueAccent)),
                              onPressed: () async {
                                if(descriptionFieldControllersList[index].text.isEmpty){
                                  var data = {
                                    'ip' : SavedUserData.getIP(),
                                    'olt' : initialOltDevice.ip,
                                    'onu' : gponDevice.gponName,
                                  };
                                  await API.create(SavedUserData.getIP()!, 0).deleteNoteData(data);
                                }else{
                                  var data = {
                                    'ip' : SavedUserData.getIP(),
                                    'olt' : initialOltDevice.ip,
                                    'onu' : gponDevice.gponName,
                                    'note' : descriptionFieldControllersList[index].text
                                  };

                                  await API.create(SavedUserData.getIP()!, 0).addGPONNote(data);
                                }
                              }
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          )
                      ),
                    ),
                  )),
                  DataCell(IconButton(
                    icon: Icon(CupertinoIcons.delete_simple, color: PrivilegesConstants.DELETE_GPON ? Colors.black : Colors.grey),
                    onPressed: PrivilegesConstants.DELETE_GPON ? () {
                      showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            title: Text('Удалить ONU ?'),
                            content: Text('Вы действительно хотите удалить ONU ?'),
                            actions: [
                              TextButton(
                                child: Text('Отмена'),
                                onPressed: () => Navigator.pop(context),
                              ),

                              TextButton(
                                child: Text('Удалить', style: TextStyle(color: Colors.red)),
                                onPressed: () async {

                                  gponDevicesList!.removeAt(index);
                                  dataTableState((){});

                                  String username = initialOltDevice.username;
                                  String password = initialOltDevice.password;

                                  String credentials = '$username:$password';
                                  String encodedCredentials = 'Basic ${base64Encode(utf8.encode(credentials))}';

                                  String delstrName = gponDevice.sn + '/none/;';

                                  Map<String, String> data = {
                                    'delstr' : delstrName,
                                    'ifName' : gponDevice.ponName.toString().toUpperCase()
                                  };

                                  await OltApi.create(initialOltDevice.ip).deleteONU(encodedCredentials, data);

                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        }
                      );
                    } : null,
                  ))
                ]
            );
          }),
        )
    ) : noDevices ? Center(
      child: Text('Нет OLT устройств', style: TextStyle(fontSize: 20)),
    ) : Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: width / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 30,
                  color: Colors.blueAccent,
                  backgroundColor: Colors.grey.withOpacity(0.4),
                ),
              )
          ),
          SizedBox(height: 20),
          Text('Может занять некоторое время...')
        ],
      ),
    );
  }

  Future loginOlt(){
    String username = _oltUsernameController.text;
    String password = _oltPasswordController.text;

    String credentials = '$username:$password';
    String encodedCredentials = 'Basic ${base64Encode(utf8.encode(credentials))}';

    return OltApi.create(_oltIpController.text).loginOlt(encodedCredentials).then((value) async {
      if(value.statusCode == 401){
        oltDialogState((){
          incorrectOltData = true;

          isOltConnected = false;
          isOltExists = false;
          isOltIpFieldEmpty = false;
          isOltNameFieldEmpty = false;
          isOltPassFieldEmpty = false;
        });
      }else{

        var data = {
          'ip' : SavedUserData.getIP(),
          'olt_ip' : _oltIpController.text,
          'username' : _oltUsernameController.text,
          'password' : _oltPasswordController.text,
          'description' : _oltDescriptionController.text,
        };

        await API.create(SavedUserData.getIP()!, 0).registerOLT(data).then((value){
          if(value.body.compareTo('olt_device_registered') == 0){
            oltDialogState((){
              isOltConnected = true;

              isOltExists = false;
              isOltIpFieldEmpty = false;
              isOltNameFieldEmpty = false;
              isOltPassFieldEmpty = false;
              incorrectOltData = false;
            });

            oltDeicesList.add(OltDevice(
              ip: _oltIpController.text,
              username: _oltUsernameController.text,
              password: _oltPasswordController.text,
              description: _oltDescriptionController.text
            ));

            initialOltDevice = oltDeicesList.first;
            oltState((){});

            _oltIpController.clear();
            _oltUsernameController.clear();
            _oltPasswordController.clear();
            _oltDescriptionController.clear();
          }else{
            oltDialogState((){
              isOltExists = true;

              isOltIpFieldEmpty = false;
              isOltNameFieldEmpty = false;
              isOltPassFieldEmpty = false;
              incorrectOltData = false;
              isOltConnected = false;
            });
          }
        });
      }
    });
  }



  FutureBuilder<Response<List<OltDevice>>> getOltDevices(){
    var data = {
      'ip' : SavedUserData.getIP()
    };


    return FutureBuilder<Response<List<OltDevice>>>(
      future: API.create(SavedUserData.getIP()!, 2).getOltDevices(data),
      builder: (context, snapshot){
        while(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 2,
            ),
          );
        }

        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
          oltDeicesList = snapshot.data!.body!;
          return oltDevicesTable(oltDeicesList);
        }else{
          return Center(
            child: Text('Нет OLT устройств', style: TextStyle(fontSize: 18)),
          );
        }
      },
    );
  }

  Widget oltDevicesTable(List<OltDevice>? oltDevicesList){
    return StatefulBuilder(
      builder: (context, tableState){
        return SizedBox.expand(
          child: DataTable2(
              columns: const [
                DataColumn2(label: Text('IP')),
                DataColumn2(label: Text('Имя польз.')),
                DataColumn2(label: Text('Пароль'), size: ColumnSize.L),
                DataColumn2(label: Text('Описание')),
                DataColumn2(label: Text(''), size: ColumnSize.S),
                DataColumn2(label: Text(''), size: ColumnSize.S)
              ],
              rows: List<DataRow2>.generate(oltDevicesList!.length, (index){
                OltDevice oltDevice = oltDevicesList[index];
                return DataRow2(
                    cells: [
                      DataCell(
                          Text('${oltDevice.ip}')
                      ),
                      DataCell(
                          Text('${oltDevice.username}')
                      ),
                      DataCell(
                          Text('${oltDevice.password}')
                      ),
                      DataCell(
                          Text('${oltDevice.description}')
                      ),
                      DataCell(
                          IconButton(
                            icon: Icon(CupertinoIcons.pencil, color: Colors.black),
                            onPressed: () {
                              _oltDescriptionController.value = _oltDescriptionController.value.copyWith(text: oltDevice.description);
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return SimpleDialog(
                                      title: Text('Редактировать'),
                                      contentPadding: EdgeInsets.all(10),
                                      children: [
                                        TextFormField(
                                          cursorColor: Colors.blueAccent,
                                          controller: _oltDescriptionController,
                                          decoration: InputDecoration(
                                            hintText: 'Описание OLT',
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey)
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey)
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        FloatingActionButton.extended(
                                          label: Text('Изменить'),
                                          backgroundColor: Colors.blueAccent,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10))
                                          ),
                                          onPressed: () async {
                                            var data = {
                                              'ip' : SavedUserData.getIP(),
                                              'olt_ip' : oltDevice.ip,
                                              'description' : _oltDescriptionController.text
                                            };

                                            oltDevice.description = _oltDescriptionController.text;
                                            oltState((){});
                                            tableState((){});

                                            _oltDescriptionController.clear();
                                            Navigator.pop(context);
                                            await API.create(SavedUserData.getIP()!, 0).setOLTDescription(data);
                                          },
                                        )
                                      ],
                                    );
                                  }
                              );
                            },
                          )
                      ),
                      DataCell(
                          IconButton(
                            icon: Icon(CupertinoIcons.delete, color: Colors.black),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    title: Text('Удалить OLT ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Отмена'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if(oltDevicesList.length != 1){
                                            initialOltDevice = oltDevicesList.where((element) => element.ip != oltDevice.ip).first;
                                          }

                                          var data = {
                                            'ip' : SavedUserData.getIP(),
                                            'olt' : oltDevicesList[index].ip
                                          };

                                          oltDevicesList.removeAt(index);
                                          oltState((){});
                                          tableState((){});

                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          await API.create(SavedUserData.getIP()!, 0).deleteOLTDevice(data);
                                        },
                                        child: Text('Удалить', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                }
                              );
                            },
                          )
                      )
                    ]
                );
              })
          ),
        );
      },
    );
  }


  FutureBuilder<Response<List<User>>> getUsers(int index){
    var data = {
      'ip' : SavedUserData.getIP()
    };

    return FutureBuilder<Response<List<User>>>(
      future: API.create(SavedUserData.getIP()!, 1).getUsers(data),
      builder: (context, snapshot){
        while(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 2,
            ),
          );
        }

        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
          return usersTable(snapshot.data!.body, index);
        }else{
          return Center(
            child: Text('Нет данных', style: TextStyle(fontSize: 18)),
          );
        }
      },
    );
  }

  Widget usersTable(List<User>? usersList, int index){
    return index == 0 ? StatefulBuilder(
      builder: (context, setState){
        return SizedBox.expand(
          child: DataTable2(
              columns: const [
                DataColumn2(label: Text('Имя польз.')),
                DataColumn2(label: Text('Пароль'), size: ColumnSize.L),
                DataColumn2(label: Text(''), size: ColumnSize.S),
                DataColumn2(label: Text(''), size: ColumnSize.S)
              ],
              rows: List<DataRow2>.generate(usersList!.length, (index){
                User user = usersList[index];
                return DataRow2(
                    cells: [
                      DataCell(
                          Text('${user.name}')
                      ),
                      DataCell(
                          Text('${user.password}')
                      ),
                      DataCell(
                          IconButton(
                            icon: Icon(CupertinoIcons.pencil),
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context){
                                    return SimpleDialog(
                                      contentPadding: EdgeInsets.all(20),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Изменить пароль ${user.name}'),
                                          IconButton(
                                            icon: Icon(Icons.close_sharp),
                                            onPressed: () => Navigator.pop(context),
                                          )
                                        ],
                                      ),
                                      children: [
                                        TextFormField(
                                          controller: _newPasswordTextController,
                                          decoration: InputDecoration(
                                            hintText: 'Новый пароль',
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey)
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey)
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        FloatingActionButton.extended(
                                          onPressed: () async {
                                            if(_newPasswordTextController.text.isNotEmpty){
                                              var data = {
                                                'ip' : SavedUserData.getIP(),
                                                'name' : user.name,
                                                'password' : _newPasswordTextController.text
                                              };

                                              await API.create(SavedUserData.getIP()!, 0).changeUserPassword(data).then((value){
                                                if(value.body == 'password_changed'){
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Успешно', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.green));
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                }
                                              });
                                            }else{
                                              Navigator.pop(context);
                                            }
                                          },
                                          backgroundColor: Colors.blueAccent,
                                          label: Text('Изменить пароль'),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10))
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                              );
                            },
                          )
                      ),
                      DataCell(IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Text('Удалить ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () async {

                                        usersList.removeAt(index);
                                        setState((){});

                                        Navigator.pop(context);

                                        var data = {
                                          'ip' : SavedUserData.getIP(),
                                          'name' : user.name
                                        };

                                        await API.create(SavedUserData.getIP()!, 0).deleteUser(data);
                                      },
                                      child: Text('Удалить', style: TextStyle(color: Colors.red)),
                                    )
                                  ],
                                );
                              }
                          );
                        },
                      ))
                    ]
                );
              })
          ),
        );
      },
    ): SizedBox.expand(
      child: DataTable2(
          columns: const [
            DataColumn2(label: Text('Имя польз.')),
            DataColumn(label: Text(''))
          ],
          rows: List<DataRow2>.generate(usersList!.length, (index){
            User user = usersList[index];
            return DataRow2(
                cells: [
                  DataCell(
                      Text('${user.name}')
                  ),
                  DataCell(
                      IconButton(
                        icon: Icon(CupertinoIcons.pencil),
                        onPressed: () async {
                          await privileges.getPrivilegesForCurrentUser(user.name).whenComplete((){
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context){
                                  return StatefulBuilder(
                                    builder: (context, setState){
                                      return SimpleDialog(
                                        contentPadding: EdgeInsets.all(10),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Изменить привилегии ${user.name}'),
                                            IconButton(
                                              icon: Icon(Icons.close_sharp),
                                              onPressed: () => Navigator.pop(context),
                                            )
                                          ],
                                        ),
                                        children: [
                                          SizedBox(
                                            height: 400,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.ADD_OLT,
                                                            title: Text('Добавить OLT'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.ADD_OLT = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    ),
                                                    SizedBox(width: 14),
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.ADD_USERS,
                                                            title: Text('Добавить пользователя'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.ADD_USERS = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.CHANGE_CATV,
                                                            title: Text('Изменить CATV'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.CHANGE_CATV = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    ),
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.CHANGE_REASONS,
                                                            title: Text('Изменить причины отключения'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.CHANGE_REASONS = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.SEE_OLT_DEVICES,
                                                            title: Text('Посмотреть OLT устр.'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.SEE_OLT_DEVICES = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    ),
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.CHANGE_PASSWORDS,
                                                            title: Text('Изменить пароль'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.CHANGE_PASSWORDS = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.CHANGE_PRIVILEGES,
                                                            title: Text('Изменить привилегии'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.CHANGE_PRIVILEGES = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    ),
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.CHANGE_PORT_DESCRIPTION,
                                                            title: Text('Изменить Port Description'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.CHANGE_PORT_DESCRIPTION = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IntrinsicWidth(
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: CheckboxListTile(
                                                            value: PrivilegesForCurrentUser.DELETE_GPON,
                                                            title: Text('Удалить GPON'),
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 60),
                                                            activeColor: Colors.blueAccent,
                                                            onChanged: (value){
                                                              setState(() {
                                                                PrivilegesForCurrentUser.DELETE_GPON = value!;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                    ),
                                                    Container()
                                                  ],
                                                ),
                                                SizedBox(height: 50),
                                                FloatingActionButton.extended(
                                                  onPressed: () async {
                                                    var data = {
                                                      'ip' : SavedUserData.getIP(),
                                                      'user' : user.name,


                                                      'add_olt' : PrivilegesForCurrentUser.ADD_OLT,
                                                      'add_users' : PrivilegesForCurrentUser.ADD_USERS,
                                                      'change_catv' : PrivilegesForCurrentUser.CHANGE_CATV,
                                                      'delete_gpon' : PrivilegesForCurrentUser.DELETE_GPON,
                                                      'change_reasons' : PrivilegesForCurrentUser.CHANGE_REASONS,
                                                      'see_olt_devices' : PrivilegesForCurrentUser.SEE_OLT_DEVICES,
                                                      'change_passwords' : PrivilegesForCurrentUser.CHANGE_PASSWORDS,
                                                      'change_privileges' : PrivilegesForCurrentUser.CHANGE_PRIVILEGES,
                                                      'change_port_description' : PrivilegesForCurrentUser.CHANGE_PORT_DESCRIPTION
                                                    };

                                                    Response response = await API.create(SavedUserData.getIP()!, 0).submitPrivileges(data);
                                                    if(response.body == 'SUCCEED'){
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Успешно', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.green));

                                                      Navigator.pop(context);
                                                      Navigator.pop(context);

                                                      PrivilegesConstants.clear();
                                                      PrivilegesForCurrentUser.clear();
                                                    }
                                                  },
                                                  backgroundColor: Colors.blueAccent,
                                                  label: Text('Подтвердить'),
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }
                            );
                          });
                        },
                      )
                  )
                ]
            );
          })
      ),
    );
  }


  FutureBuilder<Response<List<DisconnectReasonModel>>> getDisconnectReasons(){
    var data = {
      'ip' : SavedUserData.getIP()
    };

    return FutureBuilder<Response<List<DisconnectReasonModel>>>(
      future: API.create(SavedUserData.getIP()!, 3).getDisconnectionReasons(data),
      builder: (context, snapshot){
        while(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
          );
        }


        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
          disconnectReasonsList = snapshot.data!.body;
          return disconnectReasonsWidget();
        }else{
          return Center(
            child: Text('Нет данных', style: TextStyle(fontSize: 16)),
          );
        }
      },
    );
  }

  Widget disconnectReasonsWidget(){
    return StatefulBuilder(
      builder: (context, setState){
        disconnectReasonsState = setState;
        return ListView.separated(
          itemCount: disconnectReasonsList!.length,
          separatorBuilder: (context, index){
            return Divider(thickness: 1);
          },
          itemBuilder: (context, index){
            return ListTile(
              title: Text(disconnectReasonsList![index].reason),
              trailing: IconButton(
                icon: Icon(CupertinoIcons.delete, color: Colors.black),
                onPressed: () async {
                  var data = {
                    'ip' : SavedUserData.getIP(),
                    'reason' : disconnectReasonsList![index].reason
                  };

                  disconnectReasonsList!.removeAt(index);
                  disconnectReasonsState((){});

                  await API.create(SavedUserData.getIP()!, 0).deleteDisconnectReason(data);

                },
              ),
            );
          },
        );
      },
    );
  }


  void showOltSignInDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return StatefulBuilder(
            builder: (context, setState){
              oltDialogState = setState;
              return SimpleDialog(
                title: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Регистрация OLT'),
                      IconButton(
                        icon: Icon(Icons.close_outlined),
                        onPressed: (){
                          Navigator.pop(context);

                          _oltIpController.clear();
                          _oltUsernameController.clear();
                          _oltPasswordController.clear();
                          _oltDescriptionController.clear();

                          isOltIpFieldEmpty = false;
                          isOltNameFieldEmpty = false;
                          isOltPassFieldEmpty = false;
                          incorrectOltData = false;
                          isOltConnected = false;
                          isOltExists = false;
                        },
                      )
                    ],
                  ),
                ),
                contentPadding: EdgeInsets.all(20),
                children: [
                  TextFormField(
                    cursorColor: Colors.blueAccent,
                    controller: _oltIpController,
                    decoration: InputDecoration(
                      hintText: 'OLT IP',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isOltIpFieldEmpty || incorrectOltData ? Colors.red : Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isOltIpFieldEmpty || incorrectOltData ? Colors.red : Colors.grey)
                      ),
                    ),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        setState(() {
                          isOltIpFieldEmpty = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.blueAccent,
                    controller: _oltUsernameController,
                    decoration: InputDecoration(
                      hintText: 'Имя пользователя OLT',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isOltNameFieldEmpty || incorrectOltData ? Colors.red : Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isOltNameFieldEmpty || incorrectOltData ? Colors.red : Colors.grey)
                      ),
                    ),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        setState((){
                          isOltNameFieldEmpty = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.blueAccent,
                    controller: _oltPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Пароль OLT',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isOltPassFieldEmpty || incorrectOltData ? Colors.red : Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isOltPassFieldEmpty || incorrectOltData ? Colors.red : Colors.grey)
                      ),
                    ),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        setState((){
                          isOltPassFieldEmpty = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.blueAccent,
                    controller: _oltDescriptionController,
                    decoration: InputDecoration(
                      hintText: 'Описание OLT',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  FloatingActionButton.extended(
                    onPressed: (){

                      if(_oltIpController.text.isEmpty || _oltUsernameController.text.isEmpty || _oltPasswordController.text.isEmpty){
                        if(_oltIpController.text.isEmpty){
                          setState(() {
                            isOltIpFieldEmpty = true;

                            isOltNameFieldEmpty = false;
                            isOltPassFieldEmpty = false;
                            incorrectOltData = false;
                            isOltConnected = false;
                            isOltExists = false;
                          });
                        }

                        if(_oltUsernameController.text.isEmpty){
                          setState(() {
                            isOltNameFieldEmpty = true;

                            isOltIpFieldEmpty = false;
                            isOltPassFieldEmpty = false;
                            incorrectOltData = false;
                            isOltConnected = false;
                            isOltExists = false;
                          });
                        }

                        if(_oltPasswordController.text.isEmpty){
                          setState(() {
                            isOltPassFieldEmpty = true;

                            isOltIpFieldEmpty = false;
                            isOltNameFieldEmpty = false;
                            incorrectOltData = false;
                            isOltConnected = false;
                            isOltExists = false;
                          });
                        }
                      }else{
                        loginOlt();
                      }
                    },
                    backgroundColor: Colors.blueAccent,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    label: Text('Подключиться к OLT'),
                  ),
                  SizedBox(height: isOltExists || incorrectOltData || isOltConnected ? 20 : 0),
                  Container(
                    child: incorrectOltData ? Center(
                      child: Text('Неправильный логин или пароль', style: TextStyle(fontSize: 18, color: Colors.red)),
                    ) : SizedBox(),
                  ),
                  Container(
                    child: isOltConnected ? Center(
                      child: Text( 'OLT успешно подключен', style: TextStyle(fontSize: 18, color: Colors.green)),
                    ) : SizedBox(),
                  ),
                  Container(
                    child: isOltExists ? Center(
                      child: Text('OLT уже зарегистрирован', style: TextStyle(fontSize: 18, color: Colors.deepOrangeAccent)),
                    ) : SizedBox(),
                  )
                ],
              );
            },
          );
        }
    );
  }

  void _updateCursorLocation(PointerEvent details) {
    _x = details.position.dx;
    _y = details.position.dy;
    _right = details.position.distance;
    _bottom = details.position.direction;
  }

  void refreshOlt() async {
    oltDeicesList.clear();
    gponDevicesList!.clear();
    gponCATVDataList!.clear();
    gponNoteDataList!.clear();

    gponDataStringList.clear();
    rxPowerStringList.clear();
    catvStatusStringList.clear();

    isDataLoaded = false;
    dataTableState((){});

    var data = {'ip' : SavedUserData.getIP()};

    await API.create(SavedUserData.getIP()!, 3).getDisconnectionReasons(data).then((value) => disconnectReasonsList = value.body);

    Response<List<OltDevice>> oltResponse = await API.create(SavedUserData.getIP()!, 2).getOltDevices(data);

    if(oltResponse.body!.first.id != null){
        oltDeicesList = oltResponse.body!;

        if(isFirstRun){
          initialOltDevice = oltDeicesList[0];
        }else{
          OltDevice device = oltDeicesList.where((element) => element.ip == initialOltDevice.ip).first;
          initialOltDevice = device;
        }

        String username = initialOltDevice.username;
        String password = initialOltDevice.password;

        String credentials = '$username:$password';
        String encodedCredentials = 'Basic ${base64Encode(utf8.encode(credentials))}';

        for(int i = 1; i <= 16; i++) {

          Response response = await OltApi.create(initialOltDevice.ip).getGPONDevices(encodedCredentials, 'gpon0/$i');
          Response rxPowerResponse = await OltApi.create(initialOltDevice.ip).getGPONDevicesRXPower(encodedCredentials, 'gpon0/$i');

          String content = response.body;
          String rxPowerContent = rxPowerResponse.body;

          const String start = 'var divscrollheight=new Array();';
          const String end = 'selectedonuname="none";';
          final startIndex = content.indexOf(start);
          final endIndex = content.indexOf(end, startIndex + start.length);
          String data = content.substring(startIndex + start.length, endIndex).replaceAll('=', ':');

          const String start1 = 'var Description=new Array();';
          const String end1 = 'var total1=0;';
          final startIndex1 = rxPowerContent.indexOf(start1);
          final endIndex1 = rxPowerContent.indexOf(end1, startIndex1 + start1.length);
          String data1 = rxPowerContent.substring(startIndex1 + start1.length, endIndex1);

          gponDataStringList.add(data);
          rxPowerStringList.add(data1);

          dataTableState((){
            progress = (i / 16);
          });

        }

        for(int i = 0; i < gponDataStringList.length; i++){
          if(gponDataStringList[i].contains('intfname')){
            for(int j = 0; j < 128; j++){
              if(gponDataStringList[i].contains('intfname[$j]')){
                String nameStart = 'intfname[$j]:"';
                const String nameEnd = '";';
                final nameStartIndex = gponDataStringList[i].indexOf(nameStart);
                final nameEndIndex = gponDataStringList[i].indexOf(nameEnd, nameStartIndex + nameStart.length);

                String descStart = 'description[$j]:"';
                const String descEnd = '";';
                final descStartIndex = gponDataStringList[i].indexOf(descStart);
                final descEndIndex = gponDataStringList[i].indexOf(descEnd, descStartIndex + descStart.length);

                String snStart = 'sn[$j]:"';
                const String snEnd = '";';
                final snStartIndex = gponDataStringList[i].indexOf(snStart);
                final snEndIndex = gponDataStringList[i].indexOf(snEnd, snStartIndex + snStart.length);

                String ponStart = 'selectedponname:"';
                const String ponEnd = '";';
                final ponStartIndex = gponDataStringList[i].indexOf(ponStart);
                final ponEndIndex = gponDataStringList[i].indexOf(ponEnd, ponStartIndex + ponStart.length);

                String rxPowerStart = 'RxPower[$j]="';
                const String rxPowerEnd = '";';
                final rxPowerIndexStart = rxPowerStringList[i].indexOf(rxPowerStart);
                final rxPowerIndexEnd = rxPowerStringList[i].indexOf(rxPowerEnd, rxPowerIndexStart + rxPowerStart.length);


                String gponName = gponDataStringList[i].substring(nameStartIndex + nameStart.length, nameEndIndex);
                String gponDescription = gponDataStringList[i].substring(descStartIndex + descStart.length, descEndIndex);
                String gponSN = gponDataStringList[i].substring(snStartIndex + snStart.length, snEndIndex);
                String ponName = gponDataStringList[i].substring(ponStartIndex + ponStart.length, ponEndIndex);
                String rxPower = rxPowerStringList[i].substring(rxPowerIndexStart + rxPowerStart.length, rxPowerIndexEnd);

                GPONDevice gponDevice = GPONDevice(
                  gponName: gponName,
                  description: gponDescription,
                  sn: gponSN,
                  rxPower: rxPower,
                  status: rxPower == '--' ? 'Inactive' : 'Active',
                  ponName: ponName,
                );

                await OltApi.create(initialOltDevice.ip).getGPONDevicesCATVStatus(encodedCredentials, ponName, gponName).then((response){

                  String content = response.body;

                  String catvStatusStart = 'singlecatvstatus="';
                  const String catvEnd = '";';
                  final catvStatusIndexStart = content.indexOf(catvStatusStart);
                  final catvStatusIndexEnd = content.indexOf(catvEnd, catvStatusIndexStart + catvStatusStart.length);

                  String start = 'onudescription="';
                  const String end = '";';
                  final indexStart = content.indexOf(start);
                  final indexEnd = content.indexOf(end, indexStart + start.length);

                  String hasCATVStart = 'ITUsupport="';
                  const String hasCATVEnd = '";';
                  final hasCATVIndexStart = content.indexOf(hasCATVStart);
                  final hasCATVIndexEnd = content.indexOf(hasCATVEnd, hasCATVIndexStart + hasCATVStart.length);

                  String catv = content.substring(catvStatusIndexStart + catvStatusStart.length, catvStatusIndexEnd);
                  String portDescription = content.substring(indexStart + start.length, indexEnd);
                  String hasCATVSupport = content.substring(hasCATVIndexStart + hasCATVStart.length, hasCATVIndexEnd);


                  gponDevice.setCATVSupport(hasCATVSupport == "0" ? false : true);
                  gponDevice.setCATVStatus(catv == 'disable' ? false : true);
                  gponDevice.setPortDescription(portDescription != '' ? portDescription : '');
                });


                gponDevicesList!.add(gponDevice);

              }else{
                continue;
              }
            }
          }else{
            continue;
          }
      }
    }else{
      noDevices = true;
      dataTableState((){});
    }

    if(!noDevices){
      isDataLoaded = true;
      isFirstRun = false;
      gponDevicesFilteredList = gponDevicesList;
      dataTableState(() {});
      oltState((){});

      if(gponDevicesFilteredList!.isNotEmpty){
        if(!(gponDevicesMap!.containsKey(initialOltDevice.ip))){
          gponDevicesMap!.addAll({
            '${initialOltDevice.ip}' : List.from(gponDevicesFilteredList!)
          });
        }
      }
    }

    getGPONDataFromSQL();
  }

  void onSort(int columnIndex, bool ascending) {
    if (gponDevicesFilteredList == null) {
      if(columnIndex == 0){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.gponName, b.gponName));
      }else if(columnIndex == 1){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.ponName, b.ponName));
      }else if(columnIndex == 2){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.sn, b.sn));
      }else if(columnIndex == 3){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.rxPower, b.rxPower));
      }else if(columnIndex == 4){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.status, b.status));
      }else if(columnIndex == 5){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.portDescription, b.portDescription));
      }else if(columnIndex == 6){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.getCATVStatus.toString(), b.getCATVStatus.toString()));
      }else if(columnIndex == 7){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.getReason(), b.getReason()));
      }else if(columnIndex == 8){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.getDate(), b.getDate()));
      }else if(columnIndex == 9){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.getAdmin(), b.getAdmin()));
      }else if(columnIndex == 10){
        gponDevicesList!.sort((a,b) => compareString(ascending, a.getNote(), b.getNote()));
      }
    } else {
      if(columnIndex == 0){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.gponName, b.gponName));
      }else if(columnIndex == 1){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.ponName, b.ponName));
      }else if(columnIndex == 2){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.sn, b.sn));
      }else if(columnIndex == 3){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.rxPower, b.rxPower));
      }else if(columnIndex == 4){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.status, b.status));
      }else if(columnIndex == 5){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.portDescription, b.portDescription));
      }else if(columnIndex == 6){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.getCATVStatus.toString(), b.getCATVStatus.toString()));
      }else if(columnIndex == 7){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.getReason(), b.getReason()));
      }else if(columnIndex == 8){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.getDate(), b.getDate()));
      }else if(columnIndex == 9){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.getAdmin(), b.getAdmin()));
      }else if(columnIndex == 10){
        gponDevicesFilteredList!.sort((a,b) => compareString(ascending, a.getNote(), b.getNote()));
      }
    }

    dataTableState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }

  int compareString(bool ascending, String value1, String value2) {
    return ascending ? value1.compareTo(value2) : value2.compareTo(value1);
  }


  void getGPONDataFromSQL() async {
    var data = {
      'ip' : SavedUserData.getIP(),
      'olt' : initialOltDevice.ip
    };


    Response<List<CATVDataModel>>? response = await API.create(SavedUserData.getIP()!, 4).getGPONCATVData(data);
    if(response.body![0].gponName != ''){
      gponCATVDataList = response.body;
    }

    Response<List<NoteDataModel>>? noteResponse = await API.create(SavedUserData.getIP()!, 5).getNoteData(data);
    if(noteResponse.body![0].note != ''){
      gponNoteDataList = noteResponse.body;
    }

    if(gponCATVDataList!.isNotEmpty){
      for(int i = 0; i < gponDevicesList!.length; i++){
        for(int j = 0; j < gponCATVDataList!.length; j++){
          if(gponDevicesList![i].gponName == gponCATVDataList![j].gponName){
            gponDevicesList![i].setReason(gponCATVDataList![j].reason);
            gponDevicesList![i].setDate(gponCATVDataList![j].date);
            gponDevicesList![i].setAdmin(gponCATVDataList![j].admin);
          }else{
            continue;
          }
        }
      }
    }

    for(int i = 0; i < gponDevicesList!.length; i++){
      for(int j = 0; j < gponNoteDataList!.length; j++){
        if(gponDevicesList![i].gponName.toString().startsWith(gponNoteDataList![j].onu.toString())){
          gponDevicesList![i].setNote(gponNoteDataList![j].note);
        }else{
          continue;
        }
      }
    }
    dataTableState(() {});
    oltState((){});
  }
}

