class GPONDevice{

  var gponName;

  var description;

  var sn;

  var rxPower;

  var catvSupport;

  var status;

  var ponName;

  var catvStatus;

  var portDescription;

  var note;

  var reason;

  var date;

  var admin;


  GPONDevice({required this.gponName, required this.description, required this.sn, required this.rxPower, required this.status, required this.ponName});


  void setCATVStatus(bool status){
    catvStatus = status;
  }

  void setCATVSupport(bool hasCATVSupport){
    catvSupport = hasCATVSupport;
  }

  void setPortDescription(String? description){
    portDescription = description;
  }

  void setNote(String? note){
    this.note = note;
  }

  void setReason(String reason){
    this.reason = reason;
  }

  void setDate(String date){
    this.date = date;
  }

  void setAdmin(String admin){
    this.admin = admin;
  }


  bool get getCATVSupport => catvSupport;

  bool get getCATVStatus => catvStatus;

  String getPortDescription(){
    if(portDescription == null){
      return '';
    }else{
      return portDescription;
    }
  }

  String getNote(){
    if(note == null){
      return '';
    }else{
      return note;
    }
  }

  String getReason(){
    if(reason == null){
      return '';
    }else{
      return reason;
    }
  }

  String getDate(){
    if(date == null){
      return '';
    }else{
      return date;
    }
  }

  String getAdmin(){
    if(admin == null){
      return '';
    }else{
      return admin;
    }
  }

}