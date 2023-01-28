import 'package:chopper/chopper.dart';
import 'package:intermax_gpon_manager/Converter/json_converter.dart';
import 'package:intermax_gpon_manager/Data%20Models/CATV%20Data%20Model/catv_data_model.dart';
import 'package:intermax_gpon_manager/Data%20Models/Disconnect%20Reason%20Model/disconnect_reason_model.dart';
import 'package:intermax_gpon_manager/Data%20Models/Note%20Data%20Model/note_data_model.dart';
import 'package:intermax_gpon_manager/Data%20Models/OLT%20Data%20Model/olt_data_model.dart';
import 'package:intermax_gpon_manager/Data%20Models/User%20Data%20Model/user_data_model.dart';

import '../Data Models/Privileges Data Model/privileges_data_model.dart';

part 'gpon_manager_api.chopper.dart';


@ChopperApi()
abstract class API extends ChopperService{


  @Post(path: '/login_user.php')
  Future<Response<User>> loginUser(@Body() var data);

  @Post(path: '/register_user.php')
  Future<Response> registerUser(@Body() var data);

  @Post(path: '/register_olt.php')
  Future<Response> registerOLT(@Body() var data);

  @Post(path: '/add_disconnect_reason.php')
  Future<Response> addDisconnectReason(@Body() var data);

  @Post(path: '/delete_disconnect_reason.php')
  Future<Response> deleteDisconnectReason(@Body() var data);

  @Post(path: '/add_gpon_catv_data.php')
  Future<Response> addGPONCATVData(@Body() var data);

  @Post(path: '/delete_catv_data.php')
  Future<Response> deleteCATVData(@Body() var data);

  @Post(path: '/add_gpon_note.php')
  Future<Response> addGPONNote(@Body() var data);

  @Post(path: '/delete_note_data.php')
  Future<Response> deleteNoteData(@Body() var data);

  @Post(path: '/change_user_password.php')
  Future<Response> changeUserPassword(@Body() var data);

  @Post(path: '/submit_privileges.php')
  Future<Response> submitPrivileges(@Body() var data);

  @Post(path: '/delete_olt_device.php')
  Future<Response> deleteOLTDevice(@Body() var data);

  @Post(path: '/set_olt_description.php')
  Future<Response> setOLTDescription(@Body() var data);

  @Post(path: '/delete_user.php')
  Future<Response> deleteUser(@Body() var data);

  @Post(path: '/get_privileges.php')
  Future<Response<PrivilegesModel>> getPrivileges(@Body() var data);

  @Post(path: '/get_users.php')
  Future<Response<List<User>>> getUsers(@Body() var data);

  @Post(path: '/get_note_data.php')
  Future<Response<List<NoteDataModel>>> getNoteData(@Body() var data);

  @Post(path: '/get_catv_data.php')
  Future<Response<List<CATVDataModel>>> getGPONCATVData(@Body() var data);

  @Post(path: '/get_disconnect_reasons.php')
  Future<Response<List<DisconnectReasonModel>>> getDisconnectionReasons(@Body() var data);

  @Post(path: '/get_olt_devices.php')
  Future<Response<List<OltDevice>>> getOltDevices(@Body() var data);



  static API create(String ip, int converterCode){
    JsonConverter? converter;

    switch(converterCode){
      case 0:
        converter = JsonConverter();
        break;
      case 1:
        converter = JsonToTypeConverter({
          User:  (json) => User.fromJson(json)
        });
        break;
      case 2:
        converter = JsonToTypeConverter({
          OltDevice: (json) => OltDevice.fromJson(json)
        });
        break;
      case 3:
        converter = JsonToTypeConverter({
          DisconnectReasonModel: (json) => DisconnectReasonModel.fromJson(json)
        });
        break;
      case 4:
        converter = JsonToTypeConverter({
          CATVDataModel: (json) => CATVDataModel.fromJson(json)
        });
        break;
      case 5:
        converter = JsonToTypeConverter({
          NoteDataModel: (json) => NoteDataModel.fromJson(json)
        });
        break;
      case 6:
        converter = JsonToTypeConverter({
          PrivilegesModel: (json) => PrivilegesModel.fromJson(json)
        });
        break;
    }

    final client = ChopperClient(
        baseUrl: 'http://$ip:1072/Intermax GPON Manager',
        services: [_$API()],
        converter: converter
    );

    return _$API(client);
  }
}