import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/view_model/auth_model/login_page_viewmodel.dart';
import 'package:heychat_2/widgets/custom_button_widgets.dart';
import 'package:heychat_2/widgets/custom_divider_widgets.dart';
import 'package:heychat_2/widgets/custom_text_widgets.dart';
import 'package:heychat_2/widgets/custom_textfield_widgets.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_cardview_widgets.dart';

final view_model = ChangeNotifierProvider((ref) => LoginPageViewmodel());
class LoginPage extends ConsumerStatefulWidget {

  LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController email_controller = TextEditingController();
  final TextEditingController password_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService().currentUser(context);
    });
  }


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
                  Center(child: CustomTextWidgets(text: Constants.title_login,font_size: 25,color: Colors.yellow,)),
                  const SizedBox(
                    height: 5,
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
                   Align(
                     alignment: Alignment.topRight,
                     child: TextButton(onPressed: (){
                      watch.goResetPasswordPage(context);
                                       }, child: const Text(Constants.reset_password)),
                   ),
                  const SizedBox(height: 5,),
                  CustomButtonWidgets(funciton: (){
                      read.login(context,email_controller.text,password_controller.text);
                  }, text: Constants.title_login),
                  const SizedBox(height: 5,),
                  Center(child: CustomTextWidgets(text: Constants.or,font_size: 10, color: Colors.white,)),
                  const SizedBox(height: 5,),
                  const CustomDividerWidgets(),
                  const SizedBox(height: 5,),
                  Padding(padding:const EdgeInsets.only(bottom: 5),child: Center(child: TextButton(
                    onPressed: (){
                      read.goRegisterPage(context);
                    },
                    child: const Text(Constants.register,style: TextStyle(fontSize: 10, color: Colors.white),),
                  ))),
                ],
              ),
            )),
      ],
    );
  }
}
