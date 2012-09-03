# 
# Tests de la class Orchestre
# 
require 'spec_helper'
require 'orchestre'

describe Orchestre do
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
	end
  # -------------------------------------------------------------------
	# La classe
	# -------------------------------------------------------------------
	describe "La classe" do
		before(:all) do
		  @errs = Orchestre::ERRORS
		end
		it "doit définir la constante ERRORS" do
		  defined?(Orchestre::ERRORS).should be_true
		end
		it "doit définir l'erreur ERRORS[:unknown_instrument]" do
		  @errs.should have_key :unknown_instrument
		end
		it "doit définir l'erreur ERRORS[:instrument_undefined]" do
		  @errs.should have_key :instrument_undefined
		end
		it "doit définir l'erreur ERRORS[:undefined_name]" do
		  @errs.should have_key :undefined_name
		end
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
		it ":compose doit lever une erreur si l'orchestre n'est pas défini" do
			expect{res = @o.compose(nil)}.to raise_error SystemExit
		end
		it ":compose doit lever une erreur s'il manque le nom (constante)" do
		  code = 	"name\tinstrument\tclef\tton\n" \
							<< "-\tPiano\tU4\tG"
			expect{res = @o.compose(code)}.to raise_error SystemExit
			# @todo: avec l'erreur : Orchestre::ERRORS[:undefined_name]
		end
		it ":compose doit lever une erreur si l'instrument n'est pas défini" do
			code = 	"name\tinstrument\tclef\tton\n" \
							<< "FAUX\t-\t-\t-"
			expect{res = @o.compose(code)}.to raise_error SystemExit
			# @todo: avec l'erreur : Orchestre::ERRORS[:instrument_undefined]
		end
		it ":compose doit lever une erreur si un instrument n'existe pas" do
			code = 	"name\tinstrument\tclef\tton\n" \
							<< "FAUX\tbadinstrument\t-\t-"
			expect{res = @o.compose(code)}.to raise_error SystemExit
		 	# @todo: avec l'erreur : Orchestre::ERRORS[:unknown_instrument]
		end
		it ":compose doit ajouter les instruments à la liste de l'orchestre" do
		  code = <<-EOC

		name		instrument		clef			ton
	-------------------------------------------------------------------
		STING		Voice					-					F
		JEAN		Piano					-					-

EOC
			@o.compose( code.strip )
			iv_get(@o, :instruments).should == [STING, JEAN]
		end
	end
	describe "L'instance" do
	  before(:each) do
	    @o = Orchestre::new
	  end
		it "doit répondre à :score" do
		  @o.should respond_to :to_lilypond
		end
		it ":to_lilypond doit renvoyer la partition au format lilypond" do
			iv_set(@o, :instruments => [])
		  score = @o.to_lilypond
			# Sans rien préciser d'autre, le code doit être vide
			score.should == ""
			# En donnant des informations, ça doit passer
			# @todo: vérifier les informations
		end
		it "doit répondre à :polyphonique?" do
		  @o.should respond_to :polyphonique?
		end
		it ":polyphonique? doit renvoyer la bonne valeur" do
		  iv_set(@o, :instruments => [1])
			@o.should_not be_polyphonique
			iv_set(@o, :instruments => [1,2,3])
			@o.should be_polyphonique
			iv_set(@o, :instruments => nil)
		end
	end
end