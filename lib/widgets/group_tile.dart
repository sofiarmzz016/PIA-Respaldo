// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:freeyourself_app/pages/chat_page.dart';
import 'package:freeyourself_app/widgets/widgets.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupTile(
    {super.key, 
    required this.groupId, 
    required this.groupName, 
    required this.userName
    }
  );

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        nextScreen(context, ChatPage(
          groupId: widget.groupId,
          groupName: widget.groupName,
          userName: widget.userName,
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal.shade500,
            child: Text(
              widget.groupName.substring(0,1).toUpperCase(), 
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          title: Text(
            widget.groupName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          subtitle: Text(
              "Te uniste a la conversación como ${widget.userName}",
              style: const TextStyle(fontSize: 13),
            ),
        ),
      ),
    );
  }
}