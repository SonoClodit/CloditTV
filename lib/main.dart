import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const CloditTvApp());

class CloditTvApp extends StatelessWidget {
  const CloditTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF31E981);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CloditTV',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
          surface: const Color(0xFF111418),
        ),
        scaffoldBackgroundColor: const Color(0xFF090B0E),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.year,
    this.posterPath,
    this.rating = 0,
  });

  final int id;
  final String title;
  final String overview;
  final String year;
  final String? posterPath;
  final double rating;

  String? get posterUrl => posterPath == null
      ? null
      : 'https://image.tmdb.org/t/p/w500$posterPath';

  factory Movie.fromTmdb(Map<String, dynamic> json) {
    final date = (json['release_date'] as String?) ?? '';
    return Movie(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? 'Senza titolo',
      overview: (json['overview'] as String?) ?? '',
      year: date.length >= 4 ? date.substring(0, 4) : '—',
      posterPath: json['poster_path'] as String?,
      rating: ((json['vote_average'] as num?) ?? 0).toDouble(),
    );
  }
}

abstract class CatalogProvider {
  Future<List<Movie>> popular();
  Future<List<Movie>> search(String query);
}

class TmdbProvider implements CatalogProvider {
  TmdbProvider(this.apiKey);

  final String apiKey;
  static const _base = 'https://api.themoviedb.org/3';

  Future<List<Movie>> _get(String path, [Map<String, String>? extra]) async {
    final uri = Uri.parse('$_base$path').replace(queryParameters: {
      'api_key': apiKey,
      'language': 'it-IT',
      ...?extra,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('TMDB ha risposto ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['results'] as List<dynamic>)
        .map((item) => Movie.fromTmdb(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Movie>> popular() => _get('/movie/popular');

  @override
  Future<List<Movie>> search(String query) =>
      _get('/search/movie', {'query': query, 'include_adult': 'false'});
}

class DemoProvider implements CatalogProvider {
  static const movies = <Movie>[
    Movie(
      id: 101,
      title: 'Oltre le stelle',
      year: '2026',
      rating: 8.2,
      overview: 'Un viaggio nello spazio diventa una ricerca personale.',
    ),
    Movie(
      id: 102,
      title: 'Luce di mezzanotte',
      year: '2025',
      rating: 7.6,
      overview: 'Un mistero attraversa una città che non dorme mai.',
    ),
    Movie(
      id: 103,
      title: 'Il giorno perfetto',
      year: '2024',
      rating: 7.9,
      overview: 'Una commedia sul valore delle piccole coincidenze.',
    ),
    Movie(
      id: 104,
      title: 'Linea d’ombra',
      year: '2026',
      rating: 8.0,
      overview: 'Un thriller teso tra memoria, segreti e identità.',
    ),
  ];

  @override
  Future<List<Movie>> popular() async => movies;

  @override
  Future<List<Movie>> search(String query) async {
    final normalized = query.toLowerCase();
    return movies
        .where((movie) => movie.title.toLowerCase().contains(normalized))
        .toList();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const apiKey = String.fromEnvironment('TMDB_API_KEY');
  late final CatalogProvider provider =
      apiKey.isEmpty ? DemoProvider() : TmdbProvider(apiKey);
  final searchController = TextEditingController();
  Set<int> favorites = {};
  List<Movie> movies = const [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    favorites = (prefs.getStringList('favorites') ?? const [])
        .map(int.parse)
        .toSet();
    await _refresh();
  }

  Future<void> _refresh([String query = '']) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = query.trim().isEmpty
          ? await provider.popular()
          : await provider.search(query.trim());
      if (mounted) setState(() => movies = result);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _toggleFavorite(int id) async {
    setState(() => favorites.contains(id)
        ? favorites.remove(id)
        : favorites.add(id));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites',
      favorites.map((id) => '$id').toList(),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CloditTV',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1),
        ),
        actions: [
          if (apiKey.isEmpty)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Chip(label: Text('DEMO')),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(searchController.text),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _refresh,
                  decoration: InputDecoration(
                    hintText: 'Cerca un film',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        searchController.clear();
                        _refresh();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Film popolari',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            if (loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error!, textAlign: TextAlign.center),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: .58,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(
                      movie: movie,
                      favorite: favorites.contains(movie.id),
                      onFavorite: () => _toggleFavorite(movie.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  const MovieCard({
    required this.movie,
    required this.favorite,
    required this.onFavorite,
    super.key,
  });

  final Movie movie;
  final bool favorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => DetailsScreen(movie: movie),
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: movie.posterUrl == null
                      ? Container(
                          color: const Color(0xFF1A2027),
                          child: const Icon(Icons.movie_outlined, size: 54),
                        )
                      : Image.network(
                          movie.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Color(0xFF1A2027),
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    onPressed: onFavorite,
                    icon: Icon(favorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text('${movie.year}  •  ★ ${movie.rating.toStringAsFixed(1)}'),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({required this.movie, super.key});

  final Movie movie;

  Future<void> _openTrailer() async {
    final query = Uri.encodeComponent('${movie.title} trailer italiano');
    await launchUrl(
      Uri.parse('https://www.youtube.com/results?search_query=$query'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (movie.posterUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(movie.posterUrl!, width: 280),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            movie.title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text('${movie.year}  •  ★ ${movie.rating.toStringAsFixed(1)}'),
          const SizedBox(height: 20),
          Text(
            movie.overview.isEmpty
                ? 'Descrizione non disponibile.'
                : movie.overview,
            style: const TextStyle(fontSize: 17, height: 1.5),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openTrailer,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Cerca il trailer'),
          ),
        ],
      ),
    );
  }
}
