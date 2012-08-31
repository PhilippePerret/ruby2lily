# 
# Tests de la class Drums < Instrument
# 
require 'spec_helper'
require 'instruments/drums'

describe Drums do
  # -------------------------------------------------------------------
	# Classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  it "doit répondre à :new" do
	    Drums.should respond_to :new
	  end
		it ":new doit renvoyer une drums" do
		  Drums.new.class.should == Drums
		end
	end # / La classe
	
	# -------------------------------------------------------------------
	# 	L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @drums = Drums::new
	  end
	end # / L'instance
end