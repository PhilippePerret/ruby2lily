# 
# Tests de la class Guitar < Instrument
# 
require 'spec_helper'
require 'instruments/guitar'

describe Guitar do
  # -------------------------------------------------------------------
	# Classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  it "doit répondre à :new" do
	    Guitar.should respond_to :new
	  end
		it ":new doit renvoyer une guitar" do
		  Guitar.new.class.should == Guitar
		end
	end # / La classe
	
	# -------------------------------------------------------------------
	# 	L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @guitar = Guitar::new
	  end
	end # / L'instance
end