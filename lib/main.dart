import 'package:flutter/material.dart';
import 'package:flutter_tmbd/api/endpoints.dart';
import 'package:flutter_tmbd/modal_class/function.dart';
import 'package:flutter_tmbd/modal_class/genres.dart';
import 'package:flutter_tmbd/modal_class/movie.dart';
import 'package:flutter_tmbd/screens/movie_detail.dart';
import 'package:flutter_tmbd/screens/search_view.dart';
import 'package:flutter_tmbd/screens/settings.dart';
import 'package:flutter_tmbd/screens/widgets.dart';
import 'package:flutter_tmbd/theme/theme_state.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeState>(
      create: (_) => ThemeState(),
      child: MaterialApp(
        title: 'Matinee',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue, canvasColor: Colors.transparent),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Genres> _genres = [];
  @override
  void initState() {
    super.initState();
    fetchGenres().then((value) {
      _genres = value.genres ?? [];
    });

  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ThemeState>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: state.themeData.colorScheme.secondary,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        centerTitle: true,
        title: Text(
          'Matinee',
          style: state.themeData.textTheme.headlineSmall,
        ),
        backgroundColor: state.themeData.primaryColor,
        actions: <Widget>[
          IconButton(
            color: state.themeData.colorScheme.secondary,
            icon: Icon(Icons.search),
            onPressed: () async {
              final Movie? result = await showSearch<Movie?>(
                  context: context,
                  delegate:
                      MovieSearch(themeData: state.themeData, genres: _genres));
              if (result != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MovieDetailPage(
                            movie: result,
                            themeData: state.themeData,
                            genres: _genres,
                            heroId: '${result.id}Buscar')));
              }
            },
          )
        ],
      ),
      drawer: Drawer(
        child: SettingsPage(),
      ),
      body: Container(
        color: state.themeData.primaryColor,
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            DiscoverMovies(
              themeData: state.themeData,
              genres: _genres,
            ),
            ScrollingMovies(
              themeData: state.themeData,
              title: 'Top Peliculas',
              api: Endpoints.topRatedUrl(1),
              genres: _genres,
            ),
            ScrollingMovies(
              themeData: state.themeData,
              title: 'En Cartelera',
              api: Endpoints.nowPlayingMoviesUrl(1),
              genres: _genres,
            ),
            ScrollingMovies(
               themeData: state.themeData,
               title: 'Próximos Estrenos ',
               api: Endpoints.upcomingMoviesUrl(1),
               genres: _genres,
            ),
            ScrollingMovies(
              themeData: state.themeData,
              title: 'Populares',
              api: Endpoints.popularMoviesUrl(1),
              genres: _genres,
            ),
          ],
        ),
      ),
    );
  }
}
