// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpon_manager_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$API extends API {
  _$API([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = API;

  @override
  Future<Response<User>> loginUser(dynamic data) {
    final $url = '/login_user.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<User, User>($request);
  }

  @override
  Future<Response<dynamic>> registerUser(dynamic data) {
    final $url = '/register_user.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> registerOLT(dynamic data) {
    final $url = '/register_olt.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addDisconnectReason(dynamic data) {
    final $url = '/add_disconnect_reason.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteDisconnectReason(dynamic data) {
    final $url = '/delete_disconnect_reason.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addGPONCATVData(dynamic data) {
    final $url = '/add_gpon_catv_data.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteCATVData(dynamic data) {
    final $url = '/delete_catv_data.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addGPONNote(dynamic data) {
    final $url = '/add_gpon_note.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteNoteData(dynamic data) {
    final $url = '/delete_note_data.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> changeUserPassword(dynamic data) {
    final $url = '/change_user_password.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> submitPrivileges(dynamic data) {
    final $url = '/submit_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteOLTDevice(dynamic data) {
    final $url = '/delete_olt_device.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> setOLTDescription(dynamic data) {
    final $url = '/set_olt_description.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteUser(dynamic data) {
    final $url = '/delete_user.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PrivilegesModel>> getPrivileges(dynamic data) {
    final $url = '/get_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<PrivilegesModel, PrivilegesModel>($request);
  }

  @override
  Future<Response<List<User>>> getUsers(dynamic data) {
    final $url = '/get_users.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<User>, User>($request);
  }

  @override
  Future<Response<List<NoteDataModel>>> getNoteData(dynamic data) {
    final $url = '/get_note_data.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<NoteDataModel>, NoteDataModel>($request);
  }

  @override
  Future<Response<List<CATVDataModel>>> getGPONCATVData(dynamic data) {
    final $url = '/get_catv_data.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<CATVDataModel>, CATVDataModel>($request);
  }

  @override
  Future<Response<List<DisconnectReasonModel>>> getDisconnectionReasons(
      dynamic data) {
    final $url = '/get_disconnect_reasons.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<List<DisconnectReasonModel>, DisconnectReasonModel>($request);
  }

  @override
  Future<Response<List<OltDevice>>> getOltDevices(dynamic data) {
    final $url = '/get_olt_devices.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<OltDevice>, OltDevice>($request);
  }
}
