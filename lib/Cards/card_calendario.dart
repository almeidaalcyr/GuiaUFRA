import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../assets/divisor.dart';
import '../evento.dart';

class CardCalendario extends StatelessWidget {
  late int indice;

  CardCalendario(this.indice);

  @override
  Widget build(BuildContext context) {
    var inputFormato = DateFormat('yyyy-MM-dd');
    var outputFormato = DateFormat('dd MM yyyy');

    String dataExt = "";
    DateTime hoje = inputFormato.parse(DateTime.now().toString());
    if (!Evento.eventos[indice]
        .intervaloDeDatas) { //Evento em vários dias, não contíguos
      for (int i = 0; i < Evento.eventos[indice].listaDatas.length; i++) {
        i == 0
            ? dataExt = outputFormato.format(Evento.eventos[indice].dataInicio!)
            .toUpperCase()
            : dataExt =
        "$dataExt | ${outputFormato.format(Evento.eventos[indice].dataInicio!)
            .toUpperCase()}";
      }
    }

    else { //Evento em um intervalo
      dataExt = "${outputFormato.format(Evento.eventos[indice].listaDatas[0])
          .toUpperCase()} a ${outputFormato.format(
          Evento.eventos[indice].listaDatas[1]).toUpperCase()}";
    }


    /* Aqui começa a criação do card */
    Text tempo = Text("");
    Text msgTempo = Text("");
    double fontsize = 17;
    late Color cor;

    if (Evento.eventos[indice].passado) {
      cor = Colors.red;
      tempo = Text("PASSADO", textAlign: TextAlign.right,
        style: TextStyle(backgroundColor: Colors.red,),);

      if (hoje
          .difference(Evento.eventos[indice].dataFim!)
          .inDays != 1) {
        msgTempo = Text("Terminou há ${hoje
            .difference(Evento.eventos[indice].dataFim!)
            .inDays} dias", textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontsize),);
      }
      else {
        msgTempo = Text("Terminou ontem", textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontsize),);
      }
    }

    else if (Evento.eventos[indice].presente) {
      cor = Colors.yellow[800]!;
      tempo = Text("ATUAL", textAlign: TextAlign.right,
        style: TextStyle(backgroundColor: Colors.yellow, fontSize: fontsize),);

      if (Evento.eventos[indice].dataFim!.difference(hoje).inDays > 1) {
        msgTempo = Text("Termina em ${Evento.eventos[indice]
            .dataFim!
            .difference(hoje)
            .inDays} dias", textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontsize),);
      }
      else if (Evento.eventos[indice].dataFim!.difference(hoje).inDays == 1) {
        msgTempo = Text("Termina amanhã", textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontsize),);
      }
      else if (Evento.eventos[indice].dataFim!.difference(hoje).inDays == 0) {
        msgTempo = Text("Termina hoje", textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontsize),);
      }
    }

    else if (Evento.eventos[indice].futuro) {
      cor = Colors.green;
      tempo = Text("FUTURO", textAlign: TextAlign.right,
        style: TextStyle(backgroundColor: Colors.green, fontSize: fontsize),);

      if (Evento.eventos[indice].dataInicio!.difference(hoje).inDays > 1) {
        msgTempo = Text("Inicia em ${Evento.eventos[indice]
            .dataInicio!
            .difference(hoje)
            .inDays} dias", textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontsize),);
      }
      else
      if (Evento.eventos[indice].dataInicio!.difference(hoje).inDays == 1) {
        msgTempo = Text("Inicia amanhã", textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontsize),);
      }
    }

    return ListTile(
      leading: Icon(
        Icons.calendar_today_outlined,
        color: cor,
      ),
      title: Text(Evento.eventos[indice].evento),
      subtitle: Text(dataExt),
    );
  }
}



/*Column(
      children: [
        Container(
          //padding: const EdgeInsets.all(5),
          //height: 50,
          
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                      Text(Evento.eventos[indice].evento, textAlign: TextAlign.left, style: TextStyle(fontSize: fontsize),),
                    
                    //Text(""),
                    
                    /*Align(alignment: Alignment.bottomLeft,
                      child: */Text(dataExt, textAlign: TextAlign.left,)
                    //),
                  ]
                ),
              ),
              Column(
                children: [
                  Container(
                    //padding: const EdgeInsets.all(15),
                    height: 50,
                    width: 100,
                    
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: cor, width: 3),
                      //color: Colors.green
                    ),
                    //color: Colors.red,
                    child: Align(alignment: Alignment.center,
                    child: msgTempo,) ,
                  )
                ],
              )
            ],
          ),
        ),
        divisor(),
      ]
    );
  }
  }*/

