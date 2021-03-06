import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tencentplayer/flutter_tencentplayer.dart';
import 'package:skapp/store/root.dart';
import '../full_video_page.dart';
import '../main.dart';
import '../util/common_util.dart';
import '../util/time_util.dart';
import '../util/widget_util.dart';
import '../widget/tencent_player_linear_progress_indicator.dart';
import '../widget/triangle_painter.dart';

const List<double> rateList = [1.0, 1.2, 1.5, 2.0];

class TencentPlayerBottomWidget extends StatefulWidget {
  final Global global;
  final isShow;
  final showCover;
  final currentUrl;
  final showFullBtn;
  final TencentPlayerController controller;
  final VoidCallback behavingCallBack;
  final ValueChanged<int> changeClear;

  // UI
  final bool showClearBtn;

  TencentPlayerBottomWidget({
    this.global,
    this.isShow,
    this.showCover,
    this.currentUrl,
    this.controller,
    this.behavingCallBack,
    this.changeClear,
    this.showClearBtn,
    this.showFullBtn = true,
  });

  @override
  _TencentPlayerBottomWidgetState createState() =>
      _TencentPlayerBottomWidgetState();
}

class _TencentPlayerBottomWidgetState extends State<TencentPlayerBottomWidget> {
  TencentPlayerController get controller => widget.controller;

  int currentClearIndex = 0;
  bool isShowClearList = false;
  bool isShowRateList = false;

  List<String> transcodeList = ['标清', '高清', '超清'];

