# 
# Tests de la class Piano < Instrument
# 
require 'spec_helper'
require 'instruments/piano'

describe Piano do
  # -------------------------------------------------------------------
	# Classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  it "doit répondre à :new" do
	    Piano.should respond_to :new
	  end
		it ":new doit renvoyer un piano" do
		  Piano.new.class.should == Piano
		end
	end # / La classe
	
	# -------------------------------------------------------------------
	# 	L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @piano = Piano::new
	  end
	end # / L'instance
end