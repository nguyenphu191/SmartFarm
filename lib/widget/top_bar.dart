import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key, required this.title, this.isBack = true});
  final String title;
  final bool isBack;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Container(
      height: 70 * pix,
      width: size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 28, 214, 66),
            Color.fromARGB(255, 10, 146, 0)
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: pix * 50,
            margin: EdgeInsets.only(top: 0 * pix),
            child: widget.isBack
                ? IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  )
                : SizedBox(),
          ),
          Container(
            width: size.width - 100 * pix,
            height: 60 * pix,
            padding: EdgeInsets.only(top: 16 * pix),
            child: Text(
              '${widget.title}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 * pix,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'BeVietnamPro'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
