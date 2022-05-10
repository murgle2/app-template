import 'package:flutter/material.dart';
import 'package:frontend/resources/user_notifier.dart';
import 'package:provider/provider.dart';

class PanelItem extends StatelessWidget {
  final Widget child;

  const PanelItem({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
        builder: (context, userNotifier, _) => Container(
              width: 300,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
              decoration: BoxDecoration(
                  color: userNotifier.getColor(userNotifier.COLOR_PANEL),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: userNotifier.getColor(userNotifier.COLOR_BORDER))),
              child: DefaultTextStyle.merge(
                  style: TextStyle(
                      color: userNotifier.getColor(userNotifier.COLOR_TEXT), fontSize: 18),
                  child: this.child),
            ));
  }
}
