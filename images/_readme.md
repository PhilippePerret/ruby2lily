Utilisation d'images dans le wiki
==================================

1.  **Coder le fichier score ruby** dans le dossier de l'image
    (ajouter une portion @code avec l'extrait important du score)
2.  **Lancer la fabrication** de la partition (ALT+CMD+P)
3.  Ouvrir le PDF généré (dans Aperçu)
4.  Dans Aperçu, **mettre à la bonne taille** (jouer sur la taille de la fenêtre et la loupe si nécessaire)
5.  **Sélectionner** l'extrait voulu et l'**exporter** en PNG
    - Fichier > Effectuer une capture d'écran > À partir de la sélection…
    - Sélectionner la partie utile
    - Fichier > Exporter vers PNG
5.  Dans le finder, **détruire les fichiers-partition** .pdf et .ly
6.  Sur le wiki, **utiliser le code suivant** pour insérer l'image (modifier le path si nécessaire)&nbsp;:

        [[https://github.com/PhilippePerret/ruby2lily/raw/master/images/wiki/<nom-image>.png]]
7.  Actualiser le dépôt Github
        
**(*Noter que le lien ne fonctionnera —&nbsp;affichage de l'image&nbsp;– que lorsque la branche courante aura été mergée avec le master*)**