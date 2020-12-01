import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/bank_data_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:scoped_model/scoped_model.dart';


bool showLandPage=true;
bool showResumePage=false;
bool showByePage=false;


double heightPercent;
double widthPercent;

TextEditingController problemController = TextEditingController();

TextEditingController _nameController = TextEditingController();
TextEditingController _accountController = TextEditingController();
TextEditingController _digitController = TextEditingController();
TextEditingController _agencyController = TextEditingController();
TextEditingController _otherBankController = TextEditingController();
var _maskFormatterCpf = new MaskTextInputFormatter(mask: '###.###.###-##)', filter: { "#": RegExp(r'[0-9]') });
final TextEditingController _cpfController = TextEditingController();

String AcountType='cc';
String bank;

FocusNode _otherBankFocusNode;

ScrollController _scrollController;

bool isLoading=false;

BankData bankData = BankData('', '', '', '', '', '','', '', '', '', '');

final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class UserInformsBankDataPage extends StatefulWidget {
  MoveClass _moveClass = MoveClass();
  UserInformsBankDataPage(this._moveClass);

  @override
  _UserInformsBankDataPageState createState() => _UserInformsBankDataPageState();
}

class _UserInformsBankDataPageState extends State<UserInformsBankDataPage> with AfterLayoutMixin<UserInformsBankDataPage> {


  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _otherBankFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _otherBankFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }


  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    // isto é exercutado após todo o layout ser renderizado

  }

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel){

        //load fullna


        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: WidgetsConstructor().makeSimpleText("Devolução", Colors.white, 15.0),
          backgroundColor: Colors.blue,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                iconSize: 20.0,
                onPressed: () {
                  _goBack(context);
                },
              ),
          centerTitle: true),

          body: SafeArea(
              top: true,
              bottom: true,
              child: Stack(

                children: [

                  showLandPage==true
                      ? _landPage()
                      : showResumePage==true
                      ? _resumePage(userModel)
                      : showByePage==true
                      ? _byePage()
                      : Container(),

                  isLoading==true
                  ? Center(child: CircularProgressIndicator(),)
                      : Container(),

                ],

              ),
          ),
        );

      },
    );

  }

  //Pages

  Widget _landPage(){

    void _onClickFinalize(MoveClass moveClass, UserModel userModel){

      if(problemController.text.isEmpty){
        _displaySnackBar(context, 'Informe o que aconteceu para nós. Assim poderemos trabalhar para melhorar.', Colors.red);
      } else if(_nameController.text.isEmpty){
        _displaySnackBar(context, 'Informe o nome', Colors.red);
      } else if(_agencyController.text.isEmpty){
        _displaySnackBar(context, 'Informe a agência', Colors.red);
      } else if(_accountController.text.isEmpty){
        _displaySnackBar(context, 'Informe o número da conta', Colors.red);
      } else if(_digitController.text.isEmpty){
        _displaySnackBar(context, 'Informe o dígito verificador da conta', Colors.red);
      } else if(bank==null){
        _displaySnackBar(context, 'Informe o banco', Colors.red);
      } else if(bank=='outro' && _otherBankController.text.isEmpty){
        _displaySnackBar(context, 'Informe o banco', Colors.red);
      } else if(_cpfController.text.isEmpty) {
        _displaySnackBar(
            context, 'Informe o CPF do titular da conta', Colors.red);
      } else if(_cpfController.text.length != 14){
        _displaySnackBar(context, 'Verifique seu cpf. Formato inválido.', Colors.red);

      } else {
        //chegou


        bankData.userId = userModel.Uid;
        bankData.userName = userModel.FullName;
        bankData.userMail = userModel.Email;
        bankData.nameOfAccountOwner = _nameController.text;
        bankData.agency = _agencyController.text;
        bankData.account = _accountController.text;
        bankData.accountDigit = _digitController.text;
        bankData.cpfOfAccountOwner = _cpfController.text;
        bankData.problem = problemController.text;
        bankData.accountType = AcountType;

        showLandPage=false;
        setState(() {
        showResumePage=true;
        });

        //_saveData(userModel);


      }

    }

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel){


        return ListView(
          children: [
            Column(

              mainAxisSize: MainAxisSize.max,
              children: [
                WidgetsConstructor().makeText('Precisamos de algumas informações para a devolução do dinheiro', Colors.blue, 18.0, 20.0, 20.0, 'center'),

                Container(
                    decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.grey[400], 2.0, 4.0),
                    width: widthPercent*0.95,
                    child: new TextField(
                      controller: problemController,
                      decoration: InputDecoration(labelText: 'Primeiro nos explique o que aconteceu'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                    )
                ),

                SizedBox(height: 25.0,),
                WidgetsConstructor().makeText('Informações bancárias para reembolso', Colors.blue, 18.0, 20.0, 20.0, 'center'),
                _textField(_nameController, "Nome do titular da conta", widthPercent*0.85),
                SizedBox(height: 20.0,),
                _textFieldNumberOnly(_agencyController, "Agência", widthPercent*0.85),
                SizedBox(height: 20.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10.0,),
                    _textFieldNumberOnly(_accountController, "Conta - dígito", widthPercent*0.45),
                    Text(' _ '),
                    _textFieldNumberOnly(_digitController, "", widthPercent*0.15),
                  ],
                ),
                SizedBox(height: 10.0,),
                _buildRadioOptionsBankTypeSelection(context),
                WidgetsConstructor().makeText("Informe o banco", Colors.blue, 16.0, 15.0, 10.0, 'center'),
                Container(
                  width: widthPercent*0.95,
                  decoration: WidgetsConstructor().myBoxDecoration(Colors.grey[100], Colors.blue, 2.0, 7.0),
                  child: _buildRadioOptionsBank(context),
                ),
                bank == 'outro'
                    ? _textFieldWithFocusNode(_otherBankController, 'Informe o banco', widthPercent*0.85, _otherBankFocusNode)
                    :Container(),
                SizedBox(height: 20.0,),
                Container(
                  width: widthPercent*0.85,
                  child: WidgetsConstructor().makeEditTextForPhoneFormat(_cpfController, 'CPF do titular', _maskFormatterCpf),
                ),
                SizedBox(height: 20.0,),
                WidgetsConstructor().makeButtonWithCallBack(Colors.blue, Colors.white, widthPercent*0.90, 80.0, 2.0, 4.0, 'Finalizar cadastro', Colors.white, 18.0, () {_onClickFinalize(widget._moveClass, userModel);}),
                SizedBox(height: 25.0,),


              ],
            )
          ],
        );

      },
    );

  }

  Widget _resumePage(UserModel userModel){

    return GestureDetector(
      onTap: (){
        //fica em branco para n ter ação
      },
      child: Container(
        width: widthPercent,
        height: heightPercent,
        child: Container(
          width: widthPercent*0.90,
          child: Column(
            children: [

              WidgetsConstructor().makeText('Verifique as informações', Colors.blue, 18.0, 10.0, 15.0, 'center'),

              Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back, size: 45.0, color: Colors.blue,), onPressed: (){
                    showResumePage=false;
                    setState(() {
                      showLandPage=true;
                    });
                  }),
                  SizedBox(width: 10.0,),
                  WidgetsConstructor().makeText('Editar estas informações', Colors.blue, 16.0, 12.0, 5.0, 'no'),
                ],
              ),

              Row(
                children: [
                  WidgetsConstructor().makeText('Títular da conta: ', Colors.black, 15.0, 25.0, 10.0, 'no'),
                  WidgetsConstructor().makeText(bankData.nameOfAccountOwner, Colors.black54, 15.0, 25.0, 10.0, 'no'),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText('Cpf do títular: ', Colors.black, 15.0, 10.0, 10.0, 'no'),
                  WidgetsConstructor().makeText(bankData.cpfOfAccountOwner, Colors.black54, 15.0, 10.0, 10.0, 'no'),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText('Agência: ', Colors.black, 15.0, 10.0, 10.0, 'no'),
                  WidgetsConstructor().makeText(bankData.agency, Colors.black54, 15.0, 10.0, 10.0, 'no'),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText('Conta: ', Colors.black, 15.0, 10.0, 10.0, 'no'),
                  WidgetsConstructor().makeText(bankData.account+'-'+bankData.accountDigit, Colors.black54, 15.0, 10.0, 10.0, 'no'),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText('Banco: ', Colors.black, 15.0, 10.0, 25.0, 'no'),
                  WidgetsConstructor().makeText(bankData.bank, Colors.black54, 15.0, 25.0, 10.0, 'no'),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    height: 60.0,
                    width: widthPercent*0.85,
                    child: RaisedButton(

                        color: Colors.blue,
                        splashColor: Colors.blue[200],
                        child: WidgetsConstructor().makeText('Enviar informações', Colors.white, 18.0, 5.0, 5.0, 'center'),
                        onPressed: (){
                          setState(() {
                            isLoading=true;
                          });

                          _saveData(userModel, widget._moveClass);
                        }),
                  ),

                ],
              ),

              SizedBox(height: 25.0,),

            ],
          ),
        ),
      ),
    );

  }

  Widget _byePage(){
    return Container(
      width: widthPercent,
      height: heightPercent,
      color: Colors.white,
      child: Column(
        children: [

          Padding(
              child: WidgetsConstructor().makeText('Nós realmente pedimos desculpas e iremos trabalhar para resolver seu problema o mais rápido possível.', Colors.blue, 16.0, 25.0, 25.0, 'center'),
              padding: EdgeInsets.all(10.0)),

          SizedBox(height: 25.0,),


          Container(
            height: 60.0,
            width: widthPercent*0.85,
            child: RaisedButton(
              color: Colors.blue,
                splashColor: Colors.blue[200],
                child: WidgetsConstructor().makeText('Fechar', Colors.white, 18.0, 5.0, 5.0, 'center'),
                onPressed: (){

                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => HomePage()));

                }

            ),
          ),

        ],
      )
    );
  }



  void _saveData(UserModel userModel, MoveClass moveClass){

    void _onSucess(){

      FirestoreServices().deleteAscheduledMove(moveClass);
      FirestoreServices().createPunishmentEntryToTrucker(moveClass.freteiroId, 'user informed trucker never showup');

      _displaySnackBar(context, "Analisaremos suas informações e reembolsaremos o mais breve possível. Pedimos desculpas.", Colors.black87);
      showLandPage=false;
      showResumePage=false;
      showByePage=true;

      setState(() {
        isLoading=false;
      });
    }

    void _onFail(){
      _displaySnackBar(context, "Ops, ocorreu um erro. Tente novamente.", Colors.red);
      setState(() {
        isLoading=false;
      });
    }

    FirestoreServices().saveBankDataToDevolution(bankData, () { _onSucess();}, () { _onFail();});

  }

  //Widgets
  Widget _buildRadioOptionsBankTypeSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RadioButton(
          description: "Conta corrente",
          value: "cc",
          groupValue: AcountType,
          onChanged: (value) => setState(
                () => AcountType = value,
          ),
        ),
        RadioButton(

          description: "Poupança",
          value: "poup",
          groupValue: AcountType,
          onChanged: (value) => setState(
                () => AcountType = value,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOptionsBank(BuildContext context) {
    return Column(
      children: [

        Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: RadioButton(
                description: "Banco do Brasil",
                value: "bb",
                groupValue: bank,
                onChanged: (value) => setState(
                      () => bank = value,
                ),
              ),),
            Flexible(
              flex: 1,
              child: RadioButton(

                description: "Bradesco",
                value: "bradesco",
                groupValue: bank,
                onChanged: (value) => setState(
                      () => bank = value,
                ),
              ),
            ),
          ],
        ),

        Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: RadioButton(
                description: "Caixa",
                value: "caixa",
                groupValue: bank,
                onChanged: (value) => setState(
                      () => bank = value,
                ),
              ),),

            Flexible(
              flex: 1,
              child: RadioButton(

                description: "Itaú",
                value: "itau",
                groupValue: bank,
                onChanged: (value) => setState(
                      () => bank = value,
                ),
              ),
            ),


          ],
        ),

        Row(
          children: <Widget>[
            Flexible(
                flex: 1,
                child: RadioButton(
                  description: "Santander",
                  value: "santander",
                  groupValue: bank,
                  onChanged: (value) => setState(
                        () => bank = value,
                  ),
                )),
            Flexible(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    scrollToDown();
                    _otherBankFocusNode.requestFocus();
                  },
                  child: RadioButton(

                    description: "Outro",
                    value: "outro",
                    groupValue: bank,
                    onChanged: (value)=> setState(
                          () => bank = value,
                    ),
                  ),
                )
            ),


          ],
        ),

      ],
    );
  }

  Widget _textFieldNumberOnly(TextEditingController controller, String labelTxt, double width){

    return Container(
      width: width,
      child: TextField(

          controller: controller,
          decoration: InputDecoration(labelText: labelTxt),
          keyboardType: TextInputType.number
      ),
    );

  }

  Widget _textField(TextEditingController controller, String labelTxt, double width){

    return Container(
      width: width,
      child: TextField(
        controller: controller,
        //focusNode: focusNode,
        decoration: InputDecoration(labelText: labelTxt),
      ),
    );
  }

  Widget _textFieldWithFocusNode(TextEditingController controller, String labelTxt, double width, FocusNode focusNode){

    return Container(
      width: width,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(labelText: labelTxt),
      ),
    );
  }



  //functions

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  void scrollToDown() {
    final bottomOffset = _scrollController.position.pixels;
    _scrollController.animateTo(
      bottomOffset+150.0,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  _displaySnackBar(BuildContext context, String msg, Color color) {

    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: color,
      action: SnackBarAction(
        label: "Ok",
        textColor: Colors.white,
        onPressed: (){
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _goBack(BuildContext context) {
    if (showLandPage == true) {
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));
    }
  }


}
