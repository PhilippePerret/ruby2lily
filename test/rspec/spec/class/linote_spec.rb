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
			mo1 = Motif::new( :motif => "c e g", :octave => 2)
			mo2 = Motif::new( :motif => "g e c", :octave => 2)
			expect{LINote::join( h1, h2 )}.not_to raise_error(SystemExit)

			err = detemp(Liby::ERRORS[:bad_type_for_args], {
										:good => "Motif", :bad => "String"
			})
			expect{LINote::join("bad", "mauvais")}.to \
				raise_error(SystemExit, err)

			err = detemp(Liby::ERRORS[:bad_type_for_args], {
										:good => "Motif", :bad => "Hash" })
			h1 = {:motif => "c e g", :octave => 3 }
			h2 = {:motif => "c e g", :octave => 3 }
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
					# ÉCRIT EN DUR DANS LE @motif DU MOTIF
					
		].each do |data|
			mo1 = Motif::new(:motif => data[0], :octave => data[1])
			mo2 = Motif::new(:motif => data[2], :octave => data[3])
			result = data[4]
			it "Avec les data #{data[0..3].join(', ')}, ::join doit produire #{data[4]}" do
				LINote::join(mo1, mo2).should == result
				# On en profite pour vérifier aussi la méthode <motif>.join(<autre motif>)
				new_mo = mo1.join(mo2, :new => true)
				new_mo.motif.should 	== result
				mo1.motif.should_not 	== result
				mo1.join(mo2, :new => false)
				mo1.motif.should == result
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
			err = detemp(Liby::ERRORS[:invalid_motif], :bad => nil)
		  expect{LINote::fixe_notes_length(nil, 4)}.to \
				raise_error(SystemExit, err)
			mo = Motif::new "a a a"
			err = detemp(Liby::ERRORS[:invalid_motif], :bad => mo.to_s)
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
			LINote::fixe_notes_length(mo, 4).should == "a4 b4 c4"
			LINote::fixe_notes_length(mo, "4.").should == "a4. b4. c4."
			mo = "ees c4"
			LINote::fixe_notes_length(mo, 2).should == "ees2 c2"
			# @todo: ICI, IL FAUDRA ESSAYER AVEC DES MOTIFS PLUS COMPLEXES
			pending "Essayer avec des motifs plus complexes"
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
	describe "L'instance" do
	  before(:each) do
	    @ln = LINote::new "c"
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