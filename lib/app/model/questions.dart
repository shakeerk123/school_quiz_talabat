class Question {
  final String questionForKid;
  final String questionForParent;
  final List<Option> options;

  Question({
    required this.questionForKid,
    required this.questionForParent,
    required this.options,
  });
}

class Option {
  final String text;
  final String imagePath;

  Option({
    required this.text,
    required this.imagePath,
  });
}

List<Question> getQuestions() {
  return [
    Question(
      questionForKid: "What's your favorite fruit?",
      questionForParent: "What's your kid's favorite fruit?",
      options: [
        Option(text: "Apple", imagePath: "assets/images/apple.png"),
        Option(text: "Banana", imagePath: "assets/images/bananas.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite color?",
      questionForParent: "What's your kid's favorite color?",
      options: [
        Option(text: "Red", imagePath: "assets/images/red.png"),
        Option(text: "Blue", imagePath: "assets/images/blue.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite animal?",
      questionForParent: "What's your kid's favorite animal?",
      options: [
        Option(text: "Dog", imagePath: "assets/images/dog.png"),
        Option(text: "Cat", imagePath: "assets/images/cat.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite subject in school?",
      questionForParent: "What's your kid's favorite subject in school?",
      options: [
        Option(text: "Math", imagePath: "assets/images/math.png"),
        Option(text: "Science", imagePath: "assets/images/science.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite sport?",
      questionForParent: "What's your kid's favorite sport?",
      options: [
        Option(text: "Soccer", imagePath: "assets/images/soccer.png"),
        Option(text: "Basketball", imagePath: "assets/images/basketball.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite drink?",
      questionForParent: "What's your kid's favorite drink?",
      options: [
        Option(text: "Milk", imagePath: "assets/images/milk.png"),
        Option(text: "Juice", imagePath: "assets/images/juice.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite hobby?",
      questionForParent: "What's your kid's favorite hobby?",
      options: [
        Option(text: "Reading", imagePath: "assets/images/reading.png"),
        Option(text: "Playing Games", imagePath: "assets/images/gaming.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite season?",
      questionForParent: "What's your kid's favorite season?",
      options: [
        Option(text: "Summer", imagePath: "assets/images/summer.png"),
        Option(text: "Winter", imagePath: "assets/images/winter.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite ice cream flavor?",
      questionForParent: "What's your kid's favorite ice cream flavor?",
      options: [
        Option(text: "Chocolate", imagePath: "assets/images/chocolate.png"),
        Option(text: "Vanilla", imagePath: "assets/images/vanilla.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite superhero?",
      questionForParent: "What's your kid's favorite superhero?",
      options: [
        Option(text: "Superman", imagePath: "assets/images/superman.png"),
        Option(text: "Batman", imagePath: "assets/images/batman.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite cartoon?",
      questionForParent: "What's your kid's favorite cartoon?",
      options: [
        Option(text: "SpongeBob", imagePath: "assets/images/spongebob.png"),
        Option(text: "Mickey Mouse", imagePath: "assets/images/mickey_mouse.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite holiday?",
      questionForParent: "What's your kid's favorite holiday?",
      options: [
        Option(text: "Christmas", imagePath: "assets/images/christmas.png"),
        Option(text: "Halloween", imagePath: "assets/images/halloween.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite game?",
      questionForParent: "What's your kid's favorite game?",
      options: [
        Option(text: "Chess", imagePath: "assets/images/chess.png"),
        Option(text: "Checkers", imagePath: "assets/images/checkers.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite movie?",
      questionForParent: "What's your kid's favorite movie?",
      options: [
        Option(text: "Frozen", imagePath: "assets/images/frozen.png"),
        Option(text: "Toy Story", imagePath: "assets/images/toy_story.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite book?",
      questionForParent: "What's your kid's favorite book?",
      options: [
        Option(text: "Harry Potter", imagePath: "assets/images/harry_potter.png"),
        Option(text: "The Cat in the Hat", imagePath: "assets/images/cat_in_the_hat.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite place to visit?",
      questionForParent: "What's your kid's favorite place to visit?",
      options: [
        Option(text: "Zoo", imagePath: "assets/images/zoo.png"),
        Option(text: "Beach", imagePath: "assets/images/beach.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite snack?",
      questionForParent: "What's your kid's favorite snack?",
      options: [
        Option(text: "Chips", imagePath: "assets/images/chips.png"),
        Option(text: "Cookies", imagePath: "assets/images/cookies.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite pizza topping?",
      questionForParent: "What's your kid's favorite pizza topping?",
      options: [
        Option(text: "Pepperoni", imagePath: "assets/images/pepperoni.png"),
        Option(text: "Cheese", imagePath: "assets/images/cheese.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite toy?",
      questionForParent: "What's your kid's favorite toy?",
      options: [
        Option(text: "Lego", imagePath: "assets/images/lego.png"),
        Option(text: "Doll", imagePath: "assets/images/doll.png"),
      ],
    ),
    Question(
      questionForKid: "What's your favorite day of the week?",
      questionForParent: "What's your kid's favorite day of the week?",
      options: [
        Option(text: "Saturday", imagePath: "assets/images/saturday.png"),
        Option(text: "Sunday", imagePath: "assets/images/sunday.png"),
      ],
    ),
  ];
}
