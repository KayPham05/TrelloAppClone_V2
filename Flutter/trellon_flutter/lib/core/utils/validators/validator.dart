class Validator {
  
  //Không bỏ trống
  static String?  notEmpty(String? value, String label){
    if(value == null || value.trim().isEmpty){
      return '$label không được bỏ trống';
    }
    return null;
  }

  //Email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được bỏ trống';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  //Số điện thoại
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được bỏ trống';
    }
    // Regex kiểm tra số điện thoại VN (10 số, bắt đầu bằng 0)
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])([0-9]{8})$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  //Mật khẩu
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được bỏ trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận lại mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không trùng khớp';
    }
    return null;
  }
}