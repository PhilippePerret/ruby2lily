# 
# Tests de la class Bass < Instrument
# 
require 'spec_helper'
require 'instruments/bass'

describe Bass do
  # -------------------------------------------------------------------
	# Classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  it "doit répondre à :new" do
	    Bass.should respond_to :new
	  end
		it ":new doit renvoyer une bass" do
		  Bass.new.class.should == Bass
		end
	end # / La classe
	
	# -------------------------------------------------------------------
	# 	L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @bass = Bass::new
	  end
	end # / L'instance
end