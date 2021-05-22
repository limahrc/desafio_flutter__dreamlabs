import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

/*
 * Classe de dados dos Posts
 */
class Post {
  final int id;
  final String title, body;

  Post({
    required this.id,
    required this.title,
    required this.body
  });

  // método para mapeamento dos dados obtidos via JSON para objeto Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: json['title'],
        body: json['body']
    );
  }
}

/*
 * Método que realiza a requisição externa e tratamento dos dados obtidos
 * @return posts: lista de objetos Post convertidos do JSON
 */
Future<List<Post>> fetchPosts() async {
  final data = await http.get(Uri.http("jsonplaceholder.typicode.com", "posts"));
  if (data.statusCode == 200) {

    var jsonData = jsonDecode(data.body);
    List<Post> posts = [];
    for (var i in jsonData) {
      posts.add(Post.fromJson(i));
    }
    log("Qtd posts obtidos: ${posts.length}");
    return posts;
  } else throw Exception("Falha ao obter posts.");
}

/*
 * funções para tratamento de string
 */
extension CapExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${this.substring(1)}';
  String get capitalizeFirstofEach => this.split(" ").map((str) => str.capitalize).join(" ");
}

void main() => runApp(PostListPage());

class PostListPage extends StatefulWidget {
  PostListPage({Key? key}) : super(key: key);
  @override
  PostListPageState createState() => PostListPageState();
}

/*
 * Primeira tela: lista de posts
 */
class PostListPageState extends State<PostListPage> {
  late Future<List<Post>> futurePost;

  @override
  void initState() {
    super.initState();
    futurePost = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Posts',
      theme: ThemeData(
          primarySwatch: Colors.deepOrange
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Posts'),
        ),
        body: Container(
          child: FutureBuilder<List<Post>>(
            future: futurePost,
            builder: (context, snapshot) {
              if (snapshot.hasData) return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      splashColor: Colors.purple.withAlpha(30),
                      onTap: () {
                        log("Card #${snapshot.data![index].id} pressionado");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostBodyPage(),
                        settings: RouteSettings(
                        arguments: snapshot.data![index],
                        ),
                        ),
                        );
                      },
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                         ListTile(
                           leading: CircleAvatar(
                             child: Text(snapshot.data![index].title[0].toString().toUpperCase()),
                             backgroundColor: Colors.white,
                             foregroundColor: Colors.deepOrange,
                           ),
                          title: Text(
                            snapshot.data![index].title.toString().capitalizeFirstofEach,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(snapshot.data![index].body),
                        ),
                      ],
                      ),
                    ),
                  );
                },
              );
              else if (snapshot.hasError) return Text("${snapshot.error}");
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/*
 * Segunda tela: detalhes do post
 */
class PostBodyPage extends StatelessWidget {

  PostBodyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final post = ModalRoute.of(context)!.settings.arguments as Post;

    return Scaffold(
      appBar: AppBar(
        title: Text('Post #${post.id}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListTile(
          title: Text(post.title.capitalizeFirstofEach,
            style: TextStyle(
            fontWeight: FontWeight.bold
          ),
          ),
          subtitle: Text(post.body),
        ),
      ),
    );
  }

}

