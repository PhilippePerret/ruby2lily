# open ~/.bash_profile
# source ~/.bash_profile # @FIXME: ne semble pas fonctionner

# Se placer à la source de ruby2lily
# cd ~/Sites/cgi-bin/lilypond;pwd
# Se placer à la source des tests ruby2lily
cd ~/Sites/cgi-bin/lilypond/test/rspec;pwd

# rspec spec/class/motif_spec.rb -e "-d doit pouvoir être défini à l'instanciation"

# rspec spec/class/motif_spec.rb -e ":simples_notes, :to_llp et :to_s doivent retourner la bonne valeur"

# rspec spec/class/motif_spec.rb -e "Dynamique"

rspec spec/class/linote_spec.rb -e "Dépôt :post sur première ou dernière note"