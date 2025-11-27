import 'package:flutter/material.dart';
import 'package:simple_shader/gen/shaders/my_shader.dart';

void main() async {
  await MyShader.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .spaceEvenly,
          children: [
            CustomPaint(
              size: Size(300, 100),
              painter: _MyPainter(
                color: Colors.purple,
                scale: 1.0 / 20.0,
              ),
            ),
            CustomPaint(
              size: Size(300, 100),
              painter: _MyPainter(
                color: Colors.orange,
                scale: 1.0 / 30.0,
              ),
            ),
            CustomPaint(
              size: Size(300, 100),
              painter: _MyPainter(
                color: Colors.yellow,
                scale: 1.0 / 40.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  _MyPainter({
    required this.color,
    required this.scale,
  });

  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final MyShader myShader = MyShader()
      ..uColor.color = color
      ..uScale = scale;

    Paint p = Paint()
      ..shader = myShader.shader;

    canvas.drawRect(Offset.zero & size, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}