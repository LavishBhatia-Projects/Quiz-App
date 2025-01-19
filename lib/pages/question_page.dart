import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app2/Data/api.dart';
import 'package:quiz_app2/pages/result_page.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage>
    with TickerProviderStateMixin {
  int totalQuestions = 0;
  int currentQuestionIndex = 0;
  List questions = [];
  List<List<String>> options = [];
  List<int> correctIndex = [];
  int _remainingTime = 15;
  late Timer _timer;
  String _selectedAnswer = '';
  int _selectedIndex = -1;
  late AnimationController _optionButtonController;
  late AnimationController _submitButtonController;
  late AnimationController _questionChangeController;

  int correctAnswersCount = 0;
  bool isSubmitted = false;
  List<String> selectedAnswers = [];
  List<bool> answerCorrectness = [];

  Future apiData() async {
    try {
      final res = await http.get(Uri.parse(ApiKey));
      final data = jsonDecode(res.body);
      if (res.statusCode != 200) {
        throw 'An unexpected error occurred.';
      }

      setState(() {
        totalQuestions = data['questions_count'];
      });

      for (int i = 0; i < totalQuestions; i++) {
        questions.add(data['questions'][i]['description']);
        List<String> questionOptions = [];
        for (int j = 0; j < 4; j++) {
          questionOptions
              .add(data['questions'][i]['options'][j]['description']);
        }
        options.add(questionOptions);

        for (int j = 0; j < 4; j++) {
          if (data['questions'][i]['options'][j]['is_correct'] == true) {
            correctIndex.add(j);
            break;
          }
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    apiData();
    _startTimer();
    _optionButtonController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _submitButtonController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _questionChangeController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: 500), () {
      _optionButtonController.forward();
      _submitButtonController.forward();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        _timer.cancel();
        _submitAnswer();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _submitAnswer() {
    setState(() {
      selectedAnswers.add(_selectedAnswer);
      answerCorrectness
          .add(_selectedIndex == correctIndex[currentQuestionIndex]);

      if (_selectedIndex == correctIndex[currentQuestionIndex]) {
        correctAnswersCount++;
      }

      isSubmitted = true;
      _showResultDialog(_selectedIndex == correctIndex[currentQuestionIndex]);

      if (currentQuestionIndex < totalQuestions) {
        _questionChangeController.forward().then((value) {
          setState(() {
            currentQuestionIndex++;
            _remainingTime = 15;
            _timer.cancel();
            _startTimer();
            _selectedIndex = -1;
            _selectedAnswer = '';
            isSubmitted = false;
          });
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              score: correctAnswersCount,
              totalQuestions: totalQuestions,
              correctAnswers: correctAnswersCount,
            ),
          ),
        );
      }
    });
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(seconds: 1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.error,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 50,
                  ),
                  SizedBox(height: 20),
                  Text(
                    isCorrect ? "You killed it!" : "Better luck next time",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
      if (currentQuestionIndex == totalQuestions - 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              score: correctAnswersCount,
              totalQuestions: totalQuestions,
              correctAnswers: correctAnswersCount,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _optionButtonController.dispose();
    _submitButtonController.dispose();
    _questionChangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Quiz App',
          style: GoogleFonts.josefinSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.blueAccent],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: screenWidth * 0.95,
                      height: screenHeight * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Material(
                              elevation: 8.0,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: double.infinity,
                                height: screenHeight * 0.35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Question ${currentQuestionIndex + 1}/${totalQuestions}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(height: 20),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            questions.isNotEmpty
                                                ? questions[
                                                    currentQuestionIndex]
                                                : 'Loading...',
                                            style: GoogleFonts.josefinSans(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                OptionButton(
                                  options.isNotEmpty
                                      ? options[currentQuestionIndex][0]
                                      : 'Loading...',
                                  screenWidth * 0.7,
                                  0,
                                ),
                                OptionButton(
                                  options.isNotEmpty
                                      ? options[currentQuestionIndex][1]
                                      : 'Loading...',
                                  screenWidth * 0.7,
                                  1,
                                ),
                                OptionButton(
                                  options.isNotEmpty
                                      ? options[currentQuestionIndex][2]
                                      : 'Loading...',
                                  screenWidth * 0.7,
                                  2,
                                ),
                                OptionButton(
                                  options.isNotEmpty
                                      ? options[currentQuestionIndex][3]
                                      : 'Loading...',
                                  screenWidth * 0.7,
                                  3,
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: screenWidth * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent,
                                        blurRadius: 5.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _submitAnswer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 15),
                                    ),
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.purple,
                                        fontFamily: GoogleFonts.josefinSans()
                                            .fontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 5.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$_remainingTime',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget OptionButton(String optionText, double width, int index) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_remainingTime > 0 && !isSubmitted) {
                    _selectedAnswer = optionText;
                    _selectedIndex = index;
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(
                  color: isSelected ? Colors.purple : Colors.transparent,
                  width: 2,
                ),
                minimumSize: Size(0, 50),
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.josefinSans().fontFamily,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
