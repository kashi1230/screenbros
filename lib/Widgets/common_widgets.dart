import 'package:flutter/material.dart';
import 'package:screenbroz2/Widgets/TextBuilder.dart';


Widget FButton({onpress,required String title}){
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        backgroundColor:Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),)),
    onPressed: onpress,
    child: Text(title,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 15),),
  );
}

//
Widget HButton ({String ?text  ,ontap ,icon}){
  return
    TextButton(
      onPressed: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Text(
          text!,
          style: TextStyle(color: Colors.white, fontSize: 13.0),
        ),
      ),
    );
}

Widget IButton(icon ,ontap){
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40.0),
      color: Colors.red, // Background color
    ),
    child: IconButton(
      icon: Icon(icon),
      color: Colors.white, // Icon color
      onPressed: ontap,
    ),
  );
}

//cancele Text Button
Widget CancelButton({ontap , required String title}){
  return TextButton(
    onPressed: ontap,
    child: Text(title,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
  );
}
Widget loginButton({ontap,required  width,required String text,height}) {
  return GestureDetector(
    onTap: ontap,
    child: Container(
      child: TextBuilder(text: text, fontSize: 15, color: Colors.white),
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)
          ],
          color: Colors.blue
      ),
    ),
  );
}