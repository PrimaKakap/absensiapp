import 'package:flutter/material.dart';

class DetailInfoRow extends StatelessWidget {
final String label;
final String value;
const DetailInfoRow({
  super.key,
  required this.label,
  required this.value,
});


@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade200, width:1),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
      Expanded(flex: 3,
      child: Text(
        value,
        maxLines: 1,
        style: const TextStyle(color: Colors.black87,fontSize: 14, fontWeight: FontWeight.w500),
      ),)
      ],
    ),
  );
}
}