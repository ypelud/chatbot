# chatbot

A sample of using [DialogFlow](https://dialogflow.com/) with flutter. 

## Getting Started

```shell
git clone https://github.com/ypelud/chatbot.git
cd chatbot
flutter packages get
```

* Create a new Google Cloud Project on the [Google Developers Console](https://console.developers.google.com/)
* Enable DialogFlow API [Google Developers Console](https://console.developers.google.com/) (under APIs & Services -> Library)
* Create a service account key (under APIs & Services -> Credentials -> Create credentials -> Service account key) 
* Copy/rename the json file to config/dialogflow.json

```shell
flutter run
```