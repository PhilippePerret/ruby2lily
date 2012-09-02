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
	  
	end # / classe
	
	# -------------------------------------------------------------------
	# 	Instance
	# -------------------------------------------------------------------
	describe "Instance" do
		before(:each) do
		  @cmd = Liby::Command::new "commande"
		end
	  it "doit répondre à :run" do
	    @cmd.should respond_to :run
	  end
	end # / instance
	
end