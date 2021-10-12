import 'package:flutter/material.dart';
import 'package:oqueue/auth_screen.dart';
import './queue_list_screen.dart';
import 'api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name
      title: 'OQueue',
      // Application theme data, you can set the colors for the application as
      // you want
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      // A widget which will be started on application startup
      home: Builder(
        builder: (context) => AuthScreen(
          authApi: authApi,
          onAuth: (api) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QueueListScreen(api: api)),
            );
          }
        )
      ),// QueueListScreen(),
    );
  }
}

// class RootPage extends StatelessWidget {
//   final String title;
//
//   const MyHomePage({@required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // The title text which will be shown on the action bar
//         title: Text(title),
//       ),
//       body: Center(
//         child: Text(
//           'Hello, F!',
//         ),
//       ),
//     );
//   }
// }