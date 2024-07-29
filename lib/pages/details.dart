// Classe Wrap nos botões em vez de Row
// Fazer efeito de transição da tela home para a tela de detalhes conforme o protótipo do figma

import 'package:flutter/material.dart';
import '../classes/arguments.dart';

class Details extends StatefulWidget {
  const Details({super.key});
  static String routeName = "/details";

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  String formatNumberWithDots(int number) {
    String numberString = number.toString();
    StringBuffer formattedNumber = StringBuffer();
    int counter = 0;
    for (int i = numberString.length - 1; i >= 0; i--) {
      formattedNumber.write(numberString[i]);
      counter++;
      if (counter % 3 == 0 && i != 0) {
        formattedNumber.write('.');
      }
    }
    return formattedNumber.toString().split('').reversed.join('');
  }

  void goBack(){
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {

    var args = ModalRoute.of(context)!.settings.arguments as Arguments;

    String imgUrl = "https://image.tmdb.org/t/p/w500${args.details['poster_path']}";
    String movieName = args.details['title'];
    String movieYear = args.details['release_date'].toString().substring(0, 4);;
    String formattedDuration = '${args.details['runtime'] ~/ 60}h ${args.details['runtime'] % 60}m';
    String movieDescription = args.details['overview'];
    String movieBudget = formatNumberWithDots(args.details['budget']);

    List<String> genresList = (args.details['genres'] as List)
      .map((genre) => genre['name'] as String)
      .toList();

    List<String> productoinCompaniesList = (args.details['production_companies'] as List)
      .map((company) => company['name'] as String)
      .toList();
    String productionCompaniesString = productoinCompaniesList.join(', ');

    List<String> directorsList = (args.credits['crew'] as List)
      .where((member) => member['job'] == 'Director')
      .map((director) => director['name'] as String)
      .toList();
    String directorsString = directorsList.join(', ');

    List<String> mainActorsList = (args.credits['cast'] as List)
        .where((member) => member['order'] < 5)
        .map((actor) => actor['name'] as String)
        .toList();
    String mainActorsString = mainActorsList.join(', ');


    return Scaffold(
      body: 
      SingleChildScrollView(

        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 50.0),
          decoration: const BoxDecoration(
            color: Colors.white
          ),

          child: Column(
            children: [

              // BOTÃO VOLTAR
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                child:
                TextButton(
                  onPressed: goBack,
                  style:
                  TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00384C),
                    backgroundColor:  Colors.white,
                    side: const BorderSide(width: 1.0, color: Color(0xFFF1F3F5)),
                  ),
                  child: const Text(
                    "Voltar",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                    ),
                  )
                ),
              ),


              // IMAGEM
              Container(
                margin: const EdgeInsets.fromLTRB(52, 16, 52, 0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),


              // NOTA
              Container(
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      args.movie['vote_average'].toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        color: Color(0xFF00384C),
                      ),
                    ),
                    const Text(
                      " /10",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF868E96),
                        height: 2, // Ajusta a altura da linha para alinhar
                      ),
                    ),
                  ],
                ),
              ),


              // TÍTULO
              Container(
                margin: const EdgeInsets.fromLTRB(0, 15, 0, 4),
                child: Text(
                  movieName.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Color(0xFF343A40)
                  ),
                ),
              ),


              // TÍTULO ORIGINAL
              Container(
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Título Original: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        color: Color(0xFF6D7070)
                      ),
                    ),
                    Text(
                      args.movie['original_title'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        color: Color(0xFF5E6770),
                      ),
                    ),
                  ],
                )
              ),


              // ANO E DURAÇÃO
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Ano: ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Color(0xFF868E96)
                            ),
                          ),
                          Text(
                            movieYear,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Color(0xFF343A40)
                            ),
                          ),
                        ],
                      )
                    ),

                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Duração: ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Color(0xFF868E96)
                            ),
                          ),
                          Text(
                            formattedDuration,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Color(0xFF343A40)
                            ),
                          ),
                        ],
                      )
                    ),

                  ],
                ),
              ),


              // GENEROS
              Container(
                margin: const EdgeInsets.fromLTRB(0, 7, 0, 30),
                child:  Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children:
                    List.generate(
                      genresList.length,
                      (index) =>


                          Container(
                            margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFFE9ECEF),
                                width: 1,
                              )
                            ),
                            child: Text(
                              genresList[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color(0xFF5E6770)
                              ),
                            )
                          

                      )
                    ),
                ),
              ),


              // DESCRIÇÃO
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Descrição",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF5E6770)
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movieDescription,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF343A40)
                      ),
                    ),
                  ],
                ),
              ),


              // ORÇAMENTO
              Container(
                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Text(
                      "ORÇAMENTO: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF868E96)
                      ),
                    ),
                    Text(
                      movieBudget,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF343A40)
                      ),
                    ),
                  ],
                )
              ),

              const SizedBox(height: 6),


              // PRODUTORAS
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    const Text(
                      "Produtoras: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF868E96),
                      ),
                    ),
                    Text(
                      productionCompaniesString,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF343A40),
                      ),
                      softWrap: true, // Permite a quebra de linha
                    ),
                  ],
                ),
              ),


              // DIRETORES
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Diretor",
                      // textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF5E6770)
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      directorsString,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF343A40)
                      ),
                    ),
                  ],
                ),
              ),


              // ELENCO
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Elenco",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF5E6770)
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mainActorsString,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF343A40)
                      ),
                    ),
                  ],
                ),
              ),

            ],
          )

        )

      )
    );
  }
}