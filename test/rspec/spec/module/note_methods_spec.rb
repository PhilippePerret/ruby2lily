# 
# Tests du module 'note_methods.rb'
# 
# 
# @note : ce module ne teste que les méthodes du module 'note_methods',
# la plupart des méthodes sur les notes sont traitées directement dans
# la class Note (spec/class/note_spec.rb)
# 
require 'spec_helper'
require File.join(BASE_RUBY2LILY, 'module', 'note_methods.rb')


describe "Module/note_methods" do
	
	describe "- Les notes -" do
		%w(ut re mi fa sol la si).each do |note|
			it "doit définir la fonction #{note}()" do
			  defined?(note).should be_true
			end
			it "#{note}() doit retourner un élément de class Note" do
			  res = eval("#{note}()")
				res.class.should == Note
			end
			it "l'octave de #{note} doit être 3" do
			  n = eval("#{note}()")
				n.octave.should == 4
			end
		end
	end # / les notes
	describe "- Les durées -" do
	  {
			'ronde' 		=> "1", 	'whole' 					=> "1",
			'blanche'		=> "2", 	'half'						=> "2",
			'noire'			=> "4", 	"quarter"					=> "4",
			'croche'		=> "8", 	"quaver"					=> "8",
			'dbcroche'	=> "16",	"semiquaver"			=> "16",
			'tpcroche'	=> "32", 	"demisemiquaver"	=> "32",
			'qdcroche'	=> "64",
			'cqcroche'	=> "128"
		}.each do |duree, valeur|
			it "doit définir la fonction durée #{duree}()" do
				defined?(duree).should be_true
			end
			it "#{duree}() doit retourner la bonne valeur" do
				eval("#{duree}").should == valeur
			end
			it "#{duree}(true) doit retourner une durée pointée" do
			  eval("#{duree}(true)").should == "#{valeur}."
			end
		end
	end
	
	describe "- Opération sur les notes -" do
	  it "L'addition de notes doit créer un nouveau motif" do
	    (ut + re).class.should == Motif
	  end
	end
end