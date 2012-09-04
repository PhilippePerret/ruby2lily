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
	
	# -------------------------------------------------------------------
	# 	Traitement de l'addition
	# -------------------------------------------------------------------
  describe "Addition (+)" do
		it "doit répondre à :+" do
	    @s.should respond_to :+
		end
		
		# :+=
 		it ":+= doit retourner la bonne valeur" do
		  s = "str"
			s += "autre"
			s.should == "str autre"
		end
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
		  ("a b" * 2).should == "\\relative c''' { a b }" +
														"\\relative c''' { a b }"
														# note: ci-dessus, '+' ajoute une espace
		end
	end

	# -------------------------------------------------------------------
	# 	Traitements complexe (+ et * combinés)
	# -------------------------------------------------------------------
	describe "Traitements complexes" do
		it ":+ et * doivent retourner la bonne valeur" do
		  m = ("c4" * 3 + "e g" + "c" * 3)
			m.should == "c4 c4 c4 e g c c c"
		 	m = m * 2
			m.should == "\\relative c''' { c4 c4 c4 e g c c c }" + # noter que "+" ajoutera une espace
									"\\relative c''' { c4 c4 c4 e g c c c }"
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