  @override
  void didUpdateWidget(TencentPlayerBottomWidget oldWidget) {
    if (oldWidget.isShow == true && widget.isShow == false) {
      if (mounted) {
        setState(() {
          isShowClearList = false;
          isShowRateList = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !widget.isShow,
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: _Style.bottomContainerH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  /// 播放暂停按键
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (controller.value.isPlaying) {
                        controller.pause();
                        if (widget.global.appAds.pause.show) {
                          widget.global.changeAppAdsPause(true);
                        }
                      } else {
                        controller.play();
                      }
                      widget.behavingCallBack?.call();
                    },
                    child: Container(
                      height: _Style.bottomContainerH,
                      padding: EdgeInsets.all(15.0),
                      child: Image.asset(
                        controller.value.isPlaying
                            ? 'assets/images/player_pause.png'
                            : 'assets/images/player_play.png',
                        width: _Style.iconPlayW,
                        height: _Style.iconPlayW,
                      ),
                    ),
                  ),

                  /// 进度条
                  Expanded(
                    child: BottomScrubber(
                      behavingCallBack: () {
                        widget.behavingCallBack?.call();
                      },
                      controller: controller,
                    ),
                  ),
                  // widget.showClearBtn
                  //     ? GestureDetector(
                  //         behavior: HitTestBehavior.opaque,
                  //         onTap: () {
                  //           // setState(() {
                  //           //   isShowClearList = !isShowClearList;
                  //           // });
                  //           widget.behavingCallBack?.call();
                  //         },
                  //         child: Container(
                  //             height: _Style.bottomContainerH,
                  //             alignment: Alignment.center,
                  //             padding: EdgeInsets.only(
                  //               left: 15,
                  //             ),
                  //             child: Text(
                  //               transcodeList[currentClearIndex],
                  //               style: TextStyle(
                  //                 color: Colors.white,
                  //                 fontSize: 12,
                  //               ),
                  //               textAlign: TextAlign.center,
                  //             )),
                  //       )
                  //     : SizedBox(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          isShowRateList = !isShowRateList;
                        });
                      }
                      widget.behavingCallBack?.call();
                    },
                    child: Container(
                      height: _Style.bottomContainerH,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: Text(
                        '${controller.value.rate}X',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  widget.showCover
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.showFullBtn
                                ? Navigator.of(context).push(
                                    CustomRoute(
                                      FullVideoPage(
                                        controller: controller,
                                        playType: PlayType.network,
                                        dataSource: widget.currentUrl,
                                        global: widget.global,
                                      ),
                                    ),
                                  )
                                : Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.only(right: 10),
                            child: widget.showFullBtn
                                ? Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.fullscreen_exit,
                                    color: Colors.white,
                                  ),
                            // Image.asset(
                            //     'assets/images/full_screen_on.png',
                            //     width: 20,
                            //     height: 20),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),

          /// 清晰度选择框
          // isShowClearList
          //     ? Positioned(
          //         right: 60,
          //         bottom: _Style.clearItemContainerBottom,
          //         child: Column(
          //           children: <Widget>[
          //             Container(
          //               width: _Style.clearListContainerW,
          //               padding: EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //               decoration: BoxDecoration(
          //                 color: Color(0x7f000000),
          //                 borderRadius: BorderRadius.all(Radius.circular(5.0)),
          //               ),
          //               child: Column(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: transcodeList.map((String transcode) {
          //                   int index = transcodeList.indexOf(transcode);
          //                   bool isLastOne = index == transcodeList.length - 1;
          //                   return GestureDetector(
          //                     behavior: HitTestBehavior.opaque,
          //                     onTap: () {
          //                       currentClearIndex = index;
          //                       isShowClearList = false;
          //                       widget.changeClear?.call(currentClearIndex);
          //                       widget.behavingCallBack?.call();
          //                       setState(() {});
          //                     },
          //                     child: Container(
          //                       alignment: Alignment.center,
          //                       height: _Style.clearItemContainerH,
          //                       decoration: BoxDecoration(
          //                           border: isLastOne
          //                               ? null
          //                               : Border(
          //                                   bottom: BorderSide(
          //                                       width: 0.3,
          //                                       color: Color(0xffeeeeee)))),
          //                       child: Text(
          //                         transcode,
          //                         style: currentClearIndex == index
          //                             ? TextStyle(
          //                                 color: Color(0xfff24724),
          //                                 fontSize: 12,
          //                               )
          //                             : TextStyle(
          //                                 color: Colors.white,
          //                                 fontSize: 12,
          //                               ),
          //                       ),
          //                     ),
          //                   );
          //                 }).toList(),
          //               ),
          //             ),
          //             Container(
          //               width: 12,
          //               height: 6,
          //               child: CustomPaint(
          //                 painter: TrianglePainter(context),
          //               ),
          //             ),
          //           ],
          //         ),
          //       )
          //     : SizedBox(),

          /// 播放速度选择框
          isShowRateList && widget.isShow
              ? Positioned(
                  right: 20,
                  bottom: _Style.clearItemContainerBottom,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: _Style.clearListContainerW,
                        padding: EdgeInsets.only(bottom: 10, left: 5, right: 5),
                        decoration: BoxDecoration(
                          color: Color(0x7f000000),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: rateList.map((double rate) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                isShowRateList = false;
                                controller.setRate(rate);
                                widget.behavingCallBack?.call();
                                setState(() {});
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: _Style.clearItemContainerH,
                                decoration: BoxDecoration(
                                    border:
                                        rate == rateList[rateList.length - 1]
                                            ? null
                                            : Border(
                                                bottom: BorderSide(
                                                    width: 0.3,
                                                    color: Color(0xffeeeeee)))),
                                child: Text(
                                  '$rate倍',
                                  style: controller.value.rate == rate
                                      ? TextStyle(
                                          color: Color(0xfff24724),
                                          fontSize: 12,
                                        )
                                      : TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 6,
                        child: CustomPaint(
                          painter: TrianglePainter(context),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

class BottomScrubber extends StatefulWidget {
  final TencentPlayerController controller;
  final VoidCallback behavingCallBack; //正在交互

  BottomScrubber({
    @required this.controller,
    this.behavingCallBack,
  });

  @override
  _BottomScrubberState createState() => _BottomScrubberState();
}

class _BottomScrubberState extends State<BottomScrubber> {
  GlobalKey currentKey = GlobalKey();
  bool _controllerWasPlaying = false;

  TencentPlayerController get controller => widget.controller;

  Duration seekPos;

  void seekToRelativePosition(Offset globalPosition) {
    double width = WidgetUtil.findGlobalRect(currentKey).width;
    double xOffSet =
        WidgetUtil.globalOffsetToLocal(currentKey, globalPosition).dx;
    final double relative = xOffSet / width;
    seekPos = controller.value.duration * relative;
    setState(() {});

    /// 回调正在交互，用来做延迟隐藏cover
    CommonUtils.throttle(() {
      widget.behavingCallBack?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration showDuration =
        seekPos != null ? seekPos : controller.value.position;

    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            key: currentKey,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: _Style.bottomContainerH,
              padding: EdgeInsets.symmetric(
                  vertical: _Style.bottomContainerH / 2 - 1.5),
              child: Container(
                height: 3,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    LinearProgressIndicator(
                      value: controller.value.duration.inMilliseconds <= 0
                          ? 0
                          : controller.value.playable.inMilliseconds /
                              controller.value.duration.inMilliseconds,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xccffffff)),
                      backgroundColor: Color(0x33ffffff),
                    ),
                    TencentLinearProgressIndicator(
                      value: controller.value.duration.inMilliseconds <= 0
                          ? 0
                          : showDuration.inMilliseconds /
                              controller.value.duration.inMilliseconds,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                      backgroundColor: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
            onHorizontalDragStart: (DragStartDetails details) {
              if (!controller.value.initialized) {
                return;
              }
              _controllerWasPlaying = controller.value.isPlaying;
              if (_controllerWasPlaying) {
                controller.pause();
              }
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              if (!controller.value.initialized) {
                return;
              }
              seekToRelativePosition(details.globalPosition);
            },
            onHorizontalDragEnd: (DragEndDetails details) async {
              await controller.seekTo(seekPos);
              seekPos = null;
              setState(() {});
              if (_controllerWasPlaying) {
                controller.play();
              }
            },
            onTapDown: (TapDownDetails details) async {
              if (!controller.value.initialized) {
                return;
              }
              seekToRelativePosition(details.globalPosition);
              await controller.seekTo(seekPos);
              seekPos = null;
              setState(() {});
            },
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          constraints: BoxConstraints(minWidth: 80),
          height: _Style.bottomContainerH,
          alignment: Alignment.centerRight,
          child: Text(
            TimeUtil.formatDuration(showDuration) +
                '/' +
                TimeUtil.formatDuration(controller.value.duration),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _Style {
  static double bottomContainerH = 50;
  static double loadingImgW = 53;
  static double iconPlayW = 24;
  static double clearListContainerW = 65;
  static double clearItemContainerH = 36;
  static double clearItemContainerBottom = 36;
}

class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  //构造方法
  CustomRoute(this.widget)
      : super(
          transitionDuration: Duration(seconds: 2), //过渡时间
          pageBuilder: (
            //构造器
            BuildContext context,
            Animation<double> animation1,
            Animation<double> animation2,
          ) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
              Widget child) {
            //旋转+缩放动画效果
            // return RotationTransition(
            //   turns: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            //       parent: animation1, curve: Curves.fastOutSlowIn)),
            //   child: ScaleTransition(
            //     scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            //         parent: animation1, curve: Curves.fastOutSlowIn)),
            //     child: child,
            //   ),
            // );
            // return FadeTransition(
            //   opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            //     parent: animation1,
            //     curve: Curves.fastOutSlowIn, //动画曲线
            //   )),
            //   child: child,
            // );
            return child;
          },
        );
}
