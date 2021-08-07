import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogManager {
  final BuildContext? _context;

  DialogManager(this._context);

  // create a centered spinner/circular progress indicator.
  Future showSpinner(
      {String label = '',
      Color? color = Colors.pink,
      bool dismissable = true}) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color!,
          ),
          Container(margin: EdgeInsets.only(left: 7), child: Text(label)),
        ],
      ),
    );

    return showDialog(
      useRootNavigator: true,
      barrierDismissible: dismissable,
      context: _context!,
      builder: (_) {
        return alert;
      },
    );
  }

  // show material alert dialog
  Future showAlert({
    String? title = 'Alert',
    String? message = '',
    additionalActions,
    isCupertino = false,
  }) {
    var alert;
    if (!isCupertino) {
      alert = AlertDialog(
        title: Text(
          title!,
          style: TextStyle(color: Colors.pink),
        ),
        content: Text(message!),
        actions: [
          /*
        ** keep the actions list empty so that we can easily
        ** add default actions. Uncomment the textbutton below
        ** to see how default actions work
        */

          // TextButton(
          //   onPressed: () => close(),
          //   child: Text("Dismiss"),
          // ),

          // null aware spread for additional dialog options
          ...?additionalActions
        ],
      );
    } else {
      alert = CupertinoAlertDialog(
        title: Text(title!),
        content: Text(message!),
        actions: [
          /*
        ** keep the actions list empty so that we can easily
        ** add default actions. Uncomment the textbutton below
        ** to see how default actions work
        */

          // TextButton(
          //   onPressed: () => close(),
          //   child: Text("Dismiss"),
          // ),

          // null aware spread for additional dialog options
          ...?additionalActions
        ],
      );
    }

    return showDialog(
      context: _context!,
      builder: (_) {
        return alert;
      },
    );
  }

  void close() {
    return Navigator.pop(this._context!);
  }
}
