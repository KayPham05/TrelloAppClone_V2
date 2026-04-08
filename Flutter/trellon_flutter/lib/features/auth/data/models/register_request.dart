class RegisterRequestModel {
  final String userName;
  final String email;
  final String password;

  RegisterRequestModel({
    required this.userName,
    required this.email,
    required this.password
  });

  // Chuyển sang Map để Dio gửi Body JSON cho C#
  Map<String, dynamic> toJson() => {
    'userName': userName, // Phải khớp với RegisterRequest bên C#
    'email': email,
    'password': password,
  };
}