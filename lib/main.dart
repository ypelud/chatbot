import 'package:flutter/material.dart';
import 'package:googleapis/dialogflow/v2.dart';
import 'package:googleapis_auth/auth_io.dart';



void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: new ChatMessages(),
    );
  }
}

class ChatMessages extends StatefulWidget {
  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages>
    with TickerProviderStateMixin {
  List<ChatMessage> _messages = List<ChatMessage>();
  bool _isComposing = false;

  TextEditingController _controllerText = new TextEditingController();

  DialogflowApi _dialog;

  @override
  void initState() {
    super.initState();
    _initChatbot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text("ChatBot GDG")),
        body: Column(
          children: <Widget>[
            _buildList(),
            Divider(height: 8.0, color: Theme.of(context).accentColor),
            _buildComposer()
          ],
        ));
  }

  _buildList() {
    return Flexible(
      child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          reverse: true,
          itemCount: _messages.length,
          itemBuilder: (_, index) {
            return Container(child: ChatMessageListItem(_messages[index]));
          }),
    );
  }

  _buildComposer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _controllerText,
              onChanged: (value) {
                setState(() {
                  _isComposing = _controllerText.text.length > 0;
                });
              },
              onSubmitted: _handleSubmit,
              decoration: InputDecoration.collapsed(hintText: "Parle moi"),
            ),
          ),
          new IconButton(
            icon: Icon(Icons.send),
            onPressed:
            _isComposing ? () => _handleSubmit(_controllerText.text) : null,
          ),
        ],
      ),
    );
  }

  _handleSubmit(String value) {
    _controllerText.clear();
    _addMessage(
      text: value,
      name: "John Doe",
      initials: "DJ",
    );

    _requestChatBot(value);
  }

  _requestChatBot(String text) async {
    var dialogSessionId = "projects/chatbot-gdg/agent/sessions/ChatbotGDG";

    Map data = {
      "queryInput": {
        "text": {
          "text": text,
          "languageCode": "fr",
        }
      }
    };

    var request = GoogleCloudDialogflowV2DetectIntentRequest.fromJson(data);

    var resp = await _dialog.projects.agent.sessions
        .detectIntent(request, dialogSessionId);
    var result = resp.queryResult;
    _addMessage(
        name: "Chat Bot",
        initials: "CB",
        bot: true,
        text: result.fulfillmentText);
  }

  void _initChatbot() async {
    var credentials = new ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "chatbot-gdg",
      "private_key_id": "84a336b721f416a95bbc0259d709586ac2dde9ee",
      "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDh2nsQShXmvH/y\nds36jRj83vnnN860VLeXrxBc/bUsjzTL89noG7OOj2TX6NZKZsP8FhWgY5VbHqOb\n6T7vQBitop/6et7ty6Vz0NKjmHEM+Zoja6nO1A+vGbybLnvd/euJWdGKjaK7ydoa\ntAeteY1TcnJM9HGTwt842kIxd4H9VfYOIFV2AL4QPEbdLtc6y+cHpbTfX2TF1H/a\ng7G6Ew+NSB/t4xkjFyL3WJ+GjQ+MgdYwCg25Vj2PkGSjVUOVb8uJGuShARJzVaGN\npVT2R35IQ85ppMEpavO9yc0Mfq9HYToX8J6bPm8EcZmhupwRImk/ZWUJslIT/mT+\nfrwUHY21AgMBAAECggEABTmF9tHP7ZVhDZO1PEm57qPsBIKah5z1yf/RJQMaaZxS\ne1lcZVn1eGiQpEM+QTVJYzcgfvL4pcWEhlOniNMKYZHq1Lvc7b7gXET7anWUP+1I\nahcLbyBJMw8Vlt/ifOi5sj19JHN4peF36BtPwTvTAOb0LX4th61Onqc5mshsbLSF\n8AdSi16C+g4XJ2mDpDYHvV0MgDZXsWxgeRhyC8DE0BR4KhrXw4XIuQ7uOgqViGao\np4nvTV4sy5XhY+ie8xtZbLS2sDEb5sMTJrbEPbwOC24lNN+JpwX/KSFderGauYWC\nLKijbuRkdFp6DaJDNeJOT6PD+TQa0XBAMQuPysEA7QKBgQD0W3IpuIcrhBHKJNt8\nxKFCZCNQdUJetXFugMsfoOX8CIqNiqlDis8Oh0YsFQGtvVE2rV6ggnVXDMC7mh8M\nZKPcCKC0pkCxwkRlcHlNgbjkn1oqLG5dcZhGTvdwn35RbGShaj60BLLKygiWwkLL\nipehxuBVrWVeVekNCPzKYt2MzwKBgQDsnVWhz2c5vK51gRMTJX7VRJh1HPw3bDhn\nSKd6spgnIabdYUa92q4AgBTA+sQf+9BQN97WgQRb2uEbzafGudhNYIBDwHBtfp9C\nEpY8FHq9BlzCZXuINppQKdoxwo8LgotU8EuPgrb6rIEM1G0PWsKMBDC/tE0AG3MY\ne9r8MvrGOwKBgEtlD8N5sRMnK8oAN0y26r6uYQsJMxI/z6D10jaPEYcDJ6TmfLVf\nVeW4rVkanir6N92z/ndt6UCTqb/4nM3ZG4nfi55RkbKHK01VN8hHV0ILPOm4TdE9\nJGvFH6m7PGFpHV+EhZZLwNK7JY1GoQ9mUsTStRMabiV+QmsIM99KQ+uXAoGBAM4q\nHKXbgDbXhy8NIyCoqAWNOkW41q431kFwFbWcDWTzNmBoVOoxszDuaKbpGKBBmfV7\naOeADNs4MLI4E/rcjXKGJdxivdM54+v/I/X/Zh5zf7lGEUfTQ8ubW+nFezvtKBf/\nM+c8XtC2I8+Y+9nIHAFB2XP/1qPERxnLOThL9yNnAoGAPXoUMWONsAQNenzX5hg/\nAp7W39io9vpqgGJQYbchbQdPNSuSB/PUU8BvizGaka2H5xm99KjzbCQYI+aC/lOs\nx0wgC6ul2ammNYCiHlIaZ3AunWGxiMCRYkgwFh+xg1tKv3coghylSG3K/XdG43Jq\n0kkYkkf5i+pVPLTmV/q3FnQ=\n-----END PRIVATE KEY-----\n",
      "client_email": "chatbot@chatbot-gdg.iam.gserviceaccount.com",
      "client_id": "100491250244467129562",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://accounts.google.com/o/oauth2/token",
      "auth_provider_x509_cert_url":
      "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/chatbot%40chatbot-gdg.iam.gserviceaccount.com"
    });

    const _SCOPES = const [DialogflowApi.CloudPlatformScope];

    var httpClient = await clientViaServiceAccount(credentials, _SCOPES);
    _dialog = new DialogflowApi(httpClient);
  }

  void _addMessage(
      {String name, String initials, bool bot = false, String text}) {
    var animationController = AnimationController(
      duration: new Duration(milliseconds: 700),
      vsync: this,
    );

    var message = ChatMessage(
        name: name,
        text: text,
        initials: initials,
        bot: bot,
        animationController: animationController);

    setState(() {
      _messages.insert(0, message);
    });

    animationController.forward();
  }
}

class ChatMessage {
  final String name;
  final String initials;
  final String text;
  final bool bot;

  AnimationController animationController;

  ChatMessage(
      {this.name,
        this.initials,
        this.text,
        this.bot = false,
        this.animationController});
}

class ChatMessageListItem extends StatelessWidget {
  final ChatMessage chatMessage;

  ChatMessageListItem(this.chatMessage);

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
          parent: chatMessage.animationController, curve: Curves.easeOut),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                child: Text(chatMessage.initials ?? "JD"),
                backgroundColor: chatMessage.bot
                    ? Theme.of(context).accentColor
                    : Theme.of(context).highlightColor,
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 16.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(chatMessage.name ?? "Jane Doe",
                        style: Theme.of(context).textTheme.subhead),
                    Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: Text(chatMessage.text)
                    )
                  ],
                ))
            )
          ],
        ),
      ),
    );
  }
}
