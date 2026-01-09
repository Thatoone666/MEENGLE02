import 'package:flutter/material.dart';

class ResponsiveChatLayout extends StatelessWidget {
  final Widget messageList;
  final Widget inputArea;
  final Widget appBar;
  final bool isWideScreen;
  final Widget? sidePanel;
  final bool showSidePanel;

  const ResponsiveChatLayout({
    super.key,
    required this.messageList,
    required this.inputArea,
    required this.appBar,
    required this.isWideScreen,
    this.sidePanel,
    this.showSidePanel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              appBar,
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 800 : double.infinity,
                    ),
                    child: messageList,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 800 : double.infinity,
                ),
                child: inputArea,
              ),
            ],
          ),
        ),
        if (isWideScreen && showSidePanel && sidePanel != null)
          sidePanel!,
      ],
    );
  }
}