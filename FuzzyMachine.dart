import 'dart:convert';
import 'dart:io';
import 'dart:math';

Follower follower = new Follower();
Engagement engaggement = new Engagement();
Recommendation rekomendasi = new Recommendation();
Influencers influencer = new Influencers(new List(), new List(), new List());

void main() async {
  influencer = await readFile();

  if (influencer.hasData()){
    influencer.followers.forEach((f)=>{
        FollowerRules(f)
    });

    influencer.engangement.forEach((f)=>{
      EngagementRules(f)
    });

    interferensi();

    List<Result> results = new List();
    for(int i = 0; i < influencer.numbers.length;i++){
      results.add(new Result(rekomendasi.numbers[i],rekomendasi.deFuzzyFication[i]));
    }

    results.sort((a,b) => a.value.compareTo(b.value));
    List<Result> descending = results.reversed.toList();

    print("best 20 is : ");
    for(int i = 0;i < 20; i++){
      print("${descending[i].id} = ${descending[i].value}");
    }

  }
}

void showFollower(){
    print("");
    print("========== FOLLOWER Minimal ============");
    follower.minimal.forEach((f)=>{print(f)});
    print("");
    print("========== FOLLOWER Sedikit ============");
    follower.sedikit.forEach((f)=>{print(f)});
    print("");
    print("========== FOLLOWER Cukup ============");
    follower.cukup.forEach((f)=>{print(f)});
    print("");
    print("========== FOLLOWER Banyak ============");
    follower.banyak.forEach((f)=>{print(f)});
}

void showRekomendasi(){
    for(int i = 0; i < influencer.numbers.length; i++){
      print(
          "" + rekomendasi.numbers[i].toString() + " => " +
              rekomendasi.ditolak[i].toString() + " - " +
              rekomendasi.mungkin[i].toString() + " - " +
              rekomendasi.diterima[i].toString() + " => " +
              rekomendasi.deFuzzyFication[i].toString());
    }
}

class Result{
  int id;
  double value;

  Result(this.id, this.value);
}

class Influencers {
  List<int> numbers;
  List<int> followers;
  List<double> engangement;

  Influencers(this.numbers, this.followers, this.engangement);

  bool hasData() {
    return numbers.isNotEmpty && followers.isNotEmpty && engangement.isNotEmpty;
  }
}

class Follower {
  List<double> minimal = new List();
  List<double> sedikit = new List();
  List<double> cukup = new List();
  List<double> banyak = new List();
}

class Engagement {
  List<double> rendah = new List();
  List<double> sedang = new List();
  List<double> tinggi = new List();
}

class Recommendation {
  List<int> numbers = new List();
  List<double> ditolak = new List();
  List<double> mungkin = new List();
  List<double> diterima = new List();
  List<double> deFuzzyFication = new List();
}

Future<Influencers> readFile() async {
  final File file = new File("../influencers.csv");

  var influencers = new Influencers(new List(), new List(), new List());
  Stream<List> inputStream = file.openRead();

  var isTitle = true;
  return await inputStream
      .transform(utf8.decoder) // Decode bytes to UTF-8.
      .transform(new LineSplitter()) // Convert stream to individual lines.
      .listen((String line) {
    // Process results.

    List row = line.split(','); // split by comma

    String id = row[0];
    String followers = row[1];
    String engagement = row[2];

    if (!isTitle) {
      influencers.numbers.add(int.parse(id));
      influencers.followers.add(int.parse(followers));
      influencers.engangement.add(double.parse(engagement));
    } else {
      isTitle = false;
    }
  }, onDone: () {
    print('File is now closed.');
  }, onError: (e) {
    print(e.toString());
  }).asFuture(influencers);
}

double persNaik(double a, b, c) => ((c - a) / (b - a));

double persTurun(double a, b, c) => ((b - c) / (b - a));

/* Follower Rule
	    minimal	  sedikit	  cukup	    tinggi
min	  -inf	    15000	    35000	    55000
max	  20000	    40000	    60000	    inf
*/
void FollowerRules(int data) {
  if (data <= 15000) {
    follower.minimal.add(1);
    follower.sedikit.add(0);
    follower.cukup.add(0);
    follower.banyak.add(0);
  } else if ((data > 15000) && (data < 20000)) {
    follower.minimal.add(persTurun(15000, 20000, data));
    follower.sedikit.add(persNaik(15000, 20000, data));
    follower.cukup.add(0);
    follower.banyak.add(0);
  } else if ((data >= 20000) && (data <= 35000)) {
    follower.minimal.add(0);
    follower.sedikit.add(1);
    follower.cukup.add(0);
    follower.banyak.add(0);
  } else if ((data > 35000) && (data < 40000)) {
    follower.minimal.add(0);
    follower.sedikit.add(persTurun(35000, 40000, data));
    follower.cukup.add(persNaik(35000, 40000, data));
    follower.banyak.add(0);
  } else if ((data >= 40000) && (data <= 55000)) {
    follower.minimal.add(0);
    follower.sedikit.add(0);
    follower.cukup.add(1);
    follower.banyak.add(0);
  } else if ((data > 55000) && (data < 60000)) {
    follower.minimal.add(0);
    follower.sedikit.add(0);
    follower.cukup.add(persTurun(55000, 60000, data));
    follower.banyak.add(persNaik(55000, 60000, data));
  } else if (data >= 60000) {
    follower.minimal.add(0);
    follower.sedikit.add(0);
    follower.cukup.add(0);
    follower.banyak.add(1);
  }
}

