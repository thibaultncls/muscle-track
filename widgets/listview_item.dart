import 'package:flutter/material.dart';

class ListViewItem extends StatelessWidget {
  final String text;
  final Function() onTap;
  const ListViewItem({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.95;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width,
        //height: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
            )
          ],
        ),
      ),
    );
  }
}
