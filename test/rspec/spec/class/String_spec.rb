=begin

	Tests de la classe String spécifique à ruby2lily

	@rappel
		Cette extension de la classe String est spécifique principalement 
		dans le sens où les + et les * n'agissent pas comme pour les
		string normaux, afin de facilité l'écriture :
			"a" + "c" + "e"
		au lieu de renvoyer "ace", va renvoyer "a c e "
		
=end
require 'spec_helper'
require 'String'

describe String do
	before(:each) do
	  @s = "c"
	end
	
	describe "<string>" do
	
		# :abs
		it "doit répondre à :abs" do
		  "str".should respond_to :abs
		end
		[
			["c", 60], ["c'", 72], ["ces", 59], ["cis", 61], ["cisis", 62],
			["b", 71], ["b,", 59],
			["d", 62], ["d,,", 38], ["d'", 74], ["dis", 63], ["des", 61]
		].each do |d|
			note, expected = d
			it ":abs de #{note} doit renvoyer #{expected}" do
				note.abs.should == expected
		  end
		end
		# :index_diat
		it "doit répondre à :index_diat" do
		  "str".should respond_to :index_diat
		end
		[
			["c", 0], ["d'", 1], ["e,,", 2], ["fes", 3], ["gisis", 4], ["a", 5], 
			["b", 6], ["mauvais", nil]
		].each do |d|
			note, expected = d
			it ":index_diat de #{note} doit retourner #{expected}" do
				note.index_diat.should == expected
		  end
		end
		
		# :rest?
		it "doit répondre à :rest?" do
		  'str'.should respond_to :rest?
		end
		it ":rest? doit retourner la bonne valeur" do
		  "str".should_not be_rest
			"r".should be_rest
			"r5".should be_rest
		end
		# :is_lilypond?
		it "doit répondre à :is_lilypond?" do
		  "str".should respond_to :is_lilypond?
		end
		[
			["c", true], ["ceses", true],
			["r", true], 
			["r8. ", true], [" <fisis a g>", true],
			["a-^", true], ["g( a-^)", true],
			["r8. <fisis a g> g( a-^)", true],
			# Non motif lilypond
			["x", false],
			["-^ 8. g", false]
			# @todo: ajouter les motifs complexes non traités
		].each do |d|
			suite, res = d
			it ":is_lilypond doit returner #{res} pour #{suite}" do
				suite.is_lilypond?.should == res
		  end
		end
		
		# :with_alter_in_key
		it "doit répondre à :with_alter_in_key" do
		  "str".should respond_to :with_alter_in_key
		end
		[
			["c", "C", "c"],
			["f", "C", "f"],
			["f", "D", "fis"],
			["e", "C", "e"],
			["e", "Bb", "ees"],
			["a", "C", "a"],
			["a", "B", "ais"],
			["a", "Eb", "aes"]
		].each do |d|
			note, key, expected = d
			it "#{note}.with_alter_in_key('#{key}') doit valoir #{expected}@" do
				note.with_alter_in_key(key).should == expected
		  end
		end
		# :note_with_alter
		it "doit répondre à :note_with_alter" do
		  "str".should respond_to :note_with_alter
		end
		[
			["c", "c"], ["des", "des"], ["eis", "eis"], ["feses", "feses"],
			["gisis", "gisis"],
			["c8", "c"], ["<dis16.-^", "dis"],
			["r", nil], ["str", nil]
		].each do |d|
			suite, res = d
			res_str = res.nil? ? "une erreur fatale" : res
			it ":note_with_alter pour « #{suite} » doit retourner #{res_str}" do
				unless res.nil?
			  	suite.note_with_alter.should == res
				else
					err = detemp(Liby::ERRORS[:not_note_llp], :note => suite)
					expect{suite.note_with_alter}.to raise_error(SystemExit, err)
				end
			end
		end
		# :distance_to_do
		it "doit répondre à :distance_to_do" do
		  "str".should respond_to :distance_to_do
		end
		[
			["c", 0, 12],
			["d", 2, 10],
			["fis", 6, 6]
		].each do |d|
			note, distance_down, distance_up = d
			it ":distance_to_do doit returner la bonne valeur" do
				note.distance_to_do.should == distance_up
				note.distance_to_do(en_montant=false).should == distance_down
			end
		end
		# :closest
		it "doit répondre à :closest" do
		  "str".should respond_to :closest
		end
		[																# Motif				octave			direction
																		# ----------------------------------
			["c", 	3,	"c", 		3, false],				# "c c" 				id.					"up"
			["c", 	3, 	"c,", 	2, false],				# "c c" 				id.					"up"
			["c", 	3, 	"d", 		3, true],				# "c d" 				id.					up
			["c", 	3, 	"fis",	3, true],			# "c fis"				id.					up
			["fis", 2, 	"c", 		2, false],		# "fis c"				id.					down
			["c", 	3, 	"g", 		2, false],			# "c g"					-1					down
			["c", 	3, 	"g''", 	4, true],
			["a", 	3, 	"d", 		4, true],				# "a r"					+ 1					up
			["g", 	2, 	"a", 		2, true],				# "g a"					id.					up
			["fis", 2, 	"b", 		2, true],			# "fis b"				id.					up
			["fis", 2, 	"b'", 	3, true],			# "fis b"				id.					up
			["fis", 2, 	"d", 		2, false],		# "fis d"				id.					down
			["b", 	1, 	"f", 		1, false],			# "b f"					id.					down
			["gis", 4, 	"d",		4, false],		# "gis r"				id.					down
			# Pièges
			["ces", 	1,	"c",			1, true],
			["c",			1,	"ces",		1, false],
			# pièges suprêmes
			["bis", 	0,	"c",			1, false],
			["bis", 	0,	"c,",			0, false],
			["bis", 	1,	"ces", 		2, false],
			["bisis", 1, 	"ces", 		2, false],
			["bis", 	1, 	"ceses",	2, false],
			["bisis",	1, 	"ceses", 	2, false],
			["eis",		1, 	"f",			1, false],
			["eis", 	1, 	"fes", 		1, false],
			["eisis", 1, 	"fes", 		1, false],
			["eis", 	2, 	"feses",	2, false],
			["eisis",	2, 	"feses",	2, false]
		].each do |d|
			note_self, octave_self, note, res, res_sup = d
			it "Test de :closest - \"#{note_self}(octave #{octave_self})\".closest(#{note}) doit renvoyer #{res}" do
				ln_closest = note_self.closest( note, octave_self )
				ln_self = LINote::new(:note => note_self, :octave => octave_self)
				ln_closest.with_alter.should	== note.gsub(/[',]/,'')
				ln_closest.octave.should 			== res
				# ln_closest.au_dessus_de?( ln_self ).should === res_sup
				ln_closest.higher_than?( ln_self ).should == res_sup
		  end
		end
		# :as_motif
	  it "doit répondre à :as_motif" do
	    "str".should respond_to :as_motif
	  end
		it ":as_motif doit renvoyer un bon motif (tests sans octave)" do
			mo = "c".as_motif
			mo.class.should == Motif
			mo.notes.should == "c"
			mo.octave.should == 4
			mo.duration.should be_nil
			
			mo = "ebb4".as_motif
			mo.class.should == Motif
			mo.notes.should == "eeses" # @fixme: devrait être comme ici, mais contient la durée
			mo.octave.should == 4
			mo.duration.should == "4"
			
			mo = "c4 e g c".as_motif
			mo.class.should 		== Motif
			mo.notes.should 		== "c e g c"
			mo.octave.should 		== 4
			mo.duration.should 	== "4"

			mo = "c4. e g8 c".as_motif
			mo.class.should == Motif
			mo.notes.should == "c e g8 c"
			mo.octave.should == 4
			mo.duration.should == "4."
		end
		it ":as_motif doit retourner un bon motif (avec octaves)" do
		  mo = "a'".as_motif
			mo.class.should == Motif
			mo.simple_notes.should == "a"
			mo.octave.should == 5
			
			mo = "c,,,".as_motif
			mo.class.should == Motif
			mo.simple_notes.should == "c"
			mo.octave.should == 1
			
			mo = "c,, d e'".as_motif
			mo.class.should == Motif
			mo.simple_notes.should == "c d e'"
			mo.octave.should == 2
			mo.duration.should be_nil
		end
		
		it ":as_motif doit retourner le bon motif (avec accord)" do
		  mo = "<c e g>".as_motif
			mo.class.should == Motif
			mo.notes.should == "<c e g>"
			mo.octave.should == 4
			mo.duration.should be_nil
		end
		
		it ":as_motif doit retourner le bon motif (avec silences)" do
		  mo = "r r c r".as_motif
			mo.class.should == Motif
			mo.notes.should == "r r c r"
			mo.octave.should == 4
			mo.duration.should be_nil
		end
		it ":as_motif doit retourner le bon motif (avec silences, octave et durée)" do
			mo = "r8 r c, r".as_motif
			mo.class.should == Motif
			mo.notes.should == "r r c, r"
			mo.octave.should == 4
			mo.duration.should == "8"
		end
		it ":as_motif doit accepter et traiter les paramètres" do
		  str = "a b c"
			mo  = str.as_motif(:octave => 0)
			mo.class.should == Motif
			mo.notes.should == "a b c"
			mo.octave.should == 0
			mo = str.as_motif(:octave => 1)
			mo.octave.should == 1
			mo = str.as_motif(:slured => true, :octave => 2, :clef => "f")
			mo.slured.should be_true
			mo.octave.should == 2
			mo.clef.should == "bass"
		end
	end

	# -------------------------------------------------------------------
	# 	Méthodes pratiques
	# -------------------------------------------------------------------
	describe "Méthodes pratiques - <string>" do
		
		# :explode / :to_linote
		it "doit répondre à :explode" do
		  "str".should respond_to :explode
			"str".should respond_to :to_linote
		end
		[
			["c", "c", nil, 0],
			["ces", "c", "es", 0],
			["bis'", "b", "is", 1],
			["deses,", "d", "eses", -1],
			["e'''", "e", nil, 3]
		].each do |d|
			note_llp, note, alter, delta = d
			it ":explode doit retourner la bonne valeur" do
				data = {:note => note, :alter => alter, :delta => delta }
			 	note_llp.explode(false).should == data
				ln = note_llp.to_linote
				ln.note.should 	== note
				ln.alter.should	== alter
				ln.delta.should == delta
			end
		end
		
		
		# :au_dessus_de? / above?
		it "doit répondre à :au_dessus_de?/:above" do
		  "str".should respond_to :au_dessus_de?
			"str".should respond_to :above?
		end
		# @note: testé avec ":en_dessous_de" ci-dessous
		[
			["d", "s"], ["e", "xx"]
		].each do |d|
			note, bad = d
			it ":au_dessus_de? doit lever une erreur avec «#{note}» et «#{bad}»" do
				err = detemp(Liby::ERRORS[:not_a_note], 
							:bad => bad, :method => "String#au_dessus_de?")
			  expect{bad.au_dessus_de?(note)}.to raise_error(SystemExit, err)
				err = detemp(Liby::ERRORS[:not_a_note], 
							:bad => bad, :method => "String#au_dessus_de?")
			  expect{note.au_dessus_de?(bad)}.to raise_error(SystemExit, err)
			end
		end
		
		# :plus_haute_que? /:higher_than?
		it "doit répondre à :plus_haute_que? et :higher_than?" do
		  "str".should respond_to :plus_haute_que?
			"str".should respond_to :higher_than?
		end
		# @note: testé ci-dessous

		[
			# self			note				1ère 				1ère			up+franchissement
			# 											au-dessus		+ haute
			# 											de 2e ?			que 2e
			# ---------------------------------------------------------------
			# Avec do
			["c", 			"c",					false,		false,		0 + 0],
			["c", 			"d",					false, 		false,		0 + 0],
			["d", 			"c", 					true, 		true,			1 + 0],
			["c", 			"e",					false,		false,		0 + 0],
			["e", 			"c",					true, 		true,			1 + 0],
			["c",				"f",					false,		false,		0 + 0],
			["f", 			"c",					true,			true,			1 + 0],
			["fis", 		"c", 					true, 		true,			1 + 0],
			["c", 			"fis", 				false, 		false,		0 + 0],
			["c",				"g",					true,			false,		1 + 2],
			["g",				"c",					false,		true,			0 + 2],
			["c",				"ges",				true,			false,		1 + 2],
			["ges",			"c",					false,		true,			0 + 2],
			["c",				"a",					true,			false, 		1 + 2],
			["a", 			"c",					false,		true,			0 + 2],
			["c",				"b",					true,			false,		1 + 2],
			["b",				"c",					false,		true,			0 + 2],
			["ces", 		"b", 					true, 		false,		1 + 2],
			["ceses", 	"b", 					true, 		false,		1 + 2],
			["ceses", 	"b", 					true, 		false,		1 + 2],
			# Avec fa
			["f",				"d",					true,			true,			1 + 0],
			["d",				"f",					false,		false,		0 + 0],
			["f", 			"e", 					true,			true,			1 + 0],
			["e",				"f", 					false, 		false,		0 + 0],
			["f", 			"f", 					false, 		false,		0 + 0],
			["fis",			"f",					false,		true,			0 + 0],
			["f",				"g",					false,		false,		0 + 0],
			["fis", 		"g", 					false,		false,		0 + 0],
			["fis", 		"ges",				false,		false,		0 + 0],
			["fisis",		"ges",				false,		true,			0 + 0],
			["fis",			"geses",			false,		true,			0 + 0],
			["g",				"f",					true,			true,			1 + 0],
			["f",				"a",					false,		false,		0 + 0],
			["a",				"f",					true,			true, 		1 + 0],
			["f",				"b",					false,		false,		0 + 0],
			["b",				"f",					true,			true,			1 + 0],
			["f",				"bis",				false,		false,		0 + 0],
			["bis", 		"f",					true,			true,			1 + 0],
			# fin
			["a", 			"b", 					false, 		false, 		0 + 0]
		].each do |d|
			n1, n2, expected, expect_higher, expected_franchiss = d
			mess = "'#{n1}':au_dessus_de?('#{n2}') doit retourner #{expected}"
			it mess do
				res = n1.au_dessus_de?(n2)
				if res != expected
					puts "\nERREUR avec #{message}"
					ln1 = LINote::new n1
					ln2 = LINote::new n2
					puts "Linote 1 obtenue : #{ln1.inspect}"
					puts "Linote 2 obtenue : #{ln2.inspect}"
					res.should === expected
				end
			end
			# Test avec renvoi de l'indication du franchissement d'octave
			mess = "'#{n1}':au_dessus_de?('#{n2}', franchissement=true) " \
						 << "doit retourner #{expected_franchiss}"
			it mess do
				res = n1.au_dessus_de?(n2, true)
				res.should == expected_franchiss
			end
			# Test de la méthode higher_than
			it "'#{n1}':higher_than?('#{n2}') doit retourner #{expect_higher}" do
				n1.higher_than?(n2).should	=== expect_higher
			end
		end
		
		# :after?
	  it "doit répondre à :after?" do
	    'str'.should respond_to :after?
	  end
		it ":after? doit renvoyer la bonne valeur" do
		  'a'.after?('g').should === true
			'c'.after?('d').should be_false
		end
		
	end
	# -------------------------------------------------------------------
	# 	Traitement de l'addition
	# -------------------------------------------------------------------
  describe "Addition (+)" do
		it "doit répondre à :+" do
	    @s.should respond_to :+
		end
		it ":+ doit renvoyer un motif en cas de bonne addition" do
		  res = ("c" + "d")
			res.class.should == Motif
		end
		# @note: 	Tous les autres traitements sont faits dans le fichier
		# 				spec/operation/addition_spec.rb
 end

	# -------------------------------------------------------------------
	# 	Traitement de la multiplication
	# -------------------------------------------------------------------
	describe "Multiplication (*)" do
		it "doit répondre à :*" do
		  @s.should respond_to :*
		end
		it ":* doit multiplier correctement une note seule" do
		  res = (@s * 3)
			res.class.should == Motif
			res.notes.should == "c c c"
		end
		it ":* doit multiplier correctement un groupe de notes" do
		  ("a b" * 2).to_s.should == "\\relative c' { a b a b }"
		end
	end

	# -------------------------------------------------------------------
	# 	Utilisation des crochets
	# -------------------------------------------------------------------
	describe "Traitement des crochets" do
	  it "doit répondre à :[]" do
	    "str".should respond_to :[]
	  end
		it "doit avoir le comportement par défaut si pas motif lilypond" do
	  	"string"[0..2].should == "str"
			"abracadabra"[0].should == 97
		end
		it ":[] doit pouvoir définir l'octave" do
		  res = "a"[5]
			res.class.should == Motif
			res.notes.should == "a"
			res.octave.should == 5
		end
		it ":[] doit pouvoir définir la durée" do
		  res = "a"["4."]
			res.class.should == Motif
			res.duration.should == "4."
			res.octave.should == 4
		end
	end
	# -------------------------------------------------------------------
	# 	Traitements complexe ('+' et '*' combinés)
	# -------------------------------------------------------------------
	describe "Traitements complexes" do
		it ":+ et * doivent retourner la bonne valeur" do
		  m = "c4" * 3 + "e g" + "c'" + "c" * 2
			m.class.should == Motif
			# puts "\n\nmotif: #{m.inspect}"
			m.to_llp.should == "c4 c c e g c c, c"
			# ---
			# puts "\n\n= Motif avant multiplication : #{m.inspect}"
			m = m * 2
			# puts "\n\n= Motif APRÈS multiplication : #{m.inspect}"
			m.class.should 	== Motif
			m.to_llp.should == "c4 c c e g c c, c c4 c4 c e g c c, c"
			m.to_s.should 	== "\\relative c' { c4 c c e g c c, c " \
												<< "c4 c4 c e g c c, c }"
		end
	end
	# -------------------------------------------------------------------
	# 	Méthode compensatrice
	# -------------------------------------------------------------------
	describe "Méthode compensant + et *" do
	  it "doit répondre à :fois" do
	    "string".should respond_to :fois
	  end
		it ":fois doit renvoyer la bonne valeur" do
		  "str".fois(4).should == "strstrstrstr"
		end
		it "doit répondre à :x" do
		  "str".should respond_to :x
		end
		it ":x doit retourner la bonne valeur" do
		  ("bon".x 2).should == "bonbon"
		end
		it "doit répondre à :plus" do
		  "string".should respond_to :plus
		end
		it ":plus doit retourner la bonne valeur" do
			s = "str"
		  s.plus("autre").should == "strautre"
			s.should == "str"
		end
		it "doit répondre à :add" do
		  "str".should respond_to :add
		end
		it ":add doit ajouter le string" do
		  s = "str"
			s.add("autre")
			s.should == "strautre"
		end
	end
end