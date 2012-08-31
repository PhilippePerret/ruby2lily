À quoi je voudrais que ressemble une partition
===============================================

Je vais essayer de définir ici, le mieux possible, ce à quoi je voudrais que ressemble une partition ruby pour lilypond.

Pour définir les données générales du morceau ou de la chanson
---------------------------------------------------------------

    # Définition des titres et autres
    title       = "Le titre de la musique/chanson"
    author      = "L'auteur de la musique/chanson"
    instrument  = "L'instrument visé (quand partie seule)"
    etc. d'autres directives comme le parolier si chanson, etc.

Pour définir le système
------------------------

    # Définition du système (nombre de portées)
    
    system = <<-DEFH
    
      id          inst      clef    ton
    -------------------------------------------------------------------
      VXSOLO    chant     G       B
      VXDEUX    chant     G       B
      PIANO     piano     G       B
                          F       B
      VIOLON    violon    G       B
      ALTO      alto      G       B
      CELLO     cello     G       B
      BASS                F       B
    -------------------------------------------------------------------
    DEFH

Le DEFH ci-dessus permet de représenter le système utilisé.
L'identifiant va permettre de définir chaque portée.
Les instruments doivent être mis en majuscule, car ils deviendront des instrument (instance de Instrument)

Définition des notes :
-------------------------------------------------------------------

Par principe, toute portée non définie est vide.
On définit toutes les portées non vides.

Par exemple :

    vxsolo.add from_to, notes
    
    vxsolo.add 4, "do si ré la"
    # => Ajoute les notes "do si ré la" à partir de la mesure 4

L'idée ne peut-elle pas être que la musique utilise souvent les mêmes notes dans les portées, et donc de la définir modulairement. Par exemple :

  accord_sol_guitare = 
    do.octave(4).noire.pointee +
    do.octave(5).noire.pointee +
    mi.octave(5).noire.pointee,
    idem.croche,
    idem.croche,
    idem.noire.pointee
    
-> 'idem' reprend les mêmes notes que l'accord précédent

Ou si accord est un groupe de notes

    accord_do_bmi = Accord::new( 'do4', 'mi4', 'sol4' )
    
    mes1 = [
    accord_do_bmi.noire.pointee,
    idem.croche,
    idem.croche,
    idem.noire
    ]

On peut ranger les mesures dans l'instrument :

  Guitare.mesures.add( <la mesure à ajouter> )
  
  Guitare.accords.add( <l'accord à ajouter> )
  
Guitare est un objet de type Instrument


Si au contraire on fonction en mesures, on peut avoir une meilleure vue d'ensemble.
Mais il serait possible de concilier les différentes choses en rassemblant les informations, pour pouvoir définir la partition soit par instrument, soit par mesure.

  mesure(1) = <définition de la mesure>
  
Et on pourrait définir en DEFH les systèmes

  portion = <<-DEFH
  
    chant     mesure_unnorm idem            idem
    guitare   rythme_unnorm rythme_unvar1   rythme_unnorm
    basse     riff_unnormal riff_deuxnormal riff_trois
  
  DEFH
  
  couplet = <<-DEFH
  
    chant       motifA    %       motifB      motifA
    guitare     motifA    motifB  %           %
    
  DEFH