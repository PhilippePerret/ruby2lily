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
		  code = "@orchestre = <<-DEFH\n" +
							"name\tinstrument\tclef\tton\n" +
							"-\tPiano\tU4\tG\n"
							"DEFH"
			expect{res = @o.compose(code)}.to raise_error SystemExit
			# @todo: avec l'erreur : Orchestre::ERRORS[:undefined_name]
		end
		it ":compose doit lever une erreur si l'instrument n'est pas défini" do
			code = 	"@orchestre = <<-DEFH\n" +
							"name\tinstrument\tclef\tton\n" +
							"FAUX\t-\t-\t-\nDEFH"
			expect{res = @o.compose(code)}.to raise_error SystemExit
			# @todo: avec l'erreur : Orchestre::ERRORS[:instrument_undefined]
		end
		it ":compose doit lever une erreur si un instrument n'existe pas" do
			code = 	"@orchestre = <<-DEFH\n" +
							"name\tinstrument\tclef\tton\n" +
							"FAUX\tbadinstrument\t-\t-\nDEFH"
			expect{res = @o.compose(code)}.to raise_error SystemExit
		 	# @todo: avec l'erreur : Orchestre::ERRORS[:unknown_instrument]
		end
	end
end