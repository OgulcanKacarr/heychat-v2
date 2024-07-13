import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/view_model/auth_model/login_page_viewmodel.dart';
import 'package:heychat_2/view_model/auth_model/register_page_viewmodel.dart';
import 'package:heychat_2/widgets/custom_cardview_widgets.dart';

import '../../utils/constants.dart';
import '../../widgets/custom_button_widgets.dart';
import '../../widgets/custom_divider_widgets.dart';
import '../../widgets/custom_text_widgets.dart';
import '../../widgets/custom_textfield_widgets.dart';

final view_model = ChangeNotifierProvider((ref) => RegisterPageViewmodel());
class RegisterPage extends ConsumerStatefulWidget {



  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  TextEditingController password_match_controller = TextEditingController();
  TextEditingController name_and_surname_controller = TextEditingController();
  TextEditingController username_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    var watch = ref.watch(view_model);
    var read = ref.read(view_model);
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _buildForm(read,watch),
      ),
    );
  }

  Widget _buildForm(var read, var watch){
    return Column(
      children: [
        Center(child: Image.asset(Constants.logo_path)),
        CustomCardviewWidgets(
            container: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CustomTextWidgets(text: Constants.register,font_size: 25,color: Colors.yellow,)),
                  const SizedBox(
                    height: 5,
                  ), CustomTextfieldWidgets(
                      controller: name_and_surname_controller,
                      hint_text: Constants.name_and_surname,
                      prefix_icon: const Icon(Icons.person),
                      keyboard_type: TextInputType.text),
                  const SizedBox(
                    height: 10,
                  ), CustomTextfieldWidgets(
                      controller: username_controller,
                      hint_text: Constants.username,
                      prefix_icon: const Icon(Icons.person),
                      keyboard_type: TextInputType.text),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextfieldWidgets(
                      controller: email_controller,
                      hint_text: Constants.email,
                      prefix_icon: const Icon(Icons.email),
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
                  CustomTextfieldWidgets(
                      controller: password_match_controller,
                      hint_text: Constants.password_match,
                      prefix_icon: const Icon(Icons.lock),
                      is_password: true,
                      keyboard_type: TextInputType.text),
                  const SizedBox(height: 10,),
                  CustomButtonWidgets(funciton: () async {

                    //Kullanıcı oluştur
                    await read.createUser(
                        context,
                        name_and_surname_controller.text,
                        username_controller.text,
                        email_controller.text,
                        password_controller.text,
                        password_match_controller.text);

                  }, text: Constants.register),
                  const SizedBox(height: 5,),
                  Center(child: CustomTextWidgets(text: Constants.or,font_size: 10, color: Colors.white,)),
                  const SizedBox(height: 5,),
                  const CustomDividerWidgets(),
                  const SizedBox(height: 5,),
                  Padding(padding:const EdgeInsets.only(bottom: 5),child: Center(child: TextButton(
                    onPressed: ()  {
                      watch.goLoginPage(context);
                    },
                    child: const Text(Constants.title_login,style: TextStyle(fontSize: 10, color: Colors.white),),
                  ))),
                ],
              ),
            )),
      ],
    );
  }
}