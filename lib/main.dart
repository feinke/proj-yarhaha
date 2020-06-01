import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:transparent_image/transparent_image.dart';

void main() => runApp(MyApp());

Future<List<AmiiboPost>> fetchAmiibo() async {
  final String getAllUrl = 'https://www.amiiboapi.com/api/amiibo/';
  Response res = await get(getAllUrl);

  if(res.statusCode == 200) {
    Map<String, dynamic> jsonMap = jsonDecode(res.body);
    List<dynamic> body = jsonMap['amiibo'];

    List<AmiiboPost> posts = body.map((item) => AmiiboPost.fromJson(item)).toList();
    return posts;
  }
  else {
    throw "http get failed";
  }
}

class AmiiboPost {
  final String id;
  final String name;
  final String image;

  AmiiboPost({this.id, this.name, this.image});

  factory AmiiboPost.fromJson(Map<String, dynamic> json) {
    return AmiiboPost(
      id: json['head'] + json['tail'],
      name: json['name'],
      image: json['image'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        primaryColor: Colors.lime,
        ),
      home: Amiibo()
    );
  }
}

class AmiiboState extends State<Amiibo> {
  Future<List<AmiiboPost>> _futureAmiiboList;
  final Set<AmiiboPost> _favs = Set<AmiiboPost>();

  @override
  void initState() {
    super.initState();
    _futureAmiiboList = fetchAmiibo();
  }

  Widget build(BuildContext buildContext) {

    Widget _buildRow(String index, AmiiboPost amiibo) {
      final bool alreadyFav = _favs.contains(amiibo);
      return ListTile(
        leading: Text(index),
        title: Text(amiibo.name),
        subtitle: Text(amiibo.id),
        trailing: IconButton(
          icon: alreadyFav ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          color: alreadyFav ? Colors.red : null,
          onPressed: () {
            setState(() {
              if(alreadyFav) {
                _favs.remove(amiibo);
              }
              else {
                _favs.add(amiibo);
              }
            });
          },
        ),
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (buildContext) => AmiiboDetail(amiiboPost: amiibo))
          );
        },
      );
    }

    Widget _buildAmiiboList(List<AmiiboPost> posts) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: posts.length,
        itemBuilder: (context, i) {
          if(i.isOdd) return Divider();
          final index = i ~/ 2;
          return _buildRow(index.toString(), posts[i]);
        }
      );
    }


    FutureBuilder _futureBuildAmiiboList() {
      return FutureBuilder(
        future: _futureAmiiboList,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            List<AmiiboPost> posts = snapshot.data;
            return _buildAmiiboList(posts);
          }
          else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    }

    void _pushFaved() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            final Iterable<ListTile> tiles = _favs.map(
              (AmiiboPost amiibo) {
                return ListTile(
                  title: Text(amiibo.name),
                );
              }
            );

            final List<Widget> divided = ListTile.divideTiles(tiles: tiles, context: context).toList();

            return Scaffold(
              appBar: AppBar(title: Text('Fav List')),
              body: ListView(children: divided),
            );
          } 
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('amiibo list'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushFaved,)
        ],
      ),
      body: _futureBuildAmiiboList(),
    );
  }
}

class Amiibo extends StatefulWidget {
  @override
  AmiiboState createState() => AmiiboState();
}

class AmiiboDetail extends StatelessWidget {
  final AmiiboPost amiiboPost;

  AmiiboDetail({Key key, @required this.amiiboPost}) : super(key: key);

  Stack imagePlaceholder(String image) {
    return Stack(
      children: <Widget>[
        Center(child: CircularProgressIndicator()),
        Center(child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: image))
      ],
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(title: Text(amiiboPost.name)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: imagePlaceholder(amiiboPost.image),
      )
    );
  }
}