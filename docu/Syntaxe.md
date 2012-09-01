ÉLÉMENTS DE SYNTAXE 
====================

Commentaires
-------------

% seul

    %{
  
    %}


Entête
-------

\header {
  ...
}

\header {
  title = "Titre du morceau"
}


Octave supérieure et inférieure
---------------------------------

Écrire à partir d'une note relative
------------------------------------

\relative c'' {
  c d e f g h a b
}

Altérations
-----------
dièze : is        is          ais4    => La dièze en noire
bémol : es        es          bes1    => Si bémol en ronde
double-dièze      isis        cisis2  => Do double-dièze en blanche
double-bémol      eses        eeses   => Mi double-bémol durée précédente

@note : dans le programme, il faudrait pouvoir les définir par # et ß (alt + b)

Tie (liaison de durée)
-----------------------------
(par exemple lorsque la même note doit être tenue d'une mesure à l'autre)

    ~

Par exemple, pour qu'une note tienne sur deux mesures de 4/4 :

    c1~ c

Slur (liaison de jeu)
----------------------

Pour une liaison de jeu, on doit ajouter une parenthèse après la première note de la liaison, jusqu'à la dernière.

Donc, pour mettre une liaison complète sur :

    c d e d e c

… on doit écrire :

    c( d e d e c)

Dans ruby2lily, ça serait bien de simplifier en pouvant faire :

    (c d e d e c)

… qui me semble plus naturel

Pour une longue liaison de jeu (ou imbriquer des liaisons de jeu), on utilise \(...\)

Par exemple :

    c\( d( e) d( e) c\) 
  
Articulations
---------------

Utiliser :

    <note>-<articulation><doigté>

Par exemple :

    ais4-^3

… pour un la dièse en noire joué avec le troisième doigt qui doit être accentué

Les articulations sont :

    >   Accentuée
    -   Lourée (donc "<note>--")
    _   Piquée lourée (trait plat)
    ^   Accentuée
    .   Piquée
    +   Plus
    |   Marquée

Dynamique
----------

Après la note :

    \ff
    \mf
    \pp
    \p

Crescendo et decrescendo
-------------------------

    \<    Début du crescendo
    Tout signe de dynamique interromp la cres ou descresc
    \>    Début du decrescendo
    \!    Fin du cres/decres quand pas de dynamique pour le terminer
    
Style de portées
-----------------

Pour un piano :

    \new PianoStaff <<
      \new Staff { ... }
      \new Staff { ... }
    >>

Pour un orchestre :

    \new GrandStaff <<
      \new Staff { ... }
      \new Staff { ... }
      ... etc
    >>

Pour un chœur :

    \new ChoirStaff <<
      \new Staff { ... }
      \new Staff { ... }
      \new Staff { ... }
      ...
    >>

Note: il faudra modifier le code actuel pour que ce soit l'instrument qui génère ce `\new Quelquechose` plutôt que le score, afin de profiter vraiment des types d'instruments.


Contextes :
------------
    \new Score        Définition d'un nouveau contexte de partition
    \new Staff        Définition de portée
    \new Voice        Définition de nouvelle portée voix
    \new Lyrics       Définition de nouvelles paroles
    \new ChordNames   Définition des accords
    
Ajout de paroles
----------------

    \addlyrics
    
Par exemple :

    <<
      \relative c'' {
      
      }
      \addlyrics {
        
      }
    >