/* Engagement Rule
	    rendah	  sedang	tinggi
min	  -inf	    2.5	      5
max	    3	      5.5 	   inf
*/
void EngagementRules(double data) {
  if (data <= 2.5) {
    engaggement.rendah.add(1);
    engaggement.sedang.add(0);
    engaggement.tinggi.add(0);
  } else if ((data > 2.5) && (data < 3)) {
    engaggement.rendah.add(persTurun(2.5, 3, data));
    engaggement.sedang.add(persNaik(2.5, 3, data));
    engaggement.tinggi.add(0);
  } else if ((data >= 3) && (data <= 5)) {
    engaggement.rendah.add(0);
    engaggement.sedang.add(1);
    engaggement.tinggi.add(0);
  } else if ((data > 5) && (data < 5.5)) {
    engaggement.rendah.add(0);
    engaggement.sedang.add(persTurun(5, 5.5, data));
    engaggement.tinggi.add(persNaik(5, 5.5, data));
  } else if (data >= 5.5) {
    engaggement.rendah.add(0);
    engaggement.sedang.add(0);
    engaggement.tinggi.add(1);
  }
}

double minimalValue(double fol, eng) {
  if (fol <= eng) {
    return fol;
  } else {
    return eng;
  }
}

/* INTERFERENSI TABEL REKOMENDASI
        Minim   Sedikit   Cukup    Banyak
Rendah  DEC       DEC      CONS    CONS
Sedang  DEC      CONS      ACC     ACC
Tinggi  CONS      ACC      ACC     ACC
*/
void interferensi() {
  rekomendasi = new Recommendation();
  for (int i = 0; i < influencer.numbers.length; i++) {
    var rejected = [];
    var consider = [];
    var accepted = [];

    if (follower.minimal[i] != 0 && engaggement.rendah[i] != 0) {
      rejected.add(minimalValue(follower.minimal[i], engaggement.rendah[i]));
    }
    if (follower.minimal[i] != 0 && engaggement.sedang[i] != 0) {
      rejected.add(minimalValue(follower.minimal[i], engaggement.sedang[i]));
    }
    if (follower.sedikit[i] != 0 && engaggement.rendah[i] != 0) {
      rejected.add(minimalValue(follower.sedikit[i], engaggement.rendah[i]));
    }

    if (follower.cukup[i] != 0 && engaggement.rendah[i] != 0) {
      consider.add(minimalValue(follower.cukup[i], engaggement.rendah[i]));
    }
    if (follower.minimal[i] != 0 && engaggement.tinggi[i] != 0) {
      consider.add(minimalValue(follower.minimal[i], engaggement.tinggi[i]));
    }
    if (follower.sedikit[i] != 0 && engaggement.sedang[i] != 0) {
      consider.add(minimalValue(follower.sedikit[i], engaggement.sedang[i]));
    }
    if (follower.banyak[i] != 0 && engaggement.rendah[i] != 0) {
      consider.add(minimalValue(follower.banyak[i], engaggement.rendah[i]));
    }

    if (follower.sedikit[i] != 0 && engaggement.tinggi[i] != 0) {
      accepted.add(minimalValue(follower.sedikit[i], engaggement.tinggi[i]));
    }
    if (follower.cukup[i] != 0 && engaggement.sedang[i] != 0) {
      accepted.add(minimalValue(follower.cukup[i], engaggement.sedang[i]));
    }
    if (follower.cukup[i] != 0 && engaggement.tinggi[i] != 0) {
      accepted.add(minimalValue(follower.cukup[i], engaggement.tinggi[i]));
    }
    if (follower.banyak[i] != 0 && engaggement.sedang[i] != 0) {
      accepted.add(minimalValue(follower.banyak[i], engaggement.sedang[i]));
    }
    if (follower.banyak[i] != 0 && engaggement.tinggi[i] != 0) {
      accepted.add(minimalValue(follower.banyak[i], engaggement.tinggi[i]));
    }

    if (accepted.isNotEmpty && accepted.length > 1) {
      double maxVal = 0;
      accepted.forEach((acc) => {maxVal = max(maxVal, acc)});
      rekomendasi.diterima.add(maxVal);
    } else if (accepted.isNotEmpty) {
      rekomendasi.diterima.add(accepted[0]);
    } else {
      rekomendasi.diterima.add(0);
    }

    if (consider.isNotEmpty && consider.length > 1) {
      double maxVal = 0;
      consider.forEach((acc) => {maxVal = max(maxVal, acc)});
      rekomendasi.mungkin.add(maxVal);
    } else if (consider.isNotEmpty) {
      rekomendasi.mungkin.add(consider[0]);
    } else {
      rekomendasi.mungkin.add(0);
    }

    if (rejected.isNotEmpty && rejected.length > 1) {
      double maxVal = 0;
      rejected.forEach((acc) => {maxVal = max(maxVal, acc)});
      rekomendasi.ditolak.add(maxVal);
    } else if (rejected.isNotEmpty) {
      rekomendasi.ditolak.add(rejected[0]);
    } else {
      rekomendasi.ditolak.add(0);
    }

    rekomendasi.numbers.add(influencer.numbers[i]);
    rekomendasi.deFuzzyFication.add(defuzzifikasi(rekomendasi.ditolak[i],
        rekomendasi.mungkin[i], rekomendasi.diterima[i]));
  }
}

/*
  Defuzzyfikasi Percentage;
  a => ditolak => 50%
  b => mungkin => 70%
  c => diterima => 90%
 */
double defuzzifikasi(double a, b, c) {
  var result = a * 0.5;
  result += b * 0.7;
  result += c * 0.9;
  result /= (a + b + c);
  result *= 100;

  return result;
}




