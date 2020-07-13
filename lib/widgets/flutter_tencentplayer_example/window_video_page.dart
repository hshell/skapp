import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:skapp/store/details/details.dart';
import 'package:skapp/store/root.dart';
// import './full_video_page.dart';
import './widget/tencent_player_bottom_widget.dart';
import './widget/tencent_player_gesture_cover.dart';
import './widget/tencent_player_loading.dart';
import 'package:screen/screen.dart';
import 'package:flutter_tencentplayer/flutter_tencentplayer.dart';
import './main.dart';
import './util/forbidshot_util.dart';
import 'full_video_page.dart';

// widget.store.currentUrl

class WindowVideoPage extends StatefulWidget {
  final DetailsStore store;
  final Global global;
  PlayType playType;

  //UI
  bool showBottomWidget;
  bool showClearBtn;

  WindowVideoPage({
    this.showBottomWidget = true,
    this.showClearBtn = true,
    this.playType = PlayType.network,
    this.global,
    this.store,
  });

  @override
  _WindowVideoPageState createState() => _WindowVideoPageState();
}

class _WindowVideoPageState extends State<WindowVideoPage> {
  TencentPlayerController controller;
  VoidCallback listener;
  DeviceOrientation deviceOrientation;

  bool isLock = false;
  bool showCover = false;
  Timer timer;

  String dataSource = '';

