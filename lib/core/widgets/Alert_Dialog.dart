import 'package:flutter/material.dart';

class AdvanceCustomAlert extends StatelessWidget {
  const AdvanceCustomAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Stack(
          //overflow: Overflow.visible,
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'Turn on Internet Connection.',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // primary: Colors.red,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // <-- Radius
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, bottom: 10, left: 15, right: 15),
                          child: Text("Okay", style: TextStyle(fontSize: 18)),
                        )),
                  ],
                ),
              ),
            ),
            Positioned(
                top: -40,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 50,
                  child: Image.asset('assets/images/network.png'),
                  // Icon(Icons.assistant_photo, color: Colors.white, size: 50,),
                )),
          ],
        ));
  }
}
