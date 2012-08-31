# 
# Tests de la classe Instrument
# 
require 'spec_helper'
require 'instrument'

describe Instrument do
	
	# -------------------------------------------------------------------
	# Tests de la classe
	# -------------------------------------------------------------------
  describe "La classe" do
    it "doit répondre à :new" do
      Instrument.should respond_to :new
    end
		it ":new doit retourner un objet de type Instrument" do
		  Instrument.new.class.should == Instrument
		end
  end # /la classe

	# -------------------------------------------------------------------
	# Tests de l'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @instru = Instrument::new( {} )
	  end
	
		# :accord / :accords
		it "doit répondre à :accord et :chord" do
		  @instru.should respond_to :accord
			@instru.should respond_to :chord
		end
		it ":accord doit renvoyer une instance de class Accord" do
		  @instru.accord.class.should == Chord
		end
		it "doit répondre à :accords et :chords" do
		  @instru.should respond_to :accords
			@instru.should respond_to :chords
		end
		
		# :mesure / :mesures
		it "doit répondre à :mesure et :measure" do
		  @instru.should respond_to :mesure
			@instru.should respond_to :measure
		end
		it ":mesure doit retourner une instance de classe Mesure" do
		  @instru.mesure.class.should == Measure
		end
		it "doit répondre à :mesures et :measures" do
		  @instru.should respond_to :mesures
		  @instru.should respond_to :measures
		end
		
		# :motif / :motifs
		it "doit répondre à :motif" do
		  @instru.should respond_to :motif
		end
		it ":motif doit retourner une instance de classe Motif" do
		  @instru.motif.class.should == Motif
		end
		it "doit répondre à :motifs" do
		  @instru.should respond_to :motifs
		end
	end # / L'instance
	
end