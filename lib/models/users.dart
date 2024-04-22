class Users {
  final int? usrId;
  final String usrname;
  final String usrPassword;

  Users({
    this.usrId,
    required this.usrname,
    required this.usrPassword,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        usrname: json["usrname"],
        usrPassword: json["usr_password"],
      );

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "usrname": usrname,
        "usr_password": usrPassword,
      };
}
