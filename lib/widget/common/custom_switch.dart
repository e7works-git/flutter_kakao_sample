import 'package:flutter/material.dart';
import 'package:flutter_messenger/widget/common/anchor.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final Future<bool> Function(bool)? onChange;
  final Duration duration;
  final Curve curve;
  const CustomSwitch({
    super.key,
    required this.value,
    this.onChange,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.ease,
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late bool value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  void clickHandler() async {
    value = !value;
    if (widget.onChange != null) {
      var ok = await widget.onChange!(value);
      if (!ok) {
        value = false;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Anchor(
      onTap: clickHandler,
      child: SizedBox(
        width: 16,
        height: 10,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: widget.duration,
              curve: widget.curve,
              width: 14,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                color:
                    value ? const Color(0xffc9ddff) : const Color(0xffcccccc),
              ),
            ),
            AnimatedPositioned(
              left: value ? 6 : 0,
              duration: widget.duration,
              curve: widget.curve,
              child: AnimatedContainer(
                duration: widget.duration,
                curve: widget.curve,
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      value ? const Color(0xff2a61be) : const Color(0xff999999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
