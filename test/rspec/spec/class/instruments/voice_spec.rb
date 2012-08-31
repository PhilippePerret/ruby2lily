# 
# Tests de la class Voice < Instrument
# 
require 'spec_helper'
require 'instruments/voice'

describe Voice do
  # -------------------------------------------------------------------
	# Classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  it "doit répondre à :new" do
	    Voice.should respond_to :new
	  end
		it ":new doit renvoyer une voice" do
		  Voice.new.class.should == Voice
		end
	end # / La classe
	
	# -------------------------------------------------------------------
	# 	L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @voice = Voice::new
	  end
	end # / L'instance
end