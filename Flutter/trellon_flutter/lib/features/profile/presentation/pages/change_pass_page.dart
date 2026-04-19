import 'dart:async';

import 'package:apptreolon/core/constants/app_colors.dart';
import 'package:apptreolon/core/utils/validators/validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePassword extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() {
    return _changePasswordState();
  }
}

class _changePasswordState extends State<ChangePassword>{
  //key
  final _form_key = GlobalKey<FormState>();
  final _confirmPassKey = GlobalKey<FormFieldState>();

  //debounce
  Timer? _debounce;

  //Controller
  late TextEditingController _oldPass;
  late TextEditingController _newPass;
  late TextEditingController _newPassConfirm;

  //helpers
  bool isSubmitting = false;
  late FocusNode _newPassFocus = FocusNode();
  late FocusNode _newConfirmPassFocus = FocusNode();


  @override
  void initState(){
    super.initState();
    _oldPass = TextEditingController();
    _newPass = TextEditingController();
    _newPassConfirm = TextEditingController();
    _newPassConfirm.addListener(_onConfirmPassChanged);

  }

  @override
  void dispose(){
    super.dispose();
    _oldPass.dispose();
    _newPass.dispose();
    _newPassConfirm.dispose();
    _debounce?.cancel();

    _newPassFocus.dispose();
    _newConfirmPassFocus.dispose();
  }

  void _onConfirmPassChanged(){

    if(_debounce?.isActive ?? false){
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), (){
      if(_newPassConfirm.text.isNotEmpty){
        _confirmPassKey.currentState!.validate();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF1F2F4),
          leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1D4ED8),
          )),
          title: Text(
            'Đổi mật khẩu',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        backgroundColor: AppColors.background,
        body: Form(
          key: _form_key,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 80),
            child: Column(
              children: [
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hint: Text(
                        "Nhập mật khẩu cũ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      
                    ),
                    validator: (value)=>Validator.notEmpty(value, 'Mật khẩu cũ'),
                    controller: _oldPass,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_newPassFocus);
                    },
                    
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hint: Text(
                        "Nhập mật khẩu mới",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: Validator.password,
                    controller: _newPass,
                    focusNode: _newPassFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_newConfirmPassFocus);
                    },
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    key: _confirmPassKey,
                    obscureText: true,
                    decoration: InputDecoration(
                      hint: Text(
                        "Nhập lại mật khẩu mới",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      
                    ),
                    validator: (value)=>Validator.confirmPassword(value, _newPass.text),
                    controller: _newPassConfirm,
                    focusNode: _newConfirmPassFocus,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1D4ED8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                      
                    ),
                    onPressed: isSubmitting? null : () async{
                      if(_form_key.currentState!.validate()){
                        setState(() {
                           isSubmitting = true;
                        });
                  
                        await Future.delayed(Duration(seconds: 2));
                  
                        setState((){
                          isSubmitting = false;
                        });
                  
                        if(mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Đổi mật khẩu thành công"))
                          );
                              
                          await Future.delayed(Duration(seconds: 2));
                              
                          Navigator.pop(context);
                        }
                      }
                      
                    },
                    child: isSubmitting? CircularProgressIndicator() : Text("Đổi mật khẩu", style: TextStyle(color: Colors.white),))
              ],
            ),
          )  
        ),
    );
  }
}