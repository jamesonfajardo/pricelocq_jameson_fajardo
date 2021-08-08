import 'package:flutter/material.dart';
import '../const/colors.dart';

AppBar dynamicAppBar({isUserSearching, iconTapCallback, textFieldCallback}) {
  return AppBar(
    // toggle textfield depending on bool value
    bottom: isUserSearching == false
        ? null
        : PreferredSize(
            // container is used to set textfield width, padding, etc.
            child: Container(
              padding: EdgeInsets.only(bottom: 30),
              width: 300,
              child: TextField(
                autofocus: true,
                onChanged: textFieldCallback,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            // app bar height is 56px by default
            preferredSize: Size.fromHeight(isUserSearching == false ? 56 : 100),
          ),
    automaticallyImplyLeading: false, // disable appbar's back button
    title: Text('Search Station'),
    backgroundColor: kViolet,
    centerTitle: true,
    actions: [
      // open search
      GestureDetector(
        onTap: iconTapCallback,
        child: Icon(isUserSearching == false ? Icons.search : Icons.close),
      ),
      SizedBox(width: 16),
    ],
  );
}
