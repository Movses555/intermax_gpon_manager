import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:intermax_gpon_manager/API/gpon_manager_api.dart';
import 'package:intermax_gpon_manager/OLT%20List%20Page/olt_list_page.dart';
import 'package:intermax_gpon_manager/Privileges/privileges.dart';
import 'package:intermax_gpon_manager/Shared%20Preferences/sh_prefs.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SavedUserData.init();


  runApp(MaterialApp(
    home: AuthPage(),
  ));
}

class AuthPage extends StatefulWidget{
  const AuthPage({Key? key}) : super(key: key);


  @override
  _AuthPageState createState() => _AuthPageState();
}


class _AuthPageState extends State<AuthPage>{

  late double height;
  late double width;

  late Privileges _privileges;


  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();


  bool isIpFieldEmpty = false;
  bool isNameFieldEmpty = false;
  bool isPassFieldEmpty = false;

  bool rememberMe = false;

  bool incorrectData = false;

  bool hidePass = true;

  @override
  void initState() {

    _privileges = Privileges.createInstance();

    if (SavedUserData.getIP() != null && SavedUserData.getUserName() != null && SavedUserData.getPassword() != null) {
      _ipController.value = _ipController.value.copyWith(text: SavedUserData.getIP());
      _nameController.value = _nameController.value.copyWith(text: SavedUserData.getUserName());
      _passController.value = _passController.value.copyWith(text: SavedUserData.getPassword());
    }

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
    _ipController.dispose();
    _nameController.dispose();
    _passController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        return Scaffold(
          appBar: AppBar(
            title: Text('INTERMAX GPON Manager'),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurpleAccent, Colors.lightBlue]),
              ),
            ),
          ),
          body: mainBody(),
        );
      },
    );
  }

  Widget mainBody(){
    return Align(
        alignment: Alignment.center,
        child: Padding(
        padding: EdgeInsets.only(top: height/4, bottom: height/4, left: width/3, right: width/3),
        child: SizedBox(
          width: 300,
          child: Column(
            children: [
              Text('Войти', style: TextStyle(fontSize: 40),),
              SizedBox(height: 50),
              TextFormField(
                cursorColor: Colors.blueAccent,
                controller: _ipController,
                decoration: InputDecoration(
                  hintText: 'IP',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isIpFieldEmpty || incorrectData ? Colors.red : Colors.grey)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isIpFieldEmpty || incorrectData ? Colors.red : Colors.grey)
                  ),
                ),
                onChanged: (value){
                  if(value.isNotEmpty){
                    setState(() {
                      isIpFieldEmpty = false;
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                cursorColor: Colors.blueAccent,
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Имя',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isNameFieldEmpty || incorrectData ? Colors.red : Colors.grey)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isNameFieldEmpty || incorrectData ? Colors.red : Colors.grey)
                  ),
                ),
                onChanged: (value){
                  if(value.isNotEmpty){
                    setState(() {
                      isNameFieldEmpty = false;
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                cursorColor: Colors.blueAccent,
                controller: _passController,
                obscureText: hidePass,
                decoration: InputDecoration(
                  hintText: 'Пароль',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isPassFieldEmpty || incorrectData ? Colors.red : Colors.grey)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isPassFieldEmpty || incorrectData ? Colors.red : Colors.grey)
                  ),
                  suffixIcon: IconButton(
                    icon: hidePass ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    onPressed: (){
                      setState((){
                        hidePass = !hidePass;
                      });
                    },
                  )
                ),
                onChanged: (value){
                  if(value.isNotEmpty){
                    setState(() {
                      isPassFieldEmpty = false;
                    });
                  }
                },
              ),
              SizedBox(height: 30),
              CheckboxListTile(
                 value: rememberMe,
                 title: Text('Запомнить меня'),
                 controlAffinity: ListTileControlAffinity.leading,
                 contentPadding: EdgeInsets.symmetric(horizontal: 60),
                 activeColor: Colors.blueAccent,
                 onChanged: (value){
                   setState(() {
                     rememberMe = value!;
                   });
                 },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: width / 10,
                child: FloatingActionButton.extended(
                  onPressed: (){

                    if(_ipController.text.isEmpty || _nameController.text.isEmpty || _passController.text.isEmpty){
                      if(_ipController.text.isEmpty){
                        setState(() {
                          isIpFieldEmpty = true;
                        });
                      }

                      if(_nameController.text.isEmpty){
                        setState(() {
                          isNameFieldEmpty = true;
                        });
                      }

                      if(_passController.text.isEmpty){
                        setState(() {
                          isPassFieldEmpty = true;
                        });
                      }
                    }else{
                      if(rememberMe){
                        SavedUserData.rememberUser(
                          _ipController.text,
                          _nameController.text,
                          _passController.text
                        );
                      }else{
                        SavedUserData.isSignedIn = true;
                        SavedUserData.temporaryIp = _ipController.text;
                        SavedUserData.userName = _nameController.text;
                      }
                      loginUser();
                    }
                  },
                  backgroundColor: Colors.blueAccent,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  label: Text('Войти'),
                ),
              ),
              SizedBox(height: 20),
              Text(incorrectData ? 'Неправильный логин или пароль' : '', style: TextStyle(fontSize: 18, color: Colors.red))
            ],
          ),
        ),
      )
    );
  }

  Future loginUser(){
    var data = {
      'ip' : _ipController.text,
      'name' : _nameController.text,
      'password' : _passController.text
    };

    return Future.wait([
      API.create(_ipController.text, 1).loginUser(data)
    ]).then((value) async {
      if(value[0].body!.name != null && value[0].body!.password != null){

        await _privileges.getPrivileges(_ipController.text, _nameController.text).whenComplete((){
          setState(() {
            incorrectData = false;
          });

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OltListPage())
          );
        });

      }else{
        setState(() {
          incorrectData = true;
        });
      }
    });
  }

}

