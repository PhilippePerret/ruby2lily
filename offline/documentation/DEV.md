DÉVELOPPEMENT
==============

# J'EN SUIS À
  - Faire les différents instruments, héritant de Instrument
  
• Faire un repository github
• Fichier qui traite un fichier ruby partition (ruby2lily.rb)
  - analyse de l'orchestre pour sortir des constantes pour chaque 
    instrument. Noms en capitales d'instance de class Instrument

• Penser à des méthodes pratiques telles que :
  - pour copier un motif une octave en dessus (ou n'importe quel 
    interval)
      <le motif>.moins(12)  # 12 = nombre de demi-ton
      <le motif>.plus(12)   # idem
      <le motif>.to_octave_sup
      <le motif>.to_octave_inf
      <le motif>.to_quinte_sup
      <le motif>.to_quinte_inf
        .to_tierce_sup
        .to_tierce_inf
    Cela permettra de copier rapidement et facilement les motifs d'un
    instrument ou d'une mesure à l'autre.
    
    INSTRU.motif.mesure(4) = INSTRU.motif.mesure(3).to_octave_inf
    
    Note: par défault 'motif.mesure(x)' doit être considéré comme les
    notes de la mesure x.