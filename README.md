Ruby2Lily READ-ME FILE
======================

Projet de programme pour simplifier l'utilisation de Lilypond grâce à Ruby.

- Version 1.1.1 (stable)

Exemple rapide
---------------

**Ficher partition Ruby**

```ruby
# par exemple dans > score/premier_score.rb

@title    = "Mon premier score lily2ruby"
@composer = "Phil"
@time     = "6/8"
@key      = "G"

def orchestre
  <<-EOO
    
    name    instrument
  -------------------------------------------------------------------
    JANE    Voice
    PETE    Piano
    HELEN   Cello
  -------------------------------------------------------------------
  EOO
end

def score
  JANE << ("c4" * 3 + "e g" + "c" * 3) * 3
  PETE.main_droite << (riff_do + riff_fa + riff_sol) * 2
  PETE.main_gauche << (riffb_do + riffb_fa + riffb_sol) * 2
  HELEN << "c2. e g"
end

# Définition des riffs
def riff_do
  @riff_do ||= define_riff_do
end
def riff_fa
  @riff_fa ||= riff_do.moins(7)
end
def riff_sol
  puts "riff_fa : #{riff_fa.inspect}"
  riff_fa.plus(2)
end
def define_riff_do
  acc_do = Chord::new "g c e"
  Motif::new acc_do[8] + acc_do[4] * 2 + acc_do[8]
end
def riffb_do
  @riffb_do ||= Motif::new( "c8 c2 c8" ).to_s
end
def riffb_fa
  @riffb_fa ||= riffb_do.moins(7)
end
def riffb_sol
  riffb_fa.plus(2)
end
```

On lance la création de la partition :

```
    $ ruby2lily 'score/premier_score'
```

Ce qui génère :

\[Image requise]

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
