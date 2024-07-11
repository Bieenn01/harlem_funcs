import 'package:harlem/buttons_array.dart';
import 'package:harlem/ftp_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:restart_app/restart_app.dart';


class WidgetButton extends StatefulWidget {
  const WidgetButton({super.key});

  @override
  State<WidgetButton> createState() => _WidgetButtonState();
}

class _WidgetButtonState extends State<WidgetButton> {
  late PermissionStatus _locationPermissionStatus = PermissionStatus.denied;
  late PermissionStatus _cameraPermissionStatus = PermissionStatus.denied;
  late PermissionStatus _readAndwritesPermissionStatus =
      PermissionStatus.denied;


  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    _locationPermissionStatus = await Permission.location.request();
    _cameraPermissionStatus = await Permission.camera.request();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            centerTitle: true, backgroundColor: Colors.black, actions: []),
        body: Container(
          color: Colors.black87,
          child: Center(
            child: SingleChildScrollView(
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 5,
                      color: Color.fromARGB(255, 179, 153, 153),
                    ),
                    color: Color.fromARGB(255, 230, 225, 225),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ArrayWidgetButtons(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 218, 235),
                          ),
                          icon: Icon(Icons.data_array_outlined),
                          label: Text(
                            'Array List',
                            style: TextStyle(
                                fontSize: 18), // Adjust font size as needed
                          ),
                        ),
                      ),
                      Divider(),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/qrscanner-default');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 218, 235),
                          ),
                          icon: Icon(Icons.camera_alt_rounded),
                          label: Text(
                            'Default Scanner',
                            style: TextStyle(
                                fontSize: 18), // Adjust font size as needed
                          ),
                        ),
                      ),
                      Divider(),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/mysql-intergration');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 218, 235),
                          ),
                          icon: Icon(Icons.donut_small_sharp),
                          label: Text(
                            'MySQL Information Viewing',
                            style: TextStyle(
                                fontSize: 18), // Adjust font size as needed
                          ),
                        ),
                      ),
                      Divider(),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/qrscanner-mysql');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 218, 235),
                          ),
                          icon: Icon(Icons.qr_code_scanner_rounded),
                          label: Text(
                            'MySQL Scanner Integration',
                            style: TextStyle(
                                fontSize: 18), // Adjust font size as needed
                          ),
                        ),
                      ),
                      Divider(),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FTPServerWidget(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 218, 235),
                          ),
                          icon: Icon(Icons.drive_folder_upload_outlined),
                          label: Text(
                            'FTP Integration Flutter',
                            style: TextStyle(
                                fontSize: 18), // Adjust font size as needed
                          ),
                        ),
                      ),
                      Divider(),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/thermal-printer');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 218, 235),
                          ),
                          icon: Icon(Icons.print),
                          label: Text(
                            'Thermal Printer Flutter',
                            style: TextStyle(
                                fontSize: 18), // Adjust font size as needed
                          ),
                        ),
                      ),
                      Divider(),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/qr-generator');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 218, 235),
                          ),
                          icon: Icon(Icons.qr_code_2_rounded),
                          label: Text(
                            'Qr Generator',
                            style: TextStyle(
                                fontSize: 18), // Adjust font size as needed
                          ),
                        ),
                      ),
                      Divider(),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/pdf-viewer');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 218, 235),
                          ),
                          icon: Icon(Icons.picture_as_pdf),
                          label: Text(
                            'View PDF',
                            style: TextStyle(
                                fontSize: 18), // Adjust font size as needed
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 14,
      width: 14,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
