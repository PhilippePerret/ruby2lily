Définition de la partition
===========================

La partition d'un instrument (ie ses notes) est définie principalement par la méthode :

    <instance instrument>.add

Cette méthode peut recevoir différentes valeurs :

* Un string

    INSTRU.add "a c g b"
    INSTRU.add "a1 c2. r2. b4"
    INSTRU.add "(a b c d)"

Gérer `add` revient à se demander comment mémoriser la partition de l'instrument.
J'aimerais bien avoir une définition par mesure, mais dans ce cas, chaque entrée doit être analyser, pour savoir, par exemple, que "c2 b a4 g g g g" couvre 2 mesures et une noire si la signature est 4/4.
La solution la plus simple serait de tout mettre bout à bout en string.
C'est la solution simple adoptée pour le moment.

D'autre part, pour le moment, l'ajout se fait de façon séquentielle, c'est-à-dire qu'aucun insert ne peut être fait.

La seule complexité réside dans le fait de pouvoir entrer des accords ou des motifs.