NOTES TUTORIELS
===============

• Tutoriel sur l'utilisation d'une shell-script textmate pour lancer
  la création
  cf. celui de Nos Habitudes

• Tutoriel sur le choix des mesures à afficher
  Ces trois syntaxes sont équivalentes
    $ ruby2lily score.rb -m4-8
    $ ruby2lily score.rb -m=4-8
    $  ruby2lily score.rb --mesures=4-8
  ... et sortiront les mesures de 4 à 8 comprises
  @note: normalement, sauf s'il y a des coupures ?

Préciser qu'il vaut mieux utiliser `<<` pour construire une suite de
notes plutôt que le signe "+"

    notes = "a a a a " << "b b b b" # ATTENTION À L'ESPACE !
    # plutôt que : 
    notes = "a a a a" + "b b b b"
    Motif::new notes
    
Dans le premier cas, c'est seulement un string qui sera envoyé au motif
Dans le second, le signe `+` va créer un motif avec "a a a a" et lui joindre "b b b b" transformé aussi en motif => plus compliqué

En revanche, si :

    notes = "a a a a" + "b b b b"

Ici, `notes` est directement un motif.