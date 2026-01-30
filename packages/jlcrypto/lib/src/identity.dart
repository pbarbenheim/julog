class Identity {
  String name;
  String function;
  String mail;

  Identity(this.name, this.function, this.mail);

  @override
  String toString() {
    return "$name <$mail> ($function)";
  }

  factory Identity.fromString(String identityString) {
    final parts = identityString.split(' <');
    final name = parts[0];
    final mailAndFunction = parts[1].split('> (');
    final mail = mailAndFunction[0];
    final function = mailAndFunction[1].substring(
      0,
      mailAndFunction[1].length - 1,
    );

    return Identity(name, function, mail);
  }
}
