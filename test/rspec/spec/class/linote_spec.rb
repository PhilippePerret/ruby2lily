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
		it "d oit définir REG_NOTE_COMPLEXE" do
		  defined?(LINote::REG_NOTE_COMPLEXE).should be_true
		end
		
		# :data_notes
		it "d oit répondre à :explode" do
		  LINote.should respond_to :explode
		end
		# :implode
		it "d oit répondre à :implode" do
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
						if prop_value != val
							puts "Comparaison Linote et données ne matche pas (sur la propriété #{prop}):"
							puts "Suite : #{notes}"
							puts "Note d'indice : #{i_linote}"
							puts "Linote: #{linote.inspect}"
							puts "Data comparées : #{comp.inspect}"
							prop_value.should == val
						end
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
			notes = "ces <a c eeses>8 e <gis bes>156. r4."
			comp_str = <<-DEFA
				note	pre		post	jeu		duration		alter		duree_post
				--------------------------------------------------------			
				c			-			-			-			-				es			-
				a			<			-			-			-				-				-
				c			-			-			-			-				-				-
				e			-			>			-			-				eses		8
				e			-			-			-			-				-				-
				g			<			-			-			-				is			-
				b			-			>			-			-				es			156.
				r 		-			-			-			4.			-				-
			--------------------------------------------------------			
			DEFA
			comp = comp_str.to_array
			liste_tests << [notes, comp]
		
			liste_tests.each do |donne|
				it "d oivent fonctionner pour #{donne[0]}" do
					compare_notes_et_data donne[0], donne[1]
				end
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
		it "d oit r épondre à :join" do
		  LINote.should respond_to :join
		end
		it ":join peut r ecevoir seulement des Motifs" do
			mo1 = Motif::new( :notes => "c e g", :octave => 2)
			mo2 = Motif::new( :notes => "g e c", :octave => 2)
			expect{LINote::join( h1, h2 )}.not_to raise_error(SystemExit)

			err = detemp(Liby::ERRORS[:bad_type_for_args], {
										:good => "Motif", :bad => "String"
			})
			expect{LINote::join("bad", "mauvais")}.to \
				raise_error(SystemExit, err)

			err = detemp(Liby::ERRORS[:bad_type_for_args], {
										:good => "Motif", :bad => "Hash" })
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
			["ces( ees ges) r", 3, "c e g", 3, "ces( ees ges) r c e g"],
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
			mo1 = Motif::new(:notes => data[0], :octave => data[1])
			mo2 = Motif::new(:notes => data[2], :octave => data[3])
			result = data[4]
			it "Avec les data #{data[0..3].join(', ')}, ::join doit produire #{data[4]}" do
				LINote::join(mo1, mo2).should == result
				# On en profite pour vérifier aussi la méthode <motif>.join(<autre motif>)
				new_mo = mo1.join(mo2, :new => true)
				new_mo.notes.should 	== result
				mo1.notes.should_not 	== result
				mo1.join(mo2, :new => false)
				mo1.notes.should == result
			end
		end
		
		# :mark_relative
		it "doit répondre à :mark_relative" do
		  LINote::should respond_to :mark_relative
		end
		it ":mark_relative doit retourner la bonne valeur" do
		  LINote::mark_relative(3).should == "\\relative c'''"
			LINote::mark_relative(-2).should == "\\relative c,,"
		end
		
		# :octave_as_llp
		it "doit répondre à :octave_as_llp" do
		  LINote.should respond_to :octave_as_llp
		end
		it ":octave_as_llp doit renvoyer une bonne valeur pour octave < 0" do
		  LINote.octave_as_llp( -6 ).should eq ",,,,,,"
		end
		it ":octave_as_llp doit renvoyer une bonne valeur pour octave > 0" do
		  LINote.octave_as_llp(4).should eq "''''"
		end
		it ":octave_as_llp doit renvoyer un string vide pour octave 0" do
		  LINote::octave_as_llp(0).should eq ""
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
		# :mark_octave
		it "doit répondre à :mark_octave" do
		  LINote.should respond_to :mark_octave
		end
		it ":mark_octave doit renvoyer 'c' quand octave nulle" do
		  LINote::mark_octave(0).should == "c"
		end
		it ":mark_octave doit renvoyer bonne valeur quand octave négative" do
		  LINote::mark_octave(-9).should == "c,,,,,,,,,"
		end
		it ":mark_octave doit renvoyer un apostrophe quand octave > 0" do
		  LINote::mark_octave(1).should == "c'"
			LINote::mark_octave(3).should == "c'''"
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
			mo = "a b c d8 r f"
			LINote::fixe_notes_length(mo, "8.").should == "a8. b c d8 r f"
			mo = "ees c4"
			LINote::fixe_notes_length(mo, 2).should == "ees2 c4"
		end
		
  end # / classe
	describe "Méthodes de classe" do
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

		# :to_llp
		it "doit répondre à :to_llp" do
		  @ln.should respond_to :to_llp
			# @note: la méthode est vérifiée ci-dessus, avec LINote::explode
		end
		
		it "doit répondre à :set" do
		  @ln.should respond_to :set
		end
		it ":set doit permettre de définir les valeurs" do
			iv_get(@ln, :duration).should be_nil
		  @ln.set(:duration => 16)
			iv_get(@ln, :duration).should == 16
			iv_get(@ln, :finger).should be_nil
			@ln.set(:finger => "5")
			iv_get(@ln, :finger).should == "5"
		end
		it "doit répondre à :rest?" do
		  @ln.should respond_to :rest?
		end
		it ":rest? doit renvoyer la bonne valeur" do
			@ln.should_not be_rest
			iv_set(@ln, :note => 'r')
			@ln.should be_rest
		end
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