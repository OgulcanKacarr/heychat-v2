import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/widgets/custom_button_widgets.dart';
import 'package:heychat_2/widgets/custom_divider_widgets.dart';
import 'package:heychat_2/widgets/custom_text_widgets.dart';
import 'package:heychat_2/widgets/custom_textfield_widgets.dart';

import '../../widgets/custom_cardview_widgets.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController email_controller = TextEditingController();
  final TextEditingController password_controller = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _buildForm(),
      ),
    );
  }
  Widget _buildForm(){
    return Column(
      children: [
        Center(child: Image.asset(Constants.logo_path)),
        CustomCardviewWidgets(
            container: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CustomTextWidgets(text: Constants.title_login,font_size: 25,color: Colors.yellow,)),
                  const SizedBox(
                    height: 5,
                  ),
                  CustomTextfieldWidgets(
                      controller: email_controller,
                      hint_text: Constants.email,
                      prefix_icon: const Icon(Icons.person),
                      keyboard_type: TextInputType.emailAddress),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextfieldWidgets(
                      controller: password_controller,
                      hint_text: Constants.password,
                      prefix_icon: const Icon(Icons.lock),
                      is_password: true,
                      keyboard_type: TextInputType.text),
                  const SizedBox(height: 10,),
                  CustomButtonWidgets(funciton: (){

                  }, text: Constants.title_login),
                  const SizedBox(height: 5,),
                  Center(child: CustomTextWidgets(text: Constants.or,font_size: 10, color: Colors.white,)),
                  const SizedBox(height: 5,),
                  const CustomDividerWidgets(),
                  const SizedBox(height: 5,),
                  Padding(padding:const EdgeInsets.only(bottom: 5),child: Center(child: CustomTextWidgets(text: Constants.register,font_size: 10, color: Colors.white,))),
                ],
              ),
            )),
      ],
    );
  }
}
