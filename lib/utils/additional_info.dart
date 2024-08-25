import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AdditionalInfo extends StatelessWidget {
  String title = '';
  String value = '';
  IconData icon;
  AdditionalInfo({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Container(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Icon(
                icon,
                size: 32,
                color: Colors.blue,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
