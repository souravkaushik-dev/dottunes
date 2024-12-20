import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController controller = TextEditingController();
  Uuid uuid = const Uuid();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future _addUserData(String name) async {
    await Hive.box('settings').put('name', name.trim());

    final String userId = uuid.v1();
    await Hive.box('settings').put('userId', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: MediaQuery.of(context).size.width / 1.85,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: const Image(
                  image: AssetImage('assets/icon-white-trans.png'),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await _addUserData('Guest'); // Hardcoded 'Guest' text
                        Navigator.popAndPushNamed(context, '/pref');
                      },
                      child: Text(
                        'Skip', // Hardcoded 'Skip' text
                        style: TextStyle(color: Colors.grey.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Black\nHole\n',
                                  style: TextStyle(
                                    height: 0.97,
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Music',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 80,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 80,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  bottom: 5,
                                  left: 10,
                                  right: 10,
                                ),
                                height: 57.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey[900],
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5.0,
                                      offset: Offset(0.0, 3.0),
                                    )
                                  ],
                                ),
                                child: TextField(
                                  controller: controller,
                                  textAlignVertical: TextAlignVertical.center,
                                  textCapitalization: TextCapitalization.sentences,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1.5,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    border: InputBorder.none,
                                    hintText: 'Enter your name', // Hardcoded text
                                    hintStyle: const TextStyle(color: Colors.white60),
                                  ),
                                  onSubmitted: (String value) async {
                                    if (value.trim() == '') {
                                      await _addUserData('Guest'); // Hardcoded 'Guest' text
                                    } else {
                                      await _addUserData(value.trim());
                                    }
                                    Navigator.popAndPushNamed(context, '/pref');
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (controller.text.trim() == '') {
                                    await _addUserData('Guest'); // Hardcoded 'Guest' text
                                  } else {
                                    await _addUserData(controller.text.trim());
                                  }
                                  Navigator.popAndPushNamed(context, '/pref');
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                                  height: 55.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Theme.of(context).colorScheme.secondary,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        offset: Offset(0.0, 3.0),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Get Started', // Hardcoded 'Get Started' text
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  'Disclaimer: By using this app, you agree to our terms of service.', // Hardcoded disclaimer text
                                  style: TextStyle(color: Colors.grey.withOpacity(0.7)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
