import 'package:chopper/chopper.dart';

part 'olt_api.chopper.dart';

@ChopperApi()
abstract class OltApi extends ChopperService{


  @Get(path: '/')
  Future<Response> loginOlt(@Header('Cookie') String credentials);

  @Post(path: '/goform/saveall')
  Future<Response> saveAll(@Header('Cookie') String credentials, @Body() Map<String, int> data);

  @Post(path: '/goform/GponOnuIntfBindDelete')
  Future<Response> deleteONU(@Header('Cookie') String credentials, @Body() Map<String, String> data);

  @Post(path: '/goform/Onuintfconfig')
  Future<Response> setPortDescription(@Header('Cookie') String credentials, @Body() Map<String, String> data);

  @Get(path: '/ontinterfacelist.asp')
  Future<Response> getGPONDevices(@Header('Cookie') String credentials, @Query('selectedponname') String ponName);

  @Get(path: '/onusfpinfo.asp')
  Future<Response> getGPONDevicesRXPower(@Header('Cookie') String credentials, @Query('selectedponname') String ponName);

  @Get(path: '/ontinterfacedetail.asp')
  Future<Response> getGPONDevicesCATVStatus(@Header('Cookie') String credentials, @Query('selectedponname') String ponName, @Query('selectedonuname') String onuName);

  @Post(path: '/goform/OnuSinglecatvConfig')
  Future<Response> changeCATVStatus(@Header('Cookie') String credentials, @Query('selectedonuintf2') String onuName, @Query('selectedponintf2') String ponName, @Query('catvstatus') String catvStatus);



  static OltApi create(String ip){
    final client = ChopperClient(
        baseUrl: 'http://$ip',
        services: [_$OltApi()],
        converter: FormUrlEncodedConverter(),
    );


    return _$OltApi(client);
  }
}