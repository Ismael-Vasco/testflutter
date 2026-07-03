/// Lista fija de las 4 personas del grupo, tal como pide el enunciado.
enum Person { ana, juan, sofia, carlos }

extension PersonLabel on Person {
  String get displayName {
    switch (this) {
      case Person.ana:
        return 'Ana';
      case Person.juan:
        return 'Juan';
      case Person.sofia:
        return 'Sofía';
      case Person.carlos:
        return 'Carlos';
    }
  }
}
