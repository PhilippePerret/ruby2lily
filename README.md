Ruby2Lily READ-ME FILE
======================

Projet de programme pour simplifier l'utilisation de Lilypond grâce à Ruby.

Commande lilypond sur mac
--------------------------

Ce code, à exécuter ligne à ligne dans une fenêtre Terminal, permettra d'utiliser la commande `lilypond <fichier>` dans le Terminal. Il est nécessaire pour produire le fichier PDF du score ruby.

    $ cd /usr/bin
    $ touch lilypond
    $ echo 'exec /Applications/LilyPond.app/Contents/Resources/bin/lilypond "$@"' > lilypond
    $ chmod u+x lilypond

Si un problème de permission est levé, utiliser plutôt le code :

    $ cd /usr/bin
    $ sudo touch lilypond
    [Entrez votre mot de passe]
    $ sudo chmod 0777 lilypond
    $ sudo echo 'exec /Applications/LilyPond.app/Contents/Resources/bin/lilypond "$@"' > lilypond
    $ sudo chmod u+x lilypond


Commande ruby2lily sur Mac
---------------------------

    $ cd /usr/bin
    $ touch ruby2lily

ci-dessous, vous devez remplacer `PATH/TO/RUBY2LILY/` par le path à votre dossier téléchargé de ruby2lily :

    $ echo 'exec PATH/TO/RUBY2LILY/ruby2lily.rb "$@" > ruby2lily'
    $ chmod u+x ruby2lily
    
Ou en cas de problème de permissions :

    $ cd /usr/bin
    $ sudo touch ruby2lily
    [Entrez votre mot de passe]
    $ sudo chmod 0777 ruby2lily

ci-dessous, vous devez remplacer `PATH/TO/RUBY2LILY/` par le path à votre dossier téléchargé de ruby2lily :

    $ sudo echo 'exec PATH/TO/RUBY2LILY/ruby2lily.rb "$@" > ruby2lily'
    $ sudo chmod u+x ruby2lily
