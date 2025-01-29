class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel(this.email, this.password);


  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }


  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      json['email'] as String,
      json['password'] as String,
    );
  }
}

