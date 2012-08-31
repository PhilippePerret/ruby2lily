# 
# Tests généraux de ruby2lily
# 
require 'spec_helper'
require 'liby'

PATH_RUBY2LILY = File.join(BASE_LILYPOND, 'ruby2lily.rb')

describe "ruby2lily.rb" do
  it "doit exister" do
		File.exists?(PATH_RUBY2LILY).should be_true
  end
end

describe "La commande `ruby2lily'" do
	def error_sans_color err
		err[7..-5]
	end
	before(:all) do

	end
  it "doit exiter avec une erreur si absence du path du score" do
		cmd = PATH_RUBY2LILY
		err = Liby::ERRORS[:arg_path_file_ruby_needed].strip
		res = `#{cmd}`.strip
		error_sans_color(res).should == err
  end
	it "doit exiter avec une erreur si path incorrect" do
		bad_path = "mauvais/path.rb"
		cmd = PATH_RUBY2LILY + " '#{bad_path}'"
		err = Liby::error( :arg_score_ruby_unfound, :path => bad_path ).strip
		res = `#{cmd}`.strip
		error_sans_color(res).should == err
	end
	it "doit exister avec une erreur si l'orchestre n'est pas défini" do
	  path_bad_orch = 'test/score/orchestre_undefined'
		cmd = PATH_RUBY2LILY + " '#{path_bad_orch}'"
		
	end
	it "doit réussir avec une bonne ligne de commande et un bon score" do
	  good_score = 'partition_test.rb'
		cmd = PATH_RUBY2LILY + " '#{good_score}'"
		res = `#{cmd}`
		res.should === true
	end
end