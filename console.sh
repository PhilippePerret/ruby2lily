# open ~/.bash_profile
# source ~/.bash_profile # @FIXME: ne semble pas fonctionner

# Se placer à la source de ruby2lily
# cd ~/Sites/cgi-bin/lilypond;pwd
# Se placer à la source des tests ruby2lily
cd ~/Sites/cgi-bin/lilypond/test/rspec;pwd

# rspec spec/class/motif_spec.rb -e "-d doit pouvoir être défini à l'instanciation"

# rspec spec/class/motif_spec.rb

# rspec spec/class/motif_spec.rb -e ":simples_notes, :to_llp et :to_s doivent retourner la bonne valeur"


# CORRECTIONS À FAIRE SUR :
# rspec spec/operation/addition_spec.rb spec/operation/multiplication_spec.rb spec/class/String_spec.rb spec/class/instrument_spec.rb

# Les mêmes que ci-dessus, mais en séparé
# ----------------------------------------
# rspec spec/operation/addition_spec.rb
# rspec spec/operation/multiplication_spec.rb
rspec spec/class/String_spec.rb
# rspec spec/class/instrument_spec.rb

# rspec spec/class/linote_spec.rb
