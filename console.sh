# open ~/.bash_profile
# source ~/.bash_profile # @FIXME: ne semble pas fonctionner


# ruby -rtracer ruby2lily.rb '/Users/philippeperret/Music/Musiques-perso/Chansons/Pyjama/pyjama/score.rb'
# exit

# Se placer à la source de ruby2lily
# cd ~/Sites/cgi-bin/lilypond;pwd
# Se placer à la source des tests ruby2lily
cd ~/Sites/cgi-bin/lilypond/test/rspec;pwd

# LA TOTALE
# rspec spec

# rspec spec/class/String_spec.rb

# rspec spec/class/motif_spec.rb spec/class/motif/octave_spec.rb
# rspec spec/class/motif_spec.rb
# rspec spec/class/motif/octave_spec.rb
# rspec spec/class/linote_spec.rb
# rspec spec/class/linote/explode_spec.rb

# rspec spec/class/score_spec.rb

# rspec spec/class/instrument_spec.rb
# rspec spec/class/instrument/to_lilypond_spec.rb
# rspec spec/class/instrument_spec.rb -e "doit renvoyer les bonnes notes avec des liaisons de durée (~)"
# rspec spec/class/linote_spec.rb

# rspec spec/class/note_spec.rb
# rspec spec/class/chord_spec.rb
# rspec spec/class/noteclass_spec.rb

# rspec spec/operation/addition_spec.rb
# rspec spec/operation/crochets_spec.rb
# rspec spec/class/noteclass_spec.rb
# rspec spec/operation/multiplication_spec.rb

# --- INSTRUMENTS ---
rspec spec/class/instruments/voice_spec.rb