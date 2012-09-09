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
		# :dut
		it "doit répondre à :dut" do
		  "str".should respond_to :dut
		end
		[
			["str", nil], ["c", 0], ["cis", 1], ["d", 2],
			["fis", 6], ["bis", 0], ["b", 11], ["bes", 10]
		].each do |d|
			note, res = d
			it ":dut de #{note} doit être #{res}" do
				note.dut.should == res
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
			motif, res = d
			it ":note_with_alter pour « #{motif} » doit retourner #{res}" do
			  motif.note_with_alter.should == res
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
			["c", 	3,	"c", 		3, true],				# "c c" 				id.					"up"
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
			["bis", 	0,	"c",			1, true],
			["bis", 	0,	"c,",			0, false],
			["bis", 	1,	"ces", 		2, false],
			["bisis", 1, 	"ces", 		2, false],
			["bis", 	1, 	"ceses",	2, false],
			["bisis",	1, 	"ceses", 	2, false],
			["eis",		1, 	"f",			1, true],
			["eis", 	1, 	"fes", 		1, false],
			["eisis", 1, 	"fes", 		1, false],
			["eis", 	2, 	"feses",	2, false],
			["eisis",	2, 	"feses",	2, false]
		].each do |d|
			note_self, octave_self, note, res, res_sup = d
			it "Test de :closest - \"#{note_self}(octave #{octave_self})\".closest(#{note}) doit renvoyer #{res}" do
				note_self.closest( note, octave_self ).should == 
					{:note => note.gsub(/[',]/,''), :octave => res, :sup => res_sup}
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
			mo.octave.should == 3
			mo.duration.should be_nil
			
			mo = "ebb4".as_motif
			mo.class.should == Motif
			mo.notes.should == "eeses"
			mo.octave.should == 3
			mo.duration.should == "4"
			
			mo = "c4 e g c".as_motif
			mo.class.should 		== Motif
			mo.notes.should 		== "c e g c"
			mo.octave.should 		== 3
			mo.duration.should 	== "4"

			mo = "c4. e g8 c".as_motif
			mo.class.should == Motif
			mo.notes.should == "c e g8 c"
			mo.octave.should == 3
			mo.duration.should == "4."
		end
		it ":as_motif doit retourner un bon motif (avec octaves)" do
		  mo = "a'".as_motif
			mo.class.should == Motif
			mo.notes.should == "a"
			mo.octave.should == 4
			
			mo = "c,,,".as_motif
			mo.class.should == Motif
			mo.notes.should == "c"
			mo.octave.should == 0
		end
		
		it ":as_motif doit retourner le bon motif (avec accord)" do
		  mo = "<c e g>".as_motif
			mo.class.should == Motif
			mo.notes.should == "<c e g>"
			mo.octave.should == 3
			mo.duration.should be_nil
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
			# @note: des traitements plus complexes sont fait ailleurs
		end
		it ":+ doit ajouter le delta d'octave si nécessaire" do
		  mo = "c" + "fis"
			mo.notes.should == "c fis"
			mo = "c g'" + "c"
			mo.notes.should == "c g' c,"
		end
		# :+=
 		it ":+= doit retourner la bonne valeur (quand ce n'est pas un motif musical)" do
		  s = "str"
			s += "autre"
			s.should == "strautre"
		end
		
		# 
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
		  ("a b" * 2).to_s.should == "\\relative c''' { a b a b }"
		end
	end

	# -------------------------------------------------------------------
	# 	Traitements complexe ('+' et '*' combinés)
	# -------------------------------------------------------------------
	describe "Traitements complexes" do
		it ":+ et * doivent retourner la bonne valeur" do
		  m = "c4" * 3 + "e g" + "c'" + "c" * 2
			m.class.should == Motif
			m.notes.should == "c4 c4 c4 e g c c, c"
		 	m = m * 2
			puts "non motif après multiplication : #{m.inspect}" if m.class != Motif
			m.class.should == Motif
			m.to_s.should == "\\relative c''' { c4 c4 c4 e g c c, c " \
												<< "c4 c4 c4 e g c c, c }"
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