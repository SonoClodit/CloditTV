import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final themeController = ThemeController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.load();
  runApp(const CloditTvApp());
}

enum CloditTheme { neon, violet, christmas, spring, summer }

class ThemeProfile {
  const ThemeProfile({
    required this.name,
    required this.accent,
    required this.secondary,
  });

  final String name;
  final Color accent;
  final Color secondary;
}

const themeProfiles = <CloditTheme, ThemeProfile>{
  CloditTheme.neon: ThemeProfile(
    name: 'Neon',
    accent: Color(0xFF31E981),
    secondary: Color(0xFF00B86B),
  ),
  CloditTheme.violet: ThemeProfile(
    name: 'Violet',
    accent: Color(0xFFB36CFF),
    secondary: Color(0xFF6C4DFF),
  ),
  CloditTheme.christmas: ThemeProfile(
    name: 'Natale',
    accent: Color(0xFFFF405C),
    secondary: Color(0xFF16C784),
  ),
  CloditTheme.spring: ThemeProfile(
    name: 'Primavera',
    accent: Color(0xFFFF6FB5),
    secondary: Color(0xFF7FE8A7),
  ),
  CloditTheme.summer: ThemeProfile(
    name: 'Estate',
    accent: Color(0xFFFFB627),
    secondary: Color(0xFF00C8FF),
  ),
};

class ThemeController extends ChangeNotifier {
  CloditTheme selected = CloditTheme.neon;

  ThemeProfile get profile => themeProfiles[selected]!;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('clodit_theme');
    selected = CloditTheme.values.firstWhere(
      (theme) => theme.name == value,
      orElse: () => CloditTheme.neon,
    );
  }

  Future<void> select(CloditTheme theme) async {
    selected = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clodit_theme', theme.name);
  }
}

class CloditTvApp extends StatelessWidget {
  const CloditTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final profile = themeController.profile;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CloditTV',
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: profile.accent,
              primary: profile.accent,
              secondary: profile.secondary,
              brightness: Brightness.dark,
              surface: const Color(0xFF111418),
            ),
            scaffoldBackgroundColor: const Color(0xFF07090C),
            cardTheme: const CardThemeData(
              color: Color(0xFF11151B),
              elevation: 0,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
                TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
              },
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class CloditLogo extends StatelessWidget {
  const CloditLogo({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(compact ? 34 : 42, compact ? 30 : 36),
          painter: _CloditMarkPainter(accent),
        ),
        if (!compact) ...[
          const SizedBox(width: 8),
          const Text(
            'Clodit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          Text(
            'TV',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: accent,
            ),
          ),
        ],
      ],
    );
  }
}

class CloditHomeBrand extends StatelessWidget {
  const CloditHomeBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: .2),
                blurRadius: 18,
                spreadRadius: -3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              'assets/images/clodittv_app_icon.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Clodit',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
          ),
        ),
        Text(
          'TV',
          style: TextStyle(
            color: accent,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
          ),
        ),
      ],
    );
  }
}

class _CloditMarkPainter extends CustomPainter {
  const _CloditMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = color.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .16, size.height * .16, size.width * .72,
          size.height * .68),
      Radius.circular(size.height * .16),
    );
    canvas.drawRRect(rect, glow);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.height, size.height),
      .65,
      5.0,
      false,
      line,
    );
    canvas.drawRRect(rect, line);
    final play = Path()
      ..moveTo(size.width * .48, size.height * .37)
      ..lineTo(size.width * .68, size.height * .5)
      ..lineTo(size.width * .48, size.height * .63)
      ..close();
    canvas.drawPath(play, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CloditMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> opacity;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    scale = CurvedAnimation(
      parent: controller,
      curve: const Interval(0, .72, curve: Curves.easeOutBack),
    );
    opacity = CurvedAnimation(
      parent: controller,
      curve: const Interval(0, .5, curve: Curves.easeOut),
    );
    controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (_, animation, __) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.08),
                radius: .72,
                colors: [
                  colors.primary.withValues(alpha: .17),
                  const Color(0xFF07090C),
                  Colors.black,
                ],
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: opacity,
              child: ScaleTransition(
                scale: scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 118,
                      height: 118,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: .3),
                            blurRadius: 48,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const CloditLogo(compact: true),
                    ),
                    const SizedBox(height: 22),
                    const CloditLogo(),
                    const SizedBox(height: 12),
                    Text(
                      'IL CINEMA, A MODO TUO',
                      style: TextStyle(
                        color: colors.primary.withValues(alpha: .82),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
        title: const CloditHomeBrand(),
        backgroundColor: Colors.transparent,
        actions: [
          if (apiKey.isEmpty)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Chip(label: Text('DEMO')),
            ),
          IconButton(
            tooltip: 'Impostazioni',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(searchController.text),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HeroBanner(
                movie: movies.isEmpty ? null : movies.first,
                loading: loading,
              ),
            ),
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 16 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: InkWell(
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
      ),
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({required this.movie, required this.loading, super.key});

  final Movie? movie;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      height: 210,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: .32),
            colors.secondary.withValues(alpha: .14),
            const Color(0xFF11151B),
          ],
        ),
        border: Border.all(color: colors.primary.withValues(alpha: .28)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .12),
            blurRadius: 32,
            spreadRadius: -8,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                key: ValueKey(movie?.id),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    movie == null ? 'Il cinema, a modo tuo.' : 'IN EVIDENZA',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie?.title ?? 'CloditTV',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie?.overview ??
                        'Scopri, salva e organizza i film che ami.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}

class ThemePicker extends StatefulWidget {
  const ThemePicker({super.key});

  @override
  State<ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  late CloditTheme selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = themeController.selected;
  }

  Future<void> _selectTheme(CloditTheme theme) async {
    if (selectedTheme == theme) return;
    setState(() => selectedTheme = theme);
    await themeController.select(theme);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Palette',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text('Scegli l’atmosfera di CloditTV.'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: CloditTheme.values.map((theme) {
              final profile = themeProfiles[theme]!;
              final active = selectedTheme == theme;
              return ChoiceChip(
                key: ValueKey('${theme.name}-$active'),
                selected: active,
                onSelected: (_) => _selectTheme(theme),
                avatar: CircleAvatar(
                  backgroundColor: profile.accent,
                  radius: 8,
                ),
                label: Text(profile.name),
              );
            }).toList(),
          ),
        ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Impostazioni',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF11151B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.primary.withValues(alpha: .22),
              ),
            ),
            child: const ThemePicker(),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF11151B),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.animation_rounded),
                  title: Text('Animazioni fluide'),
                  subtitle: Text('Attive'),
                  trailing: Icon(Icons.check_circle_rounded),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: Colors.white.withValues(alpha: .08),
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('CloditTV'),
                  subtitle: Text('Versione 0.1.0'),
                ),
              ],
            ),
          ),
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
