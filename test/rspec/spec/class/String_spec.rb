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
		
		# :as_motif
	  it "d oit r épondre à :as_motif" do
	    "str".should respond_to :as_motif
	  end
		it ":as_motif doit lever une erreur si mauvais argument" do
			str = "str"
			err = detemp(Liby::ERRORS[:bad_argument_for_as_motif], :bad => str)
		  expect{str.as_motif}.to raise_error(SystemExit, err)
		end
		it ":as_motif doit renvoyer un bon motif" do
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
			mo.class.should == Motif
			mo.notes.should == "c e g c"
			mo.octave.should == 3
			mo.duration.should == "4"

			mo = "c4. e g8 c".as_motif
			mo.class.should == Motif
			mo.notes.should == "c e g8 c"
			mo.octave.should == 3
			mo.duration.should == "4."
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
		  (@s * 3).should == "c c c"
		end
		it ":* doit multiplier correctement un groupe de notes" do
		  ("a b" * 2).should == "\\relative c''' { a b } " \
														<< "\\relative c''' { a b }"
														# note: ci-dessus, '+' ajoute une espace
		end
	end

	# -------------------------------------------------------------------
	# 	Traitements complexe ('+' et '*' combinés)
	# -------------------------------------------------------------------
	describe "Traitements complexes" do
		it ":+ et * doivent retourner la bonne valeur" do
		  m = "c4" * 3 + "e g" + "c" * 3
			m.class.should == Motif
			m.notes.should == "c4 c4 c4 e g c c c"
		 	m = m * 2
			m.class.should == Motif
			m.to_s.should == "\\relative c''' { c4 c4 c4 e g c c c } " \
												<< "\\relative c''' { c4 c4 c4 e g c c c }"
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