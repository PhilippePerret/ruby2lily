# 
# Tests de la class Orchestre
# 
require 'spec_helper'
require 'orchestre'

describe Orchestre do
  # -------------------------------------------------------------------
	# La classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  it "doit répondre à :new" do
	    Orchestre.should respond_to :new
	  end
	end
	# -------------------------------------------------------------------
	# 	Instance
	# -------------------------------------------------------------------
	describe "L'instance" do
		before(:each) do
		  @o = Orchestre::new
		end
	  it "doit répondre à :compose" do
	    @o.should respond_to :compose
	  end
	end
end