import 'package:flutter/material.dart';

class StateBar extends StatefulWidget {
  // 상태 위셎의 크기
  final double w;
  final double h;

  // 진해도
  final double progress;
  const StateBar({super.key, required this.w, required this.h, required this.progress});

  @override
  State<StatefulWidget> createState() => _StateBar();
}

class _StateBar extends State<StateBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        width: widget.w,
        height: widget.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0x00e7e9f0).withOpacity(0.2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '진행률',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  width: 150,
                  height: 5,
                  child: Stack(children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    FractionallySizedBox(
                        widthFactor: widget.progress, // 진행도
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                          ),
                        ))
                  ])),
              Text(
                '${(widget.progress*100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
