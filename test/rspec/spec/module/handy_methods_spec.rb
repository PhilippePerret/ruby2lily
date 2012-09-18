# 
# Test des méthodes pratiques
# 
require 'spec_helper'
require File.join(BASE_RUBY2LILY, 'module', 'handy_methods.rb')


describe "Fonction :make_global_class_from_file" do
	before(:all) do
	  @path = File.join(BASE_RUBY2LILY, 'test', 'score', 
						'test_handy_methods', 'scores', 'jean_test_handy.rb')
		
	end
	it "doit exister" do
	  defined?(make_global_class_from_file).should be_true
	end
	it "doit lever une erreur si le path n'existe pas" do
	  expect{make_global_class_from_file("bad")}.to raise_error
	end
	it "doit utiliser le nom du fichier comme nom de classe" do
		defined?(JeanTestHandy).should_not be_true
	  make_global_class_from_file(@path)
		defined?(JeanTestHandy).should be_true
	end
	it "doit créer la classe voulue (tous les arguments fournies)" do
		make_global_class_from_file(@path, 'JeanTestedAsNewClassName', true)
		defined?(JeanTestedAsNewClassName).should be_true
	end
	it "doit créer des méthodes static (if required)" do
	  make_global_class_from_file(@path, 'JeanTestedAsStaticMethods')
		JeanTestedAsStaticMethods::intro.should == "a b c d"
		inst = JeanTestedAsStaticMethods::new
		inst.should_not respond_to :intro
	end
	it "doit créer des méthodes d'instance if required" do
	  make_global_class_from_file(@path, 'JeanTestedAsInstanceMethods', static=false)
		JeanTestedAsInstanceMethods.should_not respond_to :intro
		inst = JeanTestedAsInstanceMethods::new
		inst.should respond_to :intro
		inst.intro.should == "a b c d"
	end
end