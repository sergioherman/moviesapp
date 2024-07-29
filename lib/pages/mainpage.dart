
// Não deixar os botões do Filtro e o Search Bar sofrer Scroll
// Fazer efeito de gradiente de opacidade quando as imagens ficam atrás dos botões
// Fazer Transição de Telas
// Se o filme nao tiver um poster, nada deve ser exibido na tela (bug ao pesquisar filme "aaa" por exemplo)

// Avaliar responsividade
//    Telas largas nao centralizam as imagens, e deixam o efeito de gradiente maior que a imagem
//    Fazer Wrap nas listas dos Details
//    Classe Wrap em vez de Row nos botões do filtro


// Observações:
// Clicar muitas vezes em um filtro pode retornar resultados repetidos, colocar um tempo de espera para fazer a requisição
// Filtros estão seguindo a lógica "AND", mas poderia ser "OR"

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../classes/arguments.dart';
import 'dart:convert';
import 'dart:async';
import 'details.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  Color textColorBtnAction = const Color(0xFF00384C);
  Color backColorBtnAction =  Colors.white;
  Color borderColorBtnAction = const Color(0xFFF1F3F5);
  Color textColorBtnAdventure = const Color(0xFF00384C);
  Color backColorBtnAdventure =  Colors.white;
  Color borderColorBtnAdventure = const Color(0xFFF1F3F5);
  Color textColorBtnComedy = const Color(0xFF00384C);
  Color backColorBtnComedy =  Colors.white;
  Color borderColorBtnComedy = const Color(0xFFF1F3F5);
  Color textColorBtnFantasia = const Color(0xFF00384C);
  Color backColorBtnFantasia =  Colors.white;
  Color borderColorBtnFantasy = const Color(0xFFF1F3F5);

  final scrollController = ScrollController();

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  dynamic allGenres;

  List<dynamic> displayedMovies = [];
  List<dynamic> moviesToDisplay = [];
  bool searchOnNextPage = true;
  bool hasTimedOut = false;

  bool filterAction = false;
  bool filterAdventure = false;
  bool filterFantasy = false;
  bool filterComedy = false;

  List<String> displayedMovieTitles = [];
  List<String> displayedMovieGenres = [];
  List<String> displayedMoviePosterUrls = [];

  bool hasMore = true;
  int page = 1;
  bool isLoading = false;
  
  int showLoadStatus = 1;

  @override
  void initState(){
    super.initState();
    fetchMovies();
    scrollController.addListener((){
      if (scrollController.position.maxScrollExtent == scrollController.offset && hasTimedOut == false){
        fetchMovies();
      }
    });
  }
  
  @override
  void dispose() {
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future fetchMovies() async {
    setState(() {
      showLoadStatus = 1;
    });
    if (isLoading){
      return;
    }
    isLoading = true;
    const limit = 20;  // Quantidade de items que vem na API

    moviesToDisplay = [];
    searchOnNextPage = true;
    hasTimedOut = false;
    Timer timer = Timer(const Duration(seconds: 5), () {
      hasTimedOut = true;
    });

    bool startedNewWhile = false;
    while (moviesToDisplay.isEmpty && searchOnNextPage && !hasTimedOut){ // Vai ficar procurando até encontrar o filme que satisfaz todos os filtros ao longo das páginas que a API retorna
      // Recuperar populares
      startedNewWhile = true;
      var urlMoviesToDisplay = Uri.parse('https://api.themoviedb.org/3/movie/popular?language=pt-BR&page=$page');
      if (searchController.text != ""){
        String searchWord = searchController.text;
        urlMoviesToDisplay = Uri.parse('https://api.themoviedb.org/3/search/movie?query=$searchWord&include_adult=false&language=pt-BR&page=$page');
      }else{
        urlMoviesToDisplay = Uri.parse('https://api.themoviedb.org/3/movie/popular?language=pt-BR&page=$page');
      }
      const headers = {
        "accept": "application/json",
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ZjgxOTc4NTAyNDM4YjhhZGJiYmMxMThlMDJlNGE3ZCIsIm5iZiI6MTcyMTI0Mzg4Mi44MDY2MTksInN1YiI6IjY2OTMzZjFmZGNiNmJiZGVhZDkwOGY4YSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.WotT6jLBGMs8__7TtVkL1GraAV3Os_8ff7j8fG9QFao"
      };
      final responseMoviesToDisplay = await http.get(urlMoviesToDisplay, headers: headers);

      final urlGenres = Uri.parse('https://api.themoviedb.org/3/genre/movie/list?language=pt-BR');
      final responseGenres = await http.get(urlGenres, headers: headers);


      if (responseMoviesToDisplay.statusCode == 200 && (responseGenres.statusCode == 200)) {
        dynamic newResultsCandidaesToDisplay = json.decode(responseMoviesToDisplay.body);
        moviesToDisplay = newResultsCandidaesToDisplay['results'];

        if (moviesToDisplay.isEmpty){
          searchOnNextPage = false;
        }
        if ((filterAction || filterAdventure || filterComedy || filterFantasy)){
        
          List<int> genreFilters = [];
          if (filterAction) genreFilters.add(28);  // Ação
          if (filterAdventure) genreFilters.add(12);  // Aventura
          if (filterComedy) genreFilters.add(35);  // Comedia
          if (filterFantasy) genreFilters.add(14);  // Fantasia

          moviesToDisplay = moviesToDisplay.where((movie) {
            List<int> genreIds = List<int>.from(movie['genre_ids']);
            // return genreIds.any((id) => genreFilters.contains(id));  // FILTRO COM LOGICA OU
            return genreFilters.every((id) => genreIds.contains(id));  // FILTRO COM LOGICA E
          }).toList();
        }
        displayedMovies.addAll(moviesToDisplay);
        page += 1;
        
        setState(() {
          if (moviesToDisplay.length < limit){
            hasMore = false;
          }
          List<String> newMoviePosters = List<String>.from(
            moviesToDisplay.map((movie) => "https://image.tmdb.org/t/p/w500${movie['poster_path']}")
          );
          List<String> newMovieTitles = List<String>.from(
            moviesToDisplay.map((movie) => "${movie['title']}")
          );
          List<String> newMovieGenres = List<String>.from(
            moviesToDisplay.map((movie) => "${movie['genre_ids']}")
          );

          displayedMovieTitles.addAll(newMovieTitles);
          displayedMoviePosterUrls.addAll(newMoviePosters);

          allGenres = json.decode(responseGenres.body);
          final Map<int, String> genreMap = {};
          for (var genre in allGenres['genres']) {
            genreMap[genre['id']] = genre['name'];
          }
          newMovieGenres = List<String>.from(moviesToDisplay.map((movie) {
            return (movie['genre_ids'] as List).map((id) => genreMap[id]).join(" - ");
          }));
          displayedMovieGenres.addAll(newMovieGenres);

        });
      startedNewWhile = false;

      }
    }
    timer.cancel();
    isLoading = false;

    if (hasTimedOut && !startedNewWhile){
      showLoadStatus = 1;
    }else{
      if (displayedMovies.length < 2){
        showLoadStatus = 1;
      }else{
        showLoadStatus = 0;
      }
    }
    setState(() {});
  }


  Future refresh() async {
    hasMore = true;
    page = 1;
    setState(() {
      isLoading = false;
      displayedMoviePosterUrls.clear();
      displayedMovieTitles.clear();
      displayedMovieGenres.clear();
      searchController.text = "";
    });
    fetchMovies();
  }

  void searchFilm(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      hasMore = true;
      page = 1;
      setState(() {
        displayedMoviePosterUrls.clear();
        displayedMovieTitles.clear();
        displayedMovieGenres.clear();
        displayedMovies.clear();
      });
      fetchMovies();
    });
  }


  void applyActionFilter() {
    if (! isLoading){
      if (filterAction){
        filterAction = false;
        textColorBtnAction = const Color(0xFF00384C);
        backColorBtnAction =  Colors.white;
        borderColorBtnAction = const Color(0xFFF1F3F5);
      } else {
        filterAction = true;
        textColorBtnAction = Colors.white;
        backColorBtnAction = const Color(0xFF00384C);
        borderColorBtnAction = Colors.transparent;
      }
      hasMore = true;
      page = 1;
      setState(() {
        displayedMoviePosterUrls.clear();
        displayedMovieTitles.clear();
        displayedMovieGenres.clear();
        displayedMovies.clear();
      });
      fetchMovies();
      setState(() {
      });
    }
  }

  void applyAdventureFilter(){
    if (!isLoading){
      if (filterAdventure){
        filterAdventure = false;
        textColorBtnAdventure = const Color(0xFF00384C);
        backColorBtnAdventure =  Colors.white;
        borderColorBtnAdventure = const Color(0xFFF1F3F5);
      } else {
        filterAdventure = true;
        textColorBtnAdventure = Colors.white;
        backColorBtnAdventure = const Color(0xFF00384C);
        borderColorBtnAdventure = Colors.transparent;
      }
      hasMore = true;
      page = 1;
      setState(() {
        displayedMoviePosterUrls.clear();
        displayedMovieTitles.clear();
        displayedMovieGenres.clear();
        displayedMovies.clear();
      });
      fetchMovies();
      setState(() {
      });
    }
  }

  void applyFantasyFilter(){
    if (!isLoading){
      if (filterFantasy){
        filterFantasy = false;
        textColorBtnFantasia = const Color(0xFF00384C);
        backColorBtnFantasia =  Colors.white;
        borderColorBtnFantasy = const Color(0xFFF1F3F5);
      } else {
        filterFantasy = true;
        textColorBtnFantasia = Colors.white;
        backColorBtnFantasia = const Color(0xFF00384C);
        borderColorBtnFantasy = Colors.transparent;
      }
      hasMore = true;
      page = 1;
      setState(() {
        displayedMoviePosterUrls.clear();
        displayedMovieTitles.clear();
        displayedMovieGenres.clear();
        displayedMovies.clear();
      });
      fetchMovies();
      setState(() {
      });
    }
  }

  void applyComedyFilter(){
    if (!isLoading){
      if (filterComedy){
        filterComedy = false;
        textColorBtnComedy = const Color(0xFF00384C);
        backColorBtnComedy =  Colors.white;
        borderColorBtnComedy = const Color(0xFFF1F3F5);
      } else {
        filterComedy = true;
        textColorBtnComedy = Colors.white;
        backColorBtnComedy = const Color(0xFF00384C);
        borderColorBtnComedy = Colors.transparent;
      }
      hasMore = true;
      page = 1;
      setState(() {
        displayedMoviePosterUrls.clear();
        displayedMovieTitles.clear();
        displayedMovieGenres.clear();
        displayedMovies.clear();
        moviesToDisplay.clear();
      });
      fetchMovies();
      setState(() {
      });
    }
  }


  Future<dynamic> fetchMovieDetails(String movieId) async {
    String url = "https://api.themoviedb.org/3/movie/$movieId?language=pt-BR";
    const headers = {
      "accept": "application/json",
      "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ZjgxOTc4NTAyNDM4YjhhZGJiYmMxMThlMDJlNGE3ZCIsIm5iZiI6MTcyMTI0Mzg4Mi44MDY2MTksInN1YiI6IjY2OTMzZjFmZGNiNmJiZGVhZDkwOGY4YSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.WotT6jLBGMs8__7TtVkL1GraAV3Os_8ff7j8fG9QFao"
    };
    final response = await http.get(Uri.parse(url),headers: headers);
    dynamic dataDetails;
    if (response.statusCode == 200){
      dataDetails = json.decode(response.body);
    }else{
      // print("Falha: " + response.statusCode.toString());
    }
    return dataDetails;
  }

  Future<dynamic> fetchMovieCredits(String movieId) async {
    String url = "https://api.themoviedb.org/3/movie/$movieId/credits?language=pt-BR";
    const headers = {
      "accept": "application/json",
      "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ZjgxOTc4NTAyNDM4YjhhZGJiYmMxMThlMDJlNGE3ZCIsIm5iZiI6MTcyMTI0Mzg4Mi44MDY2MTksInN1YiI6IjY2OTMzZjFmZGNiNmJiZGVhZDkwOGY4YSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.WotT6jLBGMs8__7TtVkL1GraAV3Os_8ff7j8fG9QFao"
    };
    final response = await http.get(Uri.parse(url),headers: headers);
    dynamic dataCredits;
    if (response.statusCode == 200){
      dataCredits = json.decode(response.body);
    }else{
      // print("Falha: " + response.statusCode.toString());
    }
    return dataCredits;
  }

  void openDetails(index) async {
    var selectedMovie = displayedMovies[index];
    String movieId = selectedMovie['id'].toString();
    var movieDetails = await fetchMovieDetails(movieId);
    var movieCredits = await fetchMovieCredits(movieId);
    await Navigator.pushNamed(
      // ignore: use_build_context_synchronously
      context,
      Details.routeName,
      arguments: Arguments(selectedMovie, movieDetails, movieCredits)
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
      color: Colors.white,
      height: double.infinity,
      child:
      RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child:
                Column(
                  children: [

                    // TÍTULO
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                      alignment: Alignment.centerLeft,
                      child: 
                      const Text(
                        "Filmes",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF343A40),
                        ),
                      ),
                    ),

                    // BUSCA
                    Container(
                      height: 47,
                      decoration: BoxDecoration(
                      color: Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        onChanged: (value){
                          searchFilm(value);
                        },
                        controller: searchController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Pesquise filmes',
                                labelStyle: TextStyle(
                                  color: Color(0xFF5E6770),
                                ),
                          prefixIcon: Icon(
                            Icons.search,
                                  color: Color(0xFF5E6770),
                            ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    // FILTROS
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 23),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          TextButton(
                            onPressed:
                              applyActionFilter,
                            style:
                            TextButton.styleFrom(
                              foregroundColor: textColorBtnAction,
                              backgroundColor: backColorBtnAction,
                              side: BorderSide(width: 1.0, color: borderColorBtnAction),
                            ),
                            child: const Text(
                              "Ação",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          
                          TextButton(
                            onPressed:
                              applyAdventureFilter,
                            style:
                            TextButton.styleFrom(
                              foregroundColor: textColorBtnAdventure,
                              backgroundColor: backColorBtnAdventure,
                              side: BorderSide(width: 1.0, color: borderColorBtnAdventure),
                            ),
                            child: const Text(
                              "Aventura",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed:
                              applyFantasyFilter,
                            style:
                            TextButton.styleFrom(
                              foregroundColor: textColorBtnFantasia,
                              backgroundColor: backColorBtnFantasia,
                              side: BorderSide(width: 1.0, color:borderColorBtnFantasy),
                            ),
                            child: const Text(
                              "Fantasia",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed:
                              applyComedyFilter,
                            style:
                            TextButton.styleFrom(
                              foregroundColor: textColorBtnComedy,
                              backgroundColor: backColorBtnComedy,
                              side: BorderSide(width: 1.0, color: borderColorBtnComedy),
                            ),
                            child: const Text(
                              "Comédia",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],

                )
              ),

              // LISTA DE POSTERES
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: displayedMoviePosterUrls.length + showLoadStatus,
                  itemBuilder: (context, index) {
                    if (index < displayedMoviePosterUrls.length) {
                      final item = displayedMoviePosterUrls[index];
                      return GestureDetector(
                        onTap: () { openDetails(index); },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                // Posteres de Filmes
                                Image.network(item),
                                // Gradiente Escurecer
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 350,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(1),
                                          Colors.black.withOpacity(0.9),
                                          Colors.black.withOpacity(0.6),
                                          Colors.black.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Título do Filme
                                Positioned(
                                  bottom: 70,
                                  left: 24,
                                  right: 24,
                                  child: Text(
                                    displayedMovieTitles[index].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Gêneros dos Filmes
                                Positioned(
                                  bottom: 35,
                                  left: 24,
                                  right: 24,
                                  child: Text(
                                    displayedMovieGenres[index],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: !hasTimedOut
                          ? Column(children: [
                          
                              (page>1 && displayedMovies.isEmpty)?
                              Text(
                                "Buscando filmes na página\u00A0${page-1}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                )  
                              ): const SizedBox(height: 20.0),
                            const SizedBox(height: 20.0), 
                            
                            (isLoading)?
                            const CircularProgressIndicator():
                            const SizedBox(height: 10.0),
                          
                          ],)
                          
                          : Column(                              
                            children: [
                          
                              Text(
                                "Timeout após buscar em\u00A0${page-1}\u00A0página(s).",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                )  
                              ),
                              const SizedBox(height: 25.0),
                              TextButton(
                                onPressed:
                                  fetchMovies,
                                style:
                                TextButton.styleFrom(
                                  foregroundColor: textColorBtnAction,
                                  backgroundColor: backColorBtnAction,
                                  side: BorderSide(width: 1.0, color: borderColorBtnAction),
                                ),
                                child: const Text(
                                  "Continuar buscando",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          
                            ],
                          )

                        ),
                      );
                    }
                  },
                ),
              ),
              
            ],
          ),
        ),
      ),
    )
    );
  }
}