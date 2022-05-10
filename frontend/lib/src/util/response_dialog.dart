import 'package:flutter/material.dart';
import 'package:frontend/resources/config.dart';

class ResponseDialog extends StatelessWidget {
  final dynamic response;
  final bool isError;

  const ResponseDialog(
      {Key? key, required this.response, required this.isError})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: COLOR_TRANSPARENT,
      title: Text(isError ? "Please try again" : "Success",
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(response),
      actions: [
        TextButton(
          child: Text("Ok", style: TextStyle(color: COLOR_RED)),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
