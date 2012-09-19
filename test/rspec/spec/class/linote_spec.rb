# 
# Tests de la classe LINote
# 
require 'spec_helper'
require 'linote'

describe LINote do
	
	# -------------------------------------------------------------------
	# 	Classe
	# -------------------------------------------------------------------
  describe "La classe" do
		it "doit définir la constante ALTERS_PER_TUNE" do
		  defined?(LINote::ALTERS_PER_TUNE).should be_true
		end
		it "ALTERS_PER_TUNE doit contenir les bonnes valeurs" do
		  LINote::ALTERS_PER_TUNE['B'].should == {
				:nombre => 5, :suite => LINote::SUITE_DIESES, :add => 'is'
			}
		end
		it "doit définir la constante SUITE_DIESES" do
		  defined?(LINote::SUITE_DIESES).should be_true
		end
		it "SUITE_DIESES doit être valide" do
		  LINote::SUITE_DIESES.should == ['f', 'c', 'g', 'd', 'a', 'e', 'b']
		end
		it "doit définir la constante SUITE_BEMOLS" do
		  defined?(LINote::SUITE_BEMOLS).should be_true
		end
		it "SUITE_BEMOLS doit être valide" do
		  LINote::SUITE_BEMOLS.should == ['b', 'e', 'a', 'd', 'g', 'c', 'f']
		end
		it "doit définir la constante LISTE_ALT_TO_ALT_SIMPLE" do
		  defined?(LINote::LISTE_ALT_TO_ALT_SIMPLE).should be_true
		end
		it "LISTE_ALT_TO_ALT_SIMPLE doit définir les valeurs" do
			# On ne teste que quelques valeurs
		  LINote::LISTE_ALT_TO_ALT_SIMPLE["eeses"].should == "d"
			LINote::LISTE_ALT_TO_ALT_SIMPLE["fisis"].should == "g"
			LINote::LISTE_ALT_TO_ALT_SIMPLE["eisis"].should == "fis"
		end
		it "doit définir la constante GAMME_CHROMATIQUE" do
		  defined?(LINote::GAMME_CHROMATIQUE).should be_true
			LINote::GAMME_CHROMATIQUE.count.should == 12
			LINote::GAMME_CHROMATIQUE.should include 'cis'
		end
		it "doit définir la constante GAMME_CHROMATIQUE_BEMOLS" do
		  defined?(LINote::GAMME_CHROMATIQUE_BEMOLS).should be_true
			LINote::GAMME_CHROMATIQUE_BEMOLS.count.should == 12
			LINote::GAMME_CHROMATIQUE_BEMOLS.should include 'des'
		end
		it "doit définir la constante GAMME_DIATONIQUE" do
		  defined?(LINote::GAMME_DIATONIQUE).should be_true
			LINote::GAMME_DIATONIQUE.should include "g"
		end
    it "doit définir la constante NOTE_STR_TO_INT" do
      defined?(LINote::NOTE_STR_TO_INT).should be_true
    end
		it "NOTE_STR_TO_INT doit définir la correspondance" do
		  LINote::NOTE_STR_TO_INT["c"].should == 0
		end
		it "doit définir la constante NOTE_INT_TO_STR" do
		  defined?(LINote::NOTE_INT_TO_STR).should be_true
		end
		it "NOTE_INT_TO_STR doit définir la correspondance" do
		  LINote::NOTE_INT_TO_STR[4][:natural].should == "e"
		end
		it "doit définir la constante TONALITES" do
		  defined?(LINote::TONALITES).should be_true
		end
		it "TONALITES doit définir les tonalités" do
		  LINote::TONALITES['Bb'].should == {
				'fr' 			=> 'Si bémol majeur',
				'ton'			=> 'Bb',
				'bemols' 	=> 2,
				'dieses'	=> 0,
				"llp"			=>"bes"
		}
		end
		
		#  ALTERATIONS
		it "doit définir la constante ALTERATIONS" do
		  defined?(LINote::ALTERATIONS).should be_true
		end
		it "ALTERATIONS doit définir les bonnes valeurs" do
		  {'#' => 'is', '##' => 'isis', 'b' => 'es', 'bb' => 'eses'
			}.each do |str, str_llp|
				LINote::ALTERATIONS[str].should == str_llp
			end
		end
		
		# REG_ITAL_TO_LLP
		it "doit définir REG_ITAL_TO_LLP" do
		  defined?(LINote::REG_ITAL_TO_LLP).should be_true
		end
		
		# REG_NOTE_COMPLEXE
		it "doit définir REG_NOTE_COMPLEXE" do
		  defined?(LINote::REG_NOTE_COMPLEXE).should be_true
		end
		
		# REG_CHORD
		it "doit définir la constante REG_CHORD" do
		  defined?(LINote::REG_CHORD).should be_true
		end
		it "REG_CHORD doit permettre de repérer un accord" do
		 	res = "<a c e>".scan(/#{LINote::REG_CHORD}/)
			res.should_not be_empty
			res[0][0].should == "<a c e>"
			res = "ees c4 <aeses cis r> c c".scan(/#{LINote::REG_CHORD}/)
			res.should_not be_empty
			res[0][0].should == "<aeses cis r>"
			res = "c <d e f> <r a bes> c e".scan(/#{LINote::REG_CHORD}/)
			res.should_not be_nil
			res.should == [["<d e f>"], ["<r a bes>"]]
		end
		it "REG_CHORD ne doit pas se méprendre avec un crescendo" do
		  "<! c e a c e>".scan(/#{LINote::REG_CHORD}/).should be_empty
		end
		
		# :alterations_notes_in_key
		it "doit répondre à :alterations_notes_in_key" do
		  LINote.should respond_to :alterations_notes_in_key
		end
		it ":alterations_notes_in_key doit retourner le bon résultat" do
		  LINote::alterations_notes_in_key('C').should == {
				'c'=>'c', 'd'=>'d', 'e'=>'e', 'f'=>'f', 'g'=>'g', 'a'=>'a', 'b'=>'b'
			}
			LINote::alterations_notes_in_key('B').should == {
				'c'=>'cis', 'd'=>'dis', 'e'=>'e', 'f'=>'fis', 'g'=>'gis', 
				'a'=>'ais', 'b'=>'b'
			}
			LINote::alterations_notes_in_key('Db').should == {
				'c'=>'c', 'd'=>'des', 'e'=>'ees', 'f'=>'f', 'g'=>'ges', 'a'=>'aes',
				'b'=>'bes'
			}
			LINote::alterations_notes_in_key('Bb').should == {
				'c'=>'c', 'd'=>'d', 'e'=>'ees', 'f'=>'f', 'g'=>'g', 'a'=>'a', 
				'b'=>'bes'
			}
		end
		# :data_notes
		it "doit répondre à :explode" do
		  LINote.should respond_to :explode
		end
		# :implode
		it "doit répondre à :implode" do
		  LINote.should respond_to :implode
			# @note: la méthode est vérifiée ci-dessous
		end
		
		describe ":explode et :implode" do
			def compare_notes_et_data notes, data_comp
				liste_linotes = LINote::explode notes
				nombre_linotes = liste_linotes.count
				(0..nombre_linotes-1).each do |i_linote|
					linote 	= liste_linotes[i_linote]
					comp		= data_comp[i_linote]
					comp.each do |prop, val|
						prop_value = linote.instance_variable_get("@#{prop}")
						# if prop_value != val
						# 	puts "Comparaison Linote et données ne matche pas (sur la propriété #{prop}):"
						# 	puts "Suite : #{notes}"
						# 	puts "Note d'indice : #{i_linote}"
						# 	puts "Linote: #{linote.inspect}"
						# 	puts "Data comparées : #{comp.inspect}"
						# 	prop_value.should == val
						# end
					end
				end
				LINote::implode(liste_linotes).should == notes
			end
		
			liste_tests = []
			
			# Simple note
			notes = "c"
			comp = [
				{:note => "c", :pre => nil, :post => nil, :jeu => nil, :duration => nil, :alter => nil}]
			liste_tests << [notes, comp]
		
			# Simple silence
			notes = "r"
			comp = [
				{:note => "r", :pre => nil, :post => nil, :jeu => nil, :duration => nil, :alter => nil}]
		  liste_tests << [notes, comp]
			
			# Notes simples avec liaison
			notes = "c( disis e8. fes)"
			comp_str = <<-DEFA
				note	pre		post	jeu		duration		alter		duree_post
			--------------------------------------------------------
				c			-			(			-			-				-				-
				d			-			-			-			-				isis		-
				e			-			-			-			8.			-				-
				f			-			)			-			-				es			-
			--------------------------------------------------------
			DEFA
			comp = comp_str.to_array
			liste_tests << [notes, comp]
			
			# Notes et accords
			notes = "ces <a c'' eeses,,>8 e <gis bes>156. r4."
			dpo = "duree_post"
			ollp = "octave_llp"
			comp_str = <<-DEFA
				note	pre		post	jeu		duration		alter		#{dpo} #{ollp}
				--------------------------------------------------------			
				c			-			-			-			-		 		 		es			-				-
				a			<			-			-			-		 		 		-				-				-
				c			-			-			-			-		 		 		-				-				''
				e			-			>			-			-		 		 		eses		8				,,
				e			-			-			-			-		 		 		-				-				-
				g			<			-			-			-		 		 		is			-				-
				b			-			>			-			-		 		 		es			156.		-
				r 		-			-			-			4.	 		 		-				-				-
			--------------------------------------------------------			
			DEFA
			comp = comp_str.to_array
			liste_tests << [notes, comp]
		
			liste_tests.each do |donne|
				it "doivent fonctionner pour #{donne[0]}" do
					compare_notes_et_data donne[0], donne[1]
				end
			end
		end

		# :llp_to_linote
		# ---------------
		# @note : c'est la méthode principale de détection d'une note
		# lilypond, on s'en sert donc pour valider toutes les formes
		# acceptables par ruby2lily (cf. plus bas)
		it "doit répondre à :llp_to_linote" do
		  LINote.should respond_to :llp_to_linote
		end
		it ":llp_to_linote doit retourner une Linote d'après un string llp" do
		  res = LINote::llp_to_linote("a")
			res.class.should == LINote
		end
		olp = "octave_llp"
		d   = "delta/N"
		fi	= "finger"
		ary_bonnes_valeurs = <<-DEFH
				suite		note alter duree #{d} #{olp} jeu #{fi}
			-------------------------------------------------------------------
				a				a			-			-			0			-			-		-
				aes			a			es		-			0			-			-		-
				aeses		a			eses	-			0			-			-		-
				a'			a			-			-			1			'			-		-
				a,			a			-			-			-1		,			-		-
				aes''		a			es		-			2			''		-		-
				aisis,,	a			isis	-			-2		,,		-		-
				a8			a			-			8			0			-			-		-
				a8.			a			-			8.		0			-			-		-
				aes,8..	a			es		8..		-1		,			-		-				
				a~			a			-			~			0			-			-		-
				a-^			a			-			-			-			-			^		-
				a4-^-4	a			-			-			-			-			^		4
				a4.-.-4	a			-			4.		-			-			.		4
				c-.^		c			-			-			-			-			.^	-
				# La totale
				aes'4.~-^-5	a	es		4.~		1			'			^		5
			-------------------------------------------------------------------
		DEFH
		ary_bonnes_valeurs.to_array.each do |data_llp|
			suite = data_llp.delete(:suite)
			it "LINote::llp_to_linote('#{suite}') doit retourner : #{data_llp.inspect}" do
				linote = LINote::llp_to_linote(suite)
				linote.class.should == LINote
				[:note, :alter, :octave_llp, :jeu, :finger].each do |prop|
					iv_get(linote, prop).should == data_llp[prop]
				end
				linote.delta.should == data_llp[:delta]
			end
		end

		it ":llp_to_linote doit lever une erreur si mauvais argument" do
			err = detemp(Liby::ERRORS[:bad_type_for_args], :good => "String",
						:bad => "Hash", :method => "LINote::llp_to_linote")
		  expect{LINote::llp_to_linote({})}.to raise_error(SystemExit, err)
			motif = Motif::new "a c d"
			err = detemp(Liby::ERRORS[:bad_type_for_args], :good => "String",
						:bad => "Motif", :method => "LINote::llp_to_linote")
		  expect{LINote::llp_to_linote(motif)}.to raise_error(SystemExit, err)
			
		end
		["str", "t-^" "aa("].each do |bad_llp|
			it ":llp_to_linote doit lever une erreur avec « #{bad_llp} »" do
				err = detemp(Liby::ERRORS[:not_note_llp], :note => bad_llp)
		  	expect{LINote::llp_to_linote(bad_llp)}.to raise_error(SystemExit, err)
			end
		end
		
		
		
		# :to_llp
		it "doit répondre à :to_llp" do
		  LINote::should respond_to :to_llp
		end
		it ":to_llp doit renvoyer un string de notes LilyPond" do
		  {
				"c#" 						=> "cis",
				"c##"						=> "cisis",
				"db"						=> "des",
				"dbb"						=> "deses",
				"bb" 						=> "bes",
				"e# fb" 				=> "eis fes",
				"ges b#" 				=> "ges bis",
				"b# bbb bb cis" => "bis beses bes cis",
				"ré#" 					=> "dis",
				"reb"						=> "des",
				"cis bb fa# fais"	=> "cis bes fis fis",
				"c r d"					=> "c r d"
			}.each do |str, str_llp|
				LINote::to_llp(str).should == str_llp
			end
		end
		
		# :join
		it "doit répondre à :join" do
		  LINote.should respond_to :join
		end
		it ":join peut recevoir seulement des Motifs" do
			mo1 = Motif::new( :notes => "c e g", :octave => 2)
			mo2 = Motif::new( :notes => "g e c", :octave => 2)
			expect{LINote::join( h1, h2 )}.not_to raise_error(SystemExit)
			err = detemp(Liby::ERRORS[:bad_type_for_args], {
				:good => "Motif", :bad => "String", :method => "LINote::join"
			})
			expect{LINote::join("bad","mauvais")}.to raise_error(SystemExit,err)

			err = detemp(Liby::ERRORS[:bad_type_for_args], {
				:good => "Motif", :bad => "Hash", :method => "LINote::join" })
			h1 = {:notes => "c e g", :octave => 3 }
			h2 = {:notes => "c e g", :octave => 3 }
		  expect{LINote::join( h1, h2 )}.to raise_error(SystemExit, err)
		  
		end
		[
		# 	mot 1  oct  mot 2  oct résultat attendu
		# -------------------------------------------------------------------
			# Essai motifs simples
			["c e g", 3, "c e g", 3, "c e g c, e g"],
			["d f a", 3, "d f a", 3, "d f a d, f a"],
			["d f a", 3, "d f a", 4, "d f a d f a"],
			["d f a", 3, "d f a", 5, "d f a d' f a"],
			["d f a", 3, "d f a", 2, "d f a d,, f a"],
			
			# Essais motifs complexes
			["ces( ees ges) r", 3, "c e g", 3, "ces( ees ges) r c, e g"],
			["ces( ees ges) r", 3, "c e g", 4, "ces( ees ges) r c e g"],
			["ces( ees ges) r", 3, "c e g", 2, "ces( ees ges) r c,, e g"],
			["ces( ees ges) r", 3, "c e g", 1, "ces( ees ges) r c,,, e g"],
			
					# @todo: ICI, DANS LE TRAITEMENT, LE LEGATO NE DEVRAIT PAS
					# ÊTRE ENREGISTRÉ DANS LE TEXTE DU MOTIF. ÇA DEVRAIT ÊTRE PLUTÔT
					# UNE PROPRIÉTÉ @legato.
					# MAIS DANS CE CAS, QUE FAIRE ? LORSQU'ON JOIN, ON GARDE LE
					# LÉGATO SUR TOUT LE MOTIF, OU ON L'ÉCRIT ALORS DANS LE TEXTE ?
					# POUR LE MOMENT, J'OPTE POUR LE FAIT QUE LE LÉGATO DOIT ÊTRE
					# ÉCRIT EN DUR DANS LE @notes DU MOTIF
					
		].each do |data|
			notes1, oct_1, notes2, oct_2, expected = data
			mo1 = Motif::new(:notes => notes1, :octave => oct_1)
			mo2 = Motif::new(:notes => notes2, :octave => oct_2)
			result = expected
			mess = "::join avec Motif#«notes=#{notes1} octave=#{oct_1}» et " \
						<< "Motif#«notes=#{notes2} octave=#{oct_2}» doit produire #{expected}"
			it mess do
				res = LINote::join(mo1, mo2)
				unless res == expected
					# = débug =
					puts "\n\n### PROBLÈME DANS LINote::join :"
					puts "= Motif 1: #{mo1.inspect}"
					puts "= Motif 2: #{mo2.inspect}"
					puts "= Last note Motif 1: #{mo1.last_note.inspect}"
					puts "= First note Motif 2: #{mo2.first_note.inspect}"
					puts "= Notes attendues : #{expected}"
					puts "= Résultat obtenu: #{res.inspect}"
					# = / débug =
				end
				res.should == expected
				# On en profite pour vérifier aussi la méthode <motif>.join(<autre motif>)
				new_mo = mo1.join(mo2, :new => true)
				new_mo.notes.should 	== expected
				mo1.notes.should_not 	== expected
				mo1.join(mo2, :new => false)
				mo1.notes.should == expected
			end
		end
		
			
		# :octaves_from_llp
		it "doit répondre à :octaves_from_llp" do
		  LINote.should respond_to :octaves_from_llp
		end
		it ":octaves_from_llp doit renvoyer la bonne valeur" do
			LINote::octaves_from_llp("").should  == 0
			LINote::octaves_from_llp(nil).should == 0
		  LINote::octaves_from_llp("'").should == 1
			LINote::octaves_from_llp(",").should == -1
			LINote::octaves_from_llp("''").should == 2
			LINote::octaves_from_llp(",,").should == -2
			LINote::octaves_from_llp("''''''''").should == 8
			LINote::octaves_from_llp(",,,,,,,,").should == -8
		end
		
		# :octaves_to_delta
		it "doit répondre à :octaves_to_delta" do
		  LINote.should respond_to :octaves_to_delta
		end
		it ":octaves_to_delta doit retourner la bonne valeur" do
		  LINote::octaves_to_delta(3).should == "'''"
			LINote::octaves_to_delta(-3).should == ",,,"
			LINote::octaves_to_delta(0).should == ""
			LINote::octaves_to_delta(-4).should == ",,,,"
		end
		
		# :REG_NOTE
		it "doit définir REG_NOTE (motif pour trouver les notes)" do
		  defined?(LINote::REG_NOTE).should be_true
		end
		# :fixe_notes_length
		it "doit répondre à :fixe_notes_length" do
		  LINote.should respond_to :fixe_notes_length
		end
		it ":fixe_notes_length lève erreur durée si durée invalide" do
			err = Liby::ERRORS[:invalid_duree_notes]
		  expect{LINote::fixe_notes_length('a b c', -2)}.to \
				raise_error(SystemExit, err)
		  expect{LINote::fixe_notes_length('a b c', 2001)}.to \
				raise_error(SystemExit, err)
		end
		it ":fixe_notes_length lève erreur motif si motif invalide" do
			err = detemp(Liby::ERRORS[:invalid_motif], :bad => nil.inspect)
		  expect{LINote::fixe_notes_length(nil, 4)}.to \
				raise_error(SystemExit, err)

			mo = Motif::new "a a a"
			err = detemp(Liby::ERRORS[:invalid_motif], :bad => mo.inspect)
		  expect{LINote::fixe_notes_length(mo, 4)}.to \
				raise_error(SystemExit, err)
				
			err = detemp(Liby::ERRORS[:invalid_motif], :bad => 4)
		  expect{LINote::fixe_notes_length(4, 4)}.to \
				raise_error(SystemExit, err)
		end
		it ":fixe_notes_length avec durée nil renvoie le motif" do
		  mo = "a a a"
			LINote::fixe_notes_length(mo, nil).should == mo
		end
		it ":fixe_notes_length avec bons arguments renvoie la bonne valeur" do
		  mo = "a b c"
			LINote::fixe_notes_length(mo, 4).should == "a4 b c"
			LINote::fixe_notes_length(mo, "4.").should == "a4. b c"
			LINote::fixe_notes_length("a b c d8 r f", "8.").should == "a8. b c d8 r f"
			LINote::fixe_notes_length("ees c4", 2).should == "ees2 c4"
		end
		it ":fixe_notes_length renvoie la bonne valeur avec un premier accord" do
		  LINote::fixe_notes_length("<a c e>", 8).should_not == "<a8 c e>"
		  LINote::fixe_notes_length("<a c e>", 8).should == "<a c e>8"
		end
		
  end # / classe
	describe "Méthodes de classe" do
		# :pose_first_and_last_note
		it "doit répondre à :pose_first_and_last_note" do
		  LINote.should respond_to :pose_first_and_last_note
		end
		previous_suite = nil
		[
			["a b c d", 'IN', 'OUT', "aIN b c dOUT"],
			[nil, '(', ')', "a( b c d)"],
			[nil, '\(', '\)', "a\\( b c d\\)"],
			[nil, '\<', '\!', "a\\< b c d\\!"],
			["aeses,8-^ b c disis''-.", '(', ')', "aeses,8-^( b c disis''-.)"]
		].each do |d|
			suite, markin, markout, expected = d
			suite = previous_suite if suite.nil?
			it ":pose_first_and_last_note sur «#{suite}» avec «#{markin}» et «#{markout}»" do
				res = LINote::pose_first_and_last_note(suite, markin, markout)
				res.should == expected
			end
			previous_suite = suite
		end

		it "doit répondre à :note_str_in_context" do
		  LINote.should respond_to :note_str_in_context
		end
		it ":note_str_in_context doit renvoyer la bonne valeur" do
		  LINote::note_str_in_context(0).should == 'c'
			LINote::note_str_in_context(1, :tonalite => 'C').should == 'cis'
			LINote::note_str_in_context(1, :tonalite => 'F').should == 'des'
		end
	end # /méthodes de classe

	# -------------------------------------------------------------------
	# 	Instances
	# -------------------------------------------------------------------
	describe "<linote>" do
	  before(:each) do
	    @ln = LINote::new "c"
	  end

		# :abs / :to_midi
		it "doit répondre à :abs" do
		  ln = LINote::new "ces'"
			ln.should respond_to :abs
			ln.should respond_to :to_midi
		end
		[
			["c", 4, 60],
			["a", 4, 69],
			["a", 0, 21],
			["c", 8, 108],
			["ces", 4, 59],
			["bisis", 4, 73]
		].each do |d|
			notes, octave, expected = d
			it ":abs doit renvoyer #{expected} pour #{notes}:#{octave}" do
				ln = LINote::new notes, :octave => octave
				ln.abs.should == expected
		  end
		end
		# :au_dessus_de? / above?
		it "doit répondre à :au_dessus_de? / :above?" do
		  ln = LINote::new "ces'"
			ln.should respond_to :au_dessus_de?
			ln.should respond_to :above?
		end
		# :plus_haute_que? / :higher_than
		it "doit répondre à :plus_haute_que? / :higher_than" do
		  ln = LINote::new "ceses,"
			ln.should respond_to :plus_haute_que?
			ln.should respond_to :higher_than?
		end
		[
			["c", "c", false, false],
			["c", "d", false, false],
			["ces", "bis", true, false],
			["c", "bisis", true, false],
			["eis", "fes", false, true],
			["e", "feses", false, true],
			["c", "fis", false, false],
			["c", "a", true, false],
			["c", "g", true, false],
			["g", "c", false, true],
			["a", "c", false, true],
			["g", "c", false, true],
			["c", "ges", true, false],
			["c", "fis", false, false],
			["c'", "fis", false, true],
			["fis", "c", true, true],
			["fis", "c'", false, false]
		].each do |d|
			notes_ln1, notes_ln2, au_dessus, plus_haut = d
			texte = "#{notes_ln1}:au_dessus_de?(#{notes_ln2}) doit => #{au_dessus} et "
			texte << "#{notes_ln1}:higher_than?(#{notes_ln2}) doit => #{plus_haut}"
			it texte do
				ln1 = LINote::new notes_ln1
				ln2 = LINote::new notes_ln2
				ln1.au_dessus_de?(ln2).should === au_dessus
				res = ln1.higher_than?(ln2)
				if res != plus_haut
					puts "\nERREUR avec #{notes_ln1}:higher_than?(#{notes_ln2})"
					puts "Réponse attendue : #{plus_haut}"
					puts "Réponse reçue    : #{res}"
					puts "Valeur absolue de #{notes_ln1} : #{ln1.abs}"
					puts "Valeur absolue de #{notes_ln2} : #{ln2.abs}"
					puts "Détail linote 1 : #{ln1.inspect}"
					puts "Détail linote 2 : #{ln2.inspect}"
					res.should 	=== plus_haut
				end
			end
		end

		# :to_s
		# ATTENTION : ça n'est plus un alias de :to_llp
		it "doit répondre à :to_s" do
		  @ln.should respond_to :to_s
		end
		it ":to_s doit retourner la bonne valeur" do
		  ln = LINote::new "c"
			ln.to_s.should == "\\relative c { c }"
			ln = LINote::new :note => "c#", :octave => 1, :duree => "8", :jeu => "^"
			ln.to_s.should == "\\relative c,, { cis8-^ }"
		end

		# :with_alter
		it "doit répondre à :with_alter" do
		  @ln.should respond_to :with_alter
		end
		it ":with_alter doit renvoyer la bonne valeur" do
		  ln = LINote::new "eeses"
			ln.note.should == "e"
			ln.alter.should == "eses"
			ln.with_alter.should == "eeses"
			ln = LINote::new "c"
			ln.note.should == "c"
			ln.alter.should be_nil
			ln.with_alter.should == "c"
		end
		
		# :to_llp
		it "doit répondre à :to_llp)" do
		  @ln.should respond_to :to_s
		end
		dur = "duration"
		dup = "duree_post"
		olp = "octave_llp"
		dyn = "dynamique"
		data_test = <<-DEFH
			note			pre		post	#{dur} #{dup} #{olp} alter jeu finger #{dyn} res
		-------------------------------------------------------------------
			c					-			-			-			-				-			-			-			-			-			c
			c					-			(			4			-				'			es		-			-			-			ces'4(
			c					<     -			8			-				,,		isis	^		-			\\!		<cisis,,8-^\\!
		-------------------------------------------------------------------
		DEFH
		data_test = data_test.to_array
		data_test.each do |dlinote|
			res = dlinote.delete(:res)
			data_displayed = {}
			dlinote.each do |k, v| 
				next if v.nil? 
				data_displayed[k] = v 
			end
			it ":to_s avec {#{data_displayed.inspect}} doit rendre : '#{res}'" do
				linote = LINote::new dlinote
				linote.to_llp.should == res
			end
		end
		
		# :to_hash
		it "doit répondre à :to_hash" do
		  @ln.should respond_to :to_hash
		end
		it ":to_hash doit renvoyer la bonne valeur" do
			hash = {:note => "c", :duration => 4, :octave_llp => "''",
							:alter => "es" }
		  ln = LINote::new hash
		 	ln_to_hash = ln.to_hash
			hash.each { |prop, val| ln_to_hash[prop].should == val }
			ln = LINote::new "aisis''8"
			hash_ln = ln.to_hash
			hash_ln[:note].should == "a"
			hash_ln[:duration].should == "8"
			hash_ln[:alter].should == "isis"
			hash_ln[:octave_llp].should == "''"
			hash_ln[:octave].should == 5
		end
		
		# :as_note
		it "doit répondre à :as_note" do
		  @ln.should respond_to :as_note
		end
		it ":as_note doit retourner la linote en instance de Note" do
		  ln = LINote::new :note => "c", :alter => "es", :octave => 4
			note = ln.as_note
			note.class.should == Note
			note.it.should == "c"
		end
		# :to_llp
		it "doit répondre à :to_llp" do
		  @ln.should respond_to :to_llp
			# @note: la méthode est vérifiée ci-dessus, avec LINote::explode
			# @note: et elle est encore testée plus loin avec son alias
			# :to_s
		end
		
		# :set
		it "doit répondre à :set" do
		  @ln.should respond_to :set
		end
		it ":set doit permettre de définir les valeurs" do
			iv_get(@ln, :duration).should be_nil
		  @ln.set(:duration => 16)
			iv_get(@ln, :duration).should == "16"
			iv_get(@ln, :finger).should be_nil
			@ln.set(:finger => "5")
			iv_get(@ln, :finger).should == "5"
		end
		
		# :octave
		it "doit répondre à :octave" do
		  @ln.should respond_to :octave
		end
	  [
			["c", nil, "", 3],
			["c", 1, "", 1],
			["c", -2, "", -2],
			["c", nil, "'", 4],
			["c", nil, ",,", 1]
		].each do |d|
			note, octave, llp, octave_expected = d
			texte = ":octave de #{note} "
			texte << (octave.nil? ? "sans octave" : "d'octave #{octave}")
			texte << (llp == "" ? "" : " avec octave llp « #{llp} »")
			texte << " doit renvoyer #{octave_expected}"
			it texte do
				ln = LINote::new :note => note, :octave => octave, :octave_llp => llp
				ln.octave.should == octave_expected
			end
		end
		
		# :natural_octave_after
		it "doit répondre à :natural_octave_after" do
		  @ln.should respond_to :natural_octave_after
		end
		it ":natural_octave_after doit lever une erreur si le 1er param n'est pas une linote" do
			err = detemp(Liby::ERRORS[:param_method_linote_should_be_linote],
									:ln => @ln, :method => "natural_octave_after")
		  expect{@ln.natural_octave_after("a")}.to raise_error(SystemExit, err)
		end
		ary = <<-DEFA
			note1 o1/N		note2		expected/N
		---------------------------------------
			c			1				c				1
			c			2				c				2
			c			2				a				1
			c			5				fis			5
			fis		5				c				5
			fis		5				cisis		5
			g			5				c				6
			g			5				cisis		6
		---------------------------------------
		DEFA
		ary.to_array.each do |d|
			ln1 = LINote::new( d[:note1], :octave => d[:o1])
			ln2 = LINote::new( d[:note2], :octave => 0)
			octave_expected = d[:expected]
			message = "#{ln2.note}-#{ln2.octave}.natural_octave_after" \
								<< "(#{ln1.note}-#{ln1.octave}) doit retourner " \
								<< "#{octave_expected} comme octave naturel"
			it message do
			  ln2.natural_octave_after(ln1).should == octave_expected
			end
		end
		
		# :as_next_of
		it "doit répondre à :as_next_of" do
		  @ln.should respond_to :as_next_of
		end
		it ":as_next_of doit lever une erreur si le paramètre n'est pas une linote" do
			err = detemp(Liby::ERRORS[:param_method_linote_should_be_linote], 
										:ln => @ln, :method => "as_next_of")
		  expect{@ln.as_next_of('')}.to raise_error(SystemExit, err)
		end
		ary = <<-DEFA
				note1	o1/N		note2	o2/N	delta
			----------------------------------
					a			-				a		-				-
					a			1				a		0				,
					a			1				c 	0				,,
					a			1				c		1				,
					a			1				c		2				-
					f			1				c		1				-
					f			1				c		2				'
					f			2				c		1				,
					g			2				c		3				-
					g			2				c		5				''
			----------------------------------
		DEFA
		ary.to_array.each do |d|
			delta_expected = d[:delta] || ""
			ln1 = LINote::new(d[:note1], :octave => d[:o1])
			ln2 = LINote::new(d[:note2], :octave => d[:o2])
			d_str = delta_expected.blank? ? "rien" : "« #{delta_expected} »"
			texte = "#{d[:note2]}-#{d[:o2]}:as_next_of" \
							<< "(#{d[:note1]}-#{d[:o1]})" \
							<< " doit mettre le delta à #{d_str}"
			it texte do
				ln2.as_next_of ln1
				ln2.delta.should == delta_expected
		  end
		end
		# :rest?
		it "doit répondre à :rest?" do
		  @ln.should respond_to :rest?
		end
		it ":rest? doit renvoyer la bonne valeur" do
			@ln.should_not be_rest
			iv_set(@ln, :note => 'r')
			@ln.should be_rest
		end
		
		# :diese?
		it "doit répondre à :diese?" do
		  @ln.should respond_to :diese?
		end
		it ":diese doit retourner la bonne valeur" do
		  iv_set(@ln, :alter => nil)
			@ln.diese?.should be_false
		  iv_set(@ln, :alter => "es")
			@ln.diese?.should be_false
		  iv_set(@ln, :alter => "isis")
			@ln.diese?.should be_true
		  iv_set(@ln, :alter => "is")
			@ln.diese?.should be_true
		end
		# :bemol?
		it "doit répondre à :bemol?" do
		  @ln.should respond_to :bemol?
		end
		it ":bemol? doit retourner la bonne valeur" do
		  iv_set(@ln, :alter => nil)
			@ln.bemol?.should be_false
		  iv_set(@ln, :alter => "es")
			@ln.bemol?.should be_true
		  iv_set(@ln, :alter => "isis")
			@ln.bemol?.should be_false
		  iv_set(@ln, :alter => "eses")
			@ln.bemol?.should be_true
		end
		
		# :after?
		it "doit répondre à :after?" do
		  @ln.should respond_to :after?
		end
	  [
			["c", "c", true],
			["c", "d", true],
			["cis", "c", true], 		# cas spécial
			["ces", "bis", true]		# cas spécial
		].each do |d|
			suite1, suite2, expected = d
			it "#{suite1} :after? #{suite2} doit renvoyer #{expected}" do
				ln1 = LINote::new suite1
				ln2 = LINote::new suite2
				ln2.after?( ln1 ).should === expected
			end
		end
		
		# :index
		it "doit répondre à :index" do
		  @ln.should respond_to :index
		end
		it ":index doit renvoyer l'index dans la gamme chromatique" do
		  ln = LINote::new "c"
			ln.index.should == 0
			ln = LINote::new "d'"
			ln.index.should == 2
			ln = LINote::new "b,,4"
			ln.index.should == 11
			ln = LINote::new 'r'
			ln.index.should === nil
		end
		
		# :index_diat
		it "doit répondre à :index_diat" do
		  @ln.should respond_to :index_diat
		end
		[
			["c", 0], ["d", 1], ["e", 2], ["f", 3], ["g", 4], ["a", 5], ["b", 6]
		].each do |d|
			basenote, expected = d
			["", "es", "eses", "is", "isis"].each do |alter|
				note = "#{basenote}#{alter}"
				it ":index_diat pour #{note} doit renvoyer #{expected}" do
					ln = LINote::new note
					ln.index_diat.should == expected
				end
		  end
		end
		
		# :duration
		it "doit répondre à :duration" do
		  @ln.should respond_to :duration
		end
		it ":duration doit renvoyer la bonne valeur" do
		  motif = Motif::new "<a c e>8."
			ary_linotes = motif.explode
			ln = ary_linotes.last
			ln.duration.should == "8."
		end
		it ":duration doit retourner la durée d'une note d'accord" do
		  motif = Motif::new "<a c e>8."
			ary_linotes = motif.explode
			ln = ary_linotes[1]
			ln.duration.should be_nil
			ln.duration(true).should == "8."
		end
		
		# :duree_absolue
		it "doit répondre à duree_absolue" do
		  @ln.should respond_to :duree_absolue
		end
		{
			"1"  => 4.0, "2" => 2.0, "4" => 1.0, "8" => 0.5, "16" => 0.25,
			"32" => 0.125,
			"1." => 6.0, "2." => 3.0, "4." => 1.5, "8." => 0.75, "16." => 0.375,
			"1.." => 7.0, "2.." => 3.5, "4.." => 1.75
		}.each do |duree, expected|
			it "La durée absolue pour une durée LilyPond de '#{duree}' doit être #{expected}" do
			  ln = LINote::new "c", :duree => duree
				ln.duree_absolue.should == expected
			end
		end
		
		# :str_in_context
		it "doit répondre à :str_in_context" do
		  @ln.should respond_to :str_in_context
		end
		it ":str_in_context doit renvoyer la bonne valeur" do
			iv_set(@ln, :note_int => 3)
		  @ln.str_in_context(:tonalite => 'G').should 	== "dis"
		  @ln.str_in_context(:tonalite => 'Eb').should == "ees"
		end
		it "doit répondre à :moins" do
		  @ln.should respond_to :moins
		end
		it ":moins doit renvoyer la bonne valeur" do
			iv_set(@ln, :note_int => 0)
		  {
				1 => "b", 2 => "bes", 3 => "a", 4 => "aes",
				5 => "g", 6 => "fis", 7 => "f", 8 => "e",
				9 => "ees", 10 => "d", 11 => "cis", 12 => "c"
			}.each do |dt, ap|
				res = @ln.moins(dt)
				if res != ap
					debug "@ln.moins(#{dt}) aurait dû donner : #{ap}"
					res.should == ap
				end
			end
		end
		it "doit répondre à :plus" do
		  @ln.should respond_to :plus
		end
		it ":plus doit renvoyer la bonne valeur" do
		  {
				1 => "cis", 2 => "d", 3 => "ees", 4 => "e",
				5 => "f", 6 => "fis", 7 => "g", 8 => "aes",
				9 => "a", 10 => "bes", 11 => "b", 12 => "c"
			}.each do |dt, ap|
				res = @ln.plus(dt)
				if res != ap
					debug "@ln.plus(#{dt}) aurait dû donner : #{ap}"
					res.should == ap
				end
			end
		end
	end # / Instance
end