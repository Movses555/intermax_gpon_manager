// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'olt_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$OltApi extends OltApi {
  _$OltApi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = OltApi;

  @override
  Future<Response<dynamic>> loginOlt(String credentials) {
    final $url = '/';
    final $headers = {
      'Cookie': credentials,
    };

    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> saveAll(String credentials, Map<String, int> data) {
    final $url = '/goform/saveall';
    final $headers = {
      'Cookie': credentials,
    };

    final $body = data;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteONU(
      String credentials, Map<String, String> data) {
    final $url = '/goform/GponOnuIntfBindDelete';
    final $headers = {
      'Cookie': credentials,
    };

    final $body = data;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> setPortDescription(
      String credentials, Map<String, String> data) {
    final $url = '/goform/Onuintfconfig';
    final $headers = {
      'Cookie': credentials,
    };

    final $body = data;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getGPONDevices(String credentials, String ponName) {
    final $url = '/ontinterfacelist.asp';
    final $params = <String, dynamic>{'selectedponname': ponName};
    final $headers = {
      'Cookie': credentials,
    };

    final $request = Request('GET', $url, client.baseUrl,
        parameters: $params, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getGPONDevicesRXPower(
      String credentials, String ponName) {
    final $url = '/onusfpinfo.asp';
    final $params = <String, dynamic>{'selectedponname': ponName};
    final $headers = {
      'Cookie': credentials,
    };

    final $request = Request('GET', $url, client.baseUrl,
        parameters: $params, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getGPONDevicesCATVStatus(
      String credentials, String ponName, String onuName) {
    final $url = '/ontinterfacedetail.asp';
    final $params = <String, dynamic>{
      'selectedponname': ponName,
      'selectedonuname': onuName
    };
    final $headers = {
      'Cookie': credentials,
    };

    final $request = Request('GET', $url, client.baseUrl,
        parameters: $params, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> changeCATVStatus(
      String credentials, String onuName, String ponName, String catvStatus) {
    final $url = '/goform/OnuSinglecatvConfig';
    final $params = <String, dynamic>{
      'selectedonuintf2': onuName,
      'selectedponintf2': ponName,
      'catvstatus': catvStatus
    };
    final $headers = {
      'Cookie': credentials,
    };

    final $request = Request('POST', $url, client.baseUrl,
        parameters: $params, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }
}
