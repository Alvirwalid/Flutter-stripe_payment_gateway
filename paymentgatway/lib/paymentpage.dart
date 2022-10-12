// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class paymentPage extends StatefulWidget {
  paymentPage({super.key});

  @override
  State<paymentPage> createState() => _paymentPageState();
}

class _paymentPageState extends State<paymentPage> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                    onPressed: () async {
                      await makepayment();
                    },
                    child: Text('Pay')),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makepayment() async {
    try {
      paymentIntent = await createPayment('50', 'USD');
      //  print('${paymentIntent}');
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                customFlow: true,
                paymentIntentClientSecret: paymentIntent!['client_secret'],
                customerId: paymentIntent!['id'],
                //customerEphemeralKeySecret:paymentIntent['']
                merchantDisplayName: 'ALVI',
                style: ThemeMode.dark),
          )
          .then((value) => null);

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
              parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntent!['client_secret'],
        confirmPayment: true,
      ))
          .then((value) {
        print('payment intent${paymentIntent!['id'].toString()}');
        print('payment intent${paymentIntent!['client_secret'].toString()}');
        print('payment intent${paymentIntent!['amount'].toString()}');
        setState(() {
          paymentIntent = null;
        });
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Paid Successfully')));
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');

      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: Text('Cancelled'),
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

  createPayment(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      print(body);

      var respons = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51LFFSDCboHDzvRqLlAwVnOGjTpiKVIY24Ek2AVL2EqkeP7DjQQdouQdASZ3lFkKY1cd2tjAu7Xl1rLHGApqAuC5400udqb9lOq',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      print('Create Intent reponse ${respons.body.toString()}');

      return jsonDecode(respons.body);
    } catch (e) {
      print('exception is ${e.toString()}');
    }
  }

  calculateAmount(String amount) {
    final price = int.parse(amount);
    return price.toString();
  }
}
