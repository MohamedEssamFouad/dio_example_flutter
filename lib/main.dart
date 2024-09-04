import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dio Example'),
        ),
        body: Center(
          child: DioExample(),
        ),
      ),
    );
  }
}

class DioExample extends StatefulWidget {
  @override
  _DioExampleState createState() => _DioExampleState();
}

class _DioExampleState extends State<DioExample> {
  final Dio _dio = Dio();
  List<dynamic> _posts = [];
  CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  void _setupDio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Request made: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response received: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Error occurred: ${e.message}');
        return handler.next(e);
      },
    ));

    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/posts',
        cancelToken: _cancelToken,
      );
      setState(() {
        _posts = response.data;
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        print('Request cancelled');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        print('Connection timeout');
      } else {
        print('Error fetching posts: ${e.message}');
      }
    }
  }

  Future<void> _createPost() async {
    try {
      final response = await _dio.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: {'title': 'New Post', 'body': 'This is a new post.', 'userId': 1},
      );
      print('New post created: ${response.data}');
    } on DioException catch (e) {
      print('Error creating post: ${e.message}');
    }
  }

  void _cancelRequest() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('Cancelled by user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _fetchPosts,
          child: Text('Fetch Posts'),
        ),
        ElevatedButton(
          onPressed: _createPost,
          child: Text('Create Post'),
        ),
        ElevatedButton(
          onPressed: _cancelRequest,
          child: Text('Cancel Request'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return ListTile(
                title: Text(post['title']),
                subtitle: Text(post['body']),
              );
            },
          ),
        ),
      ],
    );
  }
}
