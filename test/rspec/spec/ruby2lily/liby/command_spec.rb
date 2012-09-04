# 
# Tests de la sous-classe Liby::Command
# 
# qui joue les commandes voulues
# 
require 'spec_helper'
require 'liby/command'

describe Liby::Command do
  
	# -------------------------------------------------------------------
	# 	Classe
	# -------------------------------------------------------------------
	describe "Classe" do
	  it "doit répondre à :run" do
	    Liby::Command.should respond_to :run
	  end
	end # / classe
	describe "Commande" do
	  it ":run_help doit exister" do
	    Liby::Command.should respond_to :run_help
	  end
		it ":run_help doit faire son travail" do
		  res = Liby::Command::run_help
			res.should =~ /Aide ruby2lily/
		end
	  it ":run_version doit exister" do
	    Liby::Command.should respond_to :run_version
	  end
		it ":run_version doit faire son travail" do
		  res = Liby::Command::run_version
				# @note: `res` n'existe ici que parce que la méthode renvoie
				# le texte pour les tests. Sinon, il écrit avec puts en console
			res.should =~ /version: /
			res.should =~ /author: /
			res.should =~ /github: /
		end
	end
	
end