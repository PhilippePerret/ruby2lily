# 
# Tests du module 'note_methods.rb'
# 
# 
# @note : ce module ne teste que les méthodes du module 'note_methods',
# la plupart des méthodes sur les notes sont traitées directement dans
# la class Note (spec/class/note_spec.rb)
# 
require 'spec_helper'
require File.join(BASE_LILYPOND, 'module', 'note_methods.rb')


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
				n.octave.should == 3
			end
		end
	end # / les notes
	
	
end