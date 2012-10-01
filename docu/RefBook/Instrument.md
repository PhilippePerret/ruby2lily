Instrument
===========


Relève des mesures
-------------------

(ci-dessous toutes les notes concernant le travail de la méthode `mesures`)

N0001 
  Si au moment de l'ajout d'une première LINote, on a un slure,
  un legato ou une dynamique en route, il faudra faire un 
  traitement particulier. On ne le fait pas ici, ce qui ferait
  des blocs conditionnels à chaque linote. Plutôt, on mémorise
  — cf. ci-dessous — et on le traitera en fin de boucle si
  nécessaire.
  
  Au cours de l'explosion (cf. `explode' ci-dessous), on a pu
  ajouter des propriétés utiles à la LINote (comme par exemple
  un changement de clef). Il faut le traiter ici

N0002
  On ne contrôle pas ici si un slure, un legato ou une dynamique
  comme avec cette LINote, on le fera après le break éventuel.
  Dans le cas contraire, une dernière note qui commencerait un
  crescendo par exemple mettrait le `dyna_run_in' à true, et
  au cours des tests de la fin, il faudrait vérifier si c'est
  elle ou non qui a généré ce départ de dynamique.
  En mettant les contrôles après le break, c'est forcément une
  note précédente qui aura engendré le départ de slure, de legato
  ou de dynamique.

N0003
  On n'a pas encore atteint la première mesure cherchée
  On mémorise et démémorise les marques éventuelles de slure,
  de legato, de dynamique, pour pouvoir les replacer le cas
  échéant.

N0004
  Une fin de mesure est atteinte avec cette note
  Mais c'est peut-être un accord, donc on ne considère que 
  c'est la fin seulement si on est au bout de l'accord
  Si une barre de mesure spéciale est définie, on l'ajoute

N0005
  On génère une erreur non fatale si le numéro de dernière ou de 
  première mesure est trop grand. 
  Noter qu'il ne faut pas générer d'erreur fatale. En effet, le cas
  est simple : si on demande l'affichage de mesures précises, c'est
  certainement qu'on est en train de travailler sur un passage qui
  n'est pas encore défini pour un instrument donné. Donc pour qui
  ces mesures n'existent pas encore. L'erreur générée empêcherait
  tout bonnement de voir ce qui se passe pour les autres instruments
  sur ces mesures.
  Si la liste n'a pas le bon nombre de mesures, on ajoute ce qui
  manque

N0006
  @FIXME: Dans tous les cas ci-dessous on n'étudie pas le fait que
  ce soit ou non un silence. Il est IMPÉRATIF de le faire, car
  une marque de slure, de legato ou de dynamique placé sur un 
  silence génère peut-être une erreur (même si, pourtant, ça peut
  arriver en musique… comme un crescendo sur un accord tenu au
  piano — cf. Liszt ou Beethoven, sais plus)
  Si un slure, un legato ou une dynamique courait avant, sans être
  fermé, il faut l'ajouter à la première note, sauf si cette première
  contient justement la marque de fin de la chose

N0007
  @note 1   `linotes_expected' peut contenir des simples textes (comme
            par exemple des barres spéciales). Il faut donc chercher
            la première linote en partant de la fin
  @note 2   Il se peut, dans l'absolu, qu'il n'y ait pas de last_ln

N0008
  Si la dernière linote commence un slure, un legato ou une dynamique,
  il faut les supprimer
  
  @FIXME: mais attention : tout se passe bien si la commande
  est appelée seule pour extraire des mesures une seule fois.
  En revanche, comme la linote est modifiée, si l'instrument
  doit resservir ailleurs, il deviendra erroné.
  La solution serait d'introduire des clones plutôt que les 
  vraies LINotes du motif.
  
  