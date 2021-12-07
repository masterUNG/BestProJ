import 'dart:convert';

import 'package:bestproj/utility/my_constant.dart';
import 'package:bestproj/widgets/show_image.dart';
import 'package:bestproj/widgets/show_textformfield.dart';
import 'package:bestproj/widgets/show_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:http/http.dart' as http;

class PayMent extends StatefulWidget {
  const PayMent({Key? key}) : super(key: key);

  @override
  _PayMentState createState() => _PayMentState();
}

class _PayMentState extends State<PayMent> {
  final formKey = GlobalKey<FormState>();

  String? creditCardId;

  String? amount;

  MaskTextInputFormatter creditCardIdMask =
      MaskTextInputFormatter(mask: '####-####-####-####');
  MaskTextInputFormatter dateMask = MaskTextInputFormatter(mask: '##/####');
  MaskTextInputFormatter cvvMask = MaskTextInputFormatter(mask: '###');

  String? dateStr;

  String? cvvStr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut().then((value) =>
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/authen', (route) => false));
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  newImage(constraints),
                  newTtile('Amount Money:'),
                  filedAmount(constraints),
                  newTtile('Credit Card ID:'),
                  filedCreditCardId(constraints),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      groupDate(),
                      groupCVV(),
                    ],
                  ),
                  buttonPayment(constraints),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column groupDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        newTtile('MM/YYYY'),
        fieldDate(),
      ],
    );
  }

  Column groupCVV() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        newTtile('CVV'),
        fieldCvv(),
      ],
    );
  }

  ShowTextFormField fieldDate() {
    return ShowTextFormField(
      hide: '02/2022',
      iconData: Icons.date_range,
      width: 150,
      funcValidate: myValidate,
      funcSave: saveDate,
      textInputFormatters: [dateMask],
    );
  }

  ShowTextFormField fieldCvv() {
    return ShowTextFormField(
      hide: '123',
      iconData: Icons.code,
      width: 150,
      funcValidate: myValidate,
      funcSave: saveCvv,
      textInputFormatters: [cvvMask],
    );
  }

  void saveCreditCardId(String? string) {
    creditCardId = creditCardIdMask.getUnmaskedText();
    print('creditCardId ==> $creditCardId');
  }

  void saveAmount(String? string) {
    amount = string;
    print('amount ==> $amount');
  }

  void saveDate(String? string) {
    dateStr = dateMask.getMaskedText();
    print('dateStr = $dateStr');
  }

  void saveCvv(String? string) {
    cvvStr = cvvMask.getMaskedText();
    print('cvvSt = $cvvStr');
  }

  String? myValidate(String? value) {
    if (value!.isEmpty) {
      return 'Please Fill in Blank';
    } else {
      return null;
    }
  }

  String? creditCartValidate(String? value) {
    if (value!.isEmpty) {
      return 'Please Fill Credit Card ID';
    } else {
      if (creditCardIdMask.getUnmaskedText().length != 16) {
        return 'Credit Card Id 16 Digi';
      } else {
        return null;
      }
    }
  }

  Row buttonPayment(BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: constraints.maxWidth * 0.6,
          child: ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                processChardCreditCard();
              }
            },
            child: const Text('Payment'),
          ),
        ),
      ],
    );
  }

  Future<void> processChardCreditCard() async {
    String publicKey = 'pkey_test_5pp9n4x6lu8v0riuskf';

    List<String> strings = dateStr!.split('/');
    String month = strings[0].trim();
    int monthInt = int.parse(month);
    month = monthInt.toString();
    String year = strings[1].trim();
    print('month = $month, year = $year');

    OmiseFlutter omiseFlutter = OmiseFlutter(publicKey);
    await omiseFlutter.token
        .create('Doramon', creditCardId!, month, year, cvvStr!)
        .then((value) async {
      String token = value.id.toString();
      print('token ==>>> $token');

      String secretKey = 'skey_test_5pj6xiqsml00cgz0ze2';

      String basicAuth = 'Basic ' + base64Encode(utf8.encode(secretKey + ":"));

      Map<String, String> headerMap = {};
      headerMap['authorization'] = basicAuth;
      headerMap['Cache-Control'] = 'no-cache';
      headerMap['Content-Type'] = 'application/x-www-form-urlencoded';

      amount = amount.toString() + '00';
      print('amount = $amount');

      Map<String, dynamic> data = {};
      data['amount'] = amount;
      data['currency'] = 'thb';
      data['card'] = token;

      String urlApiCharge = 'https://api.omise.co/charges';
      Uri uri = Uri.parse(urlApiCharge);

      http.Response response = await http.post(
        uri,
        headers: headerMap,
        body: data,
      );

      var status = json.decode(response.body)['status'];

      print('status Omise ==>> $status');
    });
  }

  Row filedAmount(BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShowTextFormField(
          hide: 'xxxx',
          iconData: Icons.money,
          width: constraints.maxWidth * 0.6,
          funcValidate: myValidate,
          funcSave: saveAmount,
          textInputType: TextInputType.number,
          textInputFormatters: [MaskTextInputFormatter(mask: '')],
        ),
      ],
    );
  }

  Row filedCreditCardId(BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShowTextFormField(
          hide: 'xxxx-xxxx-xxxx-xxxx',
          iconData: Icons.attach_money,
          width: constraints.maxWidth * 0.6,
          funcValidate: creditCartValidate,
          funcSave: saveCreditCardId,
          textInputType: TextInputType.number,
          textInputFormatters: [creditCardIdMask],
        ),
      ],
    );
  }

  Padding newTtile(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ShowTitle(
        title: title,
        textStyle: MyConstant().h2Style(),
      ),
    );
  }

  Row newImage(BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          width: constraints.maxWidth * 0.6,
          child: const ShowImage(),
        ),
      ],
    );
  }
}
