import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

ThemeData createDarkTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.purple.shade300,
    primaryVariant: Colors.purple.shade500,
    secondary: Colors.green,
    secondaryVariant: Colors.green.shade500,
    background: Colors.white,
    surface: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    error: Colors.red.shade400,
  );

  return ThemeData.from(colorScheme: colorScheme).copyWith(
    applyElevationOverlayColor: false,
  );
}

GlobalKey<NavigatorState> a = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AlertProvider(
      child: MaterialApp(
        navigatorKey: a,
        title: 'Flutter Demo',
        theme: ThemeData.light(),
        // darkTheme: createDarkTheme(),
        home: HomePage(),
      ),
    );
  }
}

class AlertProvider extends StatefulWidget {
  final Widget child;

  AlertProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  static AlertProviderState of(
    BuildContext context, {
    bool rootNavigator = false,
  }) {
    // Handles the case where the input context is a navigator element.
    AlertProviderState? alertProvider;
    if (context is StatefulElement && context.state is AlertProviderState) {
      alertProvider = context.state as AlertProviderState;
    }
    if (rootNavigator) {
      alertProvider =
          context.findRootAncestorStateOfType<AlertProviderState>() ??
              alertProvider;
    } else {
      alertProvider = alertProvider ??
          context.findAncestorStateOfType<AlertProviderState>();
    }

    assert(() {
      if (alertProvider == null) {
        throw FlutterError(
          'AlertProvider operation requested with a context that does not include a AlertProvider.\n'
          'The context used to push or pop routes from the Navigator must be that of a '
          'widget that is a descendant of a AlertProvider widget.',
        );
      }
      return true;
    }());
    return alertProvider!;
  }

  @override
  AlertProviderState createState() => AlertProviderState();
}

class AlertProviderState extends State<AlertProvider>
    with TickerProviderStateMixin {
  OverlayEntry? _currentOverlay;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 300));

    _animationController.addListener(listenAnimation);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.removeListener(listenAnimation);
    super.dispose();
  }

  void listenAnimation() {
    if (_animationController.status == AnimationStatus.dismissed &&
        _currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  void showAlert(BuildContext context) {
    final overlayState = Overlay.of(context);

    _animationController.reset();
    _animationController.forward();

    _currentOverlay = OverlayEntry(builder: (context) {
      return Positioned(
        left: 20,
        bottom: 0,
        child: Material(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => Opacity(
              opacity: _animationController.value,
              child: Transform.translate(
                offset: Offset(0, -_animationController.value * 20),
                child: Container(
                  color: Colors.green,
                  width: MediaQuery.of(context).size.width - 40,
                  child: Text('Hello world'),
                ),
              ),
            ),
          ),
        ),
      );
    });

    overlayState?.insert(_currentOverlay!);

    Future.delayed(Duration(seconds: 5))
        .then((value) => _animationController.reverse());
  }

  void hideCurrentAlert() {
    _currentOverlay?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Second page'),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SecondPage()));
              },
            ),
            ElevatedButton(
              child: Text('Hide'),
              onPressed: () {
                AlertProvider.of(context).showAlert(context);
              },
            )
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('Show Flushbar and pop!'),
          onPressed: () {
            //   context.showAlert();
            AlertProvider.of(context).showAlert(context);
            Navigator.of(context).pop();
            // Flushbar(
            //   message: 'Pop!',
            //   onStatusChanged: print,
            //   duration: Duration(seconds: 4),
            //   routeColor: Colors.green.withOpacity(0.9),
            //   routeBlur: 1,
            //   blockBackgroundInteraction: true,
            // )..show(context);
            // //a.currentState?.pop();
          },
        ),
      ),
    );
  }
}