  _WindowVideoPageState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIOverlays([]);
    _initController();
    controller.initialize();
    controller.addListener(listener);
    hideCover();
    ForbidShotUtil.initForbid(context);
    Screen.keepOn(true);
  }

  @override
  void dispose() {
    super.dispose();
    // SystemChrome.setEnabledSystemUIOverlays(
    //     [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    controller.removeListener(listener);
    controller.dispose();
    ForbidShotUtil.disposeForbid();
    Screen.keepOn(false);
  }

  _initController() {
    dataSource = widget.store.currentUrl;
    switch (widget.playType) {
      case PlayType.network:
        controller = TencentPlayerController.network(
          dataSource,
          playerConfig: PlayerConfig(autoPlay: false),
        );
        break;
      case PlayType.asset:
        controller = TencentPlayerController.asset(
          dataSource,
          playerConfig: PlayerConfig(autoPlay: false),
        );
        break;
      case PlayType.file:
        controller = TencentPlayerController.file(
          dataSource,
          playerConfig: PlayerConfig(autoPlay: false),
        );
        break;
      case PlayType.fileId:
        controller = TencentPlayerController.network(null,
            playerConfig: PlayerConfig(
                autoPlay: false,
                auth: {"appId": 1252463788, "fileId": dataSource}));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 判断是否切换了源
    if (dataSource != widget.store.currentUrl) {
      dataSource = widget.store.currentUrl;
      // 切换播放源
      controller?.removeListener(listener);
      controller?.pause();
      controller = TencentPlayerController.network(
        dataSource,
      );
      controller?.initialize().then((_) {
        if (mounted) setState(() {});
      });
      controller?.addListener(listener);
    }
    return Observer(builder: (_) {
      return AspectRatio(
        aspectRatio: 16.0 / 9.0, // 宽高比
        child: Container(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              hideCover();
            },
            onDoubleTap: () {
              if (!widget.showBottomWidget || isLock) return;
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            child: Container(
              color: Colors.black,
              child: Stack(
                overflow: Overflow.visible,
                alignment: Alignment.center,
                children: <Widget>[
                  /// 视频
                  /// 加广告位
                  widget.store.showAd
                      ? CountDownWidget(
                          timer: widget.global.appAds.prestrain.timer,
                          onCountDownFinishCallBack: (bool value) {
                            if (value) {
                              widget.store.changeShowAd(false);
                            }
                          },
                        )
                      : Container(
                          child: Text('播放电影'),
                        ),
                  // controller.value.initialized
                  //     ? AspectRatio(
                  //         aspectRatio: controller.value.aspectRatio,
                  //         child: TencentPlayer(controller),
                  //       )
                  //     : SizedBox(),

                  /// 支撑全屏
                  Container(),

                  /// 半透明浮层
                  showCover ? Container(color: Color(0x1f000000)) : SizedBox(),

                  /// 处理滑动手势
                  Offstage(
                    offstage: isLock,
                    child: TencentPlayerGestureCover(
                      controller: controller,
                      showBottomWidget: widget.showBottomWidget,
                      behavingCallBack: delayHideCover,
                    ),
                  ),

                  /// 加载loading
                  TencentPlayerLoading(
                    controller: controller,
                    iconW: 53,
                  ),

                  /// 头部浮层
                  !isLock && showCover
                      ? Positioned(
                          top: 0,
                          left: MediaQuery.of(context).padding.top,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.only(top: 14, left: 14),
                              child: Image.asset(
                                'assets/images/icon_back.png',
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),

                  /// 锁
                  showCover
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  isLock = !isLock;
                                });
                              }
                              delayHideCover();
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top,
                                right: 20,
                                bottom: 20,
                                left: 12,
                              ),
                              child: Icon(
                                isLock ? Icons.lock_outline : Icons.lock_open,
                                color: Colors.white,
                              ),

                              // Image.asset(
                              //   isLock
                              //       ? 'assets/images/player_lock.png'
                              //       : 'assets/images/player_unlock.png',
                              //   width: 38,
                              //   height: 38,
                              // ),
                            ),
                          ),
                        )
                      : SizedBox(),

                  /// 进度、清晰度、速度
                  Offstage(
                    offstage: !widget.showBottomWidget,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).padding.top,
                          right: MediaQuery.of(context).padding.bottom),
                      child: TencentPlayerBottomWidget(
                        isShow: !isLock && showCover,
                        showCover: showCover,
                        currentUrl: widget.store.currentUrl,
                        controller: controller,
                        showClearBtn: widget.showClearBtn,
                        behavingCallBack: () {
                          delayHideCover();
                        },
                        changeClear: (int index) {
                          changeClear(index);
                        },
                      ),
                    ),
                  ),

                  /// 全屏按钮
                  // showCover
                  //     ? Positioned(
                  //         right: 0,
                  //         bottom: 20,
                  //         child: GestureDetector(
                  //           behavior: HitTestBehavior.opaque,
                  //           onTap: () {
                  //             Navigator.of(context).push(CupertinoPageRoute(
                  //                 builder: (_) => FullVideoPage(
                  //                     controller: controller,
                  //                     playType: PlayType.network)));
                  //           },
                  //           child: Container(
                  //             padding: EdgeInsets.all(20),
                  //             child: Image.asset(
                  //                 'assets/images/full_screen_on.png',
                  //                 width: 20,
                  //                 height: 20),
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  List<String> clearUrlList = [
    'http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/e1ab85305285890781763144364/v.f10.mp4',
    'http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/e1ab85305285890781763144364/v.f20.mp4',
    'http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/e1ab85305285890781763144364/v.f30.mp4',
  ];

  changeClear(int urlIndex, {int startTime}) {
    controller?.removeListener(listener);
    controller?.pause();
    controller = TencentPlayerController.network(clearUrlList[urlIndex],
        playerConfig: PlayerConfig(
            startTime: startTime ?? controller.value.position.inSeconds));
    controller?.initialize()?.then((_) {
      if (mounted) setState(() {});
    });
    controller?.addListener(listener);
  }

  hideCover() {
    if (!mounted) return;
    setState(() {
      showCover = !showCover;
    });
    delayHideCover();
  }

  delayHideCover() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    if (showCover) {
      timer = new Timer(Duration(seconds: 6), () {
        if (!mounted) return;
        setState(() {
          showCover = false;
        });
      });
    }
  }
}

class CountDownWidget extends StatefulWidget {
  final onCountDownFinishCallBack;
  final int timer;

  CountDownWidget(
      {Key key, @required this.timer, @required this.onCountDownFinishCallBack})
      : super(key: key);

  @override
  _CountDownWidgetState createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget> {
  Timer _timer;
  int _seconds;
  @override
  void initState() {
    super.initState();
    _seconds = widget.timer;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        child: Container(
          width: 0,
          height: 0,
        ));
  }

  /// 启动倒计时的计时器。
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
      if (_seconds <= 1) {
        widget.onCountDownFinishCallBack(true);
        _cancelTimer();
        return;
      }
      _seconds--;
    });
  }

  /// 取消倒计时的计时器。
  void _cancelTimer() {
    _timer?.cancel();
  }
}
