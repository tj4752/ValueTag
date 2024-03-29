import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ValueTag',
      initialRoute: MyHomePage.id,
      routes: {
        MyHomePage.id: (context) => MyHomePage(),
        Registration.id: (context) => Registration(),
        Chat.id: (context) => Chat(),
      },
    );
  }
}
class MyHomePage extends StatefulWidget{
  static const String id = "HOMESCREEN";
  @override
  _MyHomePage createState() => _MyHomePage();
}
class _MyHomePage extends State<MyHomePage> {

  String email;
  String password;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser() async {
    FirebaseUser user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          user: user,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
           Hero(
           tag: 'logo',
      child: Container(
        width: 200.0,
        child: Image.asset("assets/logo.png"),
      ),
    ),
    SizedBox(
    height: 50,
    ),
    Container(
    width: 300,
    child: TextField(
    keyboardType: TextInputType.emailAddress,
    onChanged: (value) => email = value,
    decoration: InputDecoration(
    hintText: "Enter Your Email",
    icon: Icon(Icons.email)
    ),
    )),
    Container(
    width: 300,
    child: TextField(
    obscureText: true,
    keyboardType: TextInputType.emailAddress,
    onChanged: (value) => password = value,
    decoration: InputDecoration(
    hintText: "Enter Your Password",
    icon: Icon(Icons.lock_outline)
    ),
    )),
    SizedBox(
    height: 20,
    ),
        CustomButton(
          text: "Log In",
          callback: () async {
            await loginUser();
          },),
    SizedBox(
    height: 10,
    ),
    Container(
    child: GestureDetector(
    onTap: () => Navigator.of(context).pushNamed(Registration.id),
    child: Text(
    'Don\'t have an account? Sign up.'
    ),
    )
    )
    ],
    ),)
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  const CustomButton({Key key, this.callback, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.blueGrey,
        elevation: 6.0,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: callback,
          minWidth: 200.0,
          height: 45.0,
          child: Text(text),
        ),
      ),
    );
  }
}

class Registration extends StatefulWidget {
  static const String id = "REGISTRATION";
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String email;
  String password;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerUser() async {
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Value Tag"),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  width: 200.0,
                  child: Image.asset("assets/logo.png"),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                  width: 300,
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => email = value,
                    decoration: InputDecoration(
                        hintText: "Enter Your Email",
                        icon: Icon(Icons.email)
                    ),
                  )),
              Container(
                  width: 300,
                  child: TextField(
                    obscureText: true,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => password = value,
                    decoration: InputDecoration(
                        hintText: "Enter Your Password",
                        icon: Icon(Icons.lock_outline)
                    ),
                  )),
              SizedBox(
                height: 20,
              ),
          CustomButton(
            text: "Register",
            callback: () async {
              await registerUser();
            },
          ),
              SizedBox(
                height: 10,
              ),
              Container(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(MyHomePage.id),
                    child: Text(
                        'Already on ValueTag? Sign in.'
                    ),
                  )
              )
        ],
      ),
      ));
  }
}

class Chat extends StatefulWidget {
  static const String id = "CHAT";
  final FirebaseUser user;

  const Chat({Key key, this.user}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Future<void> callback() async {
    if (messageController.text.length > 0) {
      await _firestore.collection('messages').add({
        'text': messageController.text,
        'from': widget.user.email,
      });
      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'logo',
          child: Container(
            height: 40.0,
            child: Image.asset("assets/logo.png"),
          ),
        ),
        title: Text("Value Tag"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  List<Widget> messages = docs
                      .map((doc) => Message(
                    from: doc.data['from'],
                    text: doc.data['text'],
                    me: widget.user.email == doc.data['from'],
                  ))
                      .toList();

                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages,
                    ],
                  );
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) => callback(),
                      decoration: InputDecoration(
                        hintText: "Enter a Message...",
                        border: const OutlineInputBorder(),
                      ),
                      controller: messageController,
                    ),
                  ),
                  SendButton(
                    text: "Send",
                    callback: callback,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.orange,
      onPressed: callback,
      child: Text(text),
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;

  final bool me;

  const Message({Key key, this.from, this.text, this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
        me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            from,
          ),
          Material(
            color: me ? Colors.teal : Colors.red,
            borderRadius: BorderRadius.circular(10.0),
            elevation: 6.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(
                text,
              ),
            ),
          )
        ],
      ),
    );
  }
}