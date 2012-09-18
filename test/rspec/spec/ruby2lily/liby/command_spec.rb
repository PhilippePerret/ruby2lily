# 
# Tests de la sous-classe Liby::Command
# 
# qui joue les commandes voulues
# 
require 'fileutils'
require 'spec_helper'
require 'liby/command'

describe Liby::Command do
  
	# -------------------------------------------------------------------
	# 	Classe
	# -------------------------------------------------------------------
	describe "Classe" do
	  it "doit répondre à :run" do
	    Liby::Command.should respond_to :run
	  end
	end # / classe
	describe "Commande" do
	  it ":run_help doit exister" do
	    Liby::Command.should respond_to :run_help
	  end
		it ":run_help doit faire son travail" do
		  res = Liby::Command::run_help
			res.should =~ /Aide ruby2lily/
		end
	  it ":run_version doit exister" do
	    Liby::Command.should respond_to :run_version
	  end
		it ":run_version doit faire son travail" do
		  res = Liby::Command::run_version
				# @note: `res` n'existe ici que parce que la méthode renvoie
				# le texte pour les tests. Sinon, il écrit avec puts en console
			res.should =~ /version: /
			res.should =~ /author: /
			res.should =~ /github: /
		end
	end
	describe "Commande `new`" do
	  it "doit exister" do
	    Liby::Command.should respond_to :run_new
	  end
		it "doit créer une nouvelle configuration de partition" do
			score_name 	= "mon_score"
			score_title	= Liby::score_name_to_title score_name
			ARGV.clear
			ARGV << "new"
			ARGV << "mon_score"
			Liby::analyze_command_line
			cv_get(Liby, :command).should == "new"
			# On se place dans le dossier pour tester
			folder_test_creation = File.join(BASE_RUBY2LILY, 'test', 'creation')
			path_score = File.join(folder_test_creation, score_name, 'score.rb')
			path_dossier_scores = File.join(folder_test_creation, score_name, 'scores')
			
			# On vide et on recrée le dossier création
			FileUtils::rm_rf(folder_test_creation) if File.exists?(folder_test_creation)
			Dir.mkdir(folder_test_creation, 0777)
			File.exists?(path_score).should be_false
			# On se place dans ce dossier
      Dir.chdir(folder_test_creation)

			# --- On lance la création ---
		  res = Liby::Command::run_new
			res.should be_true
			File.exists?(path_score).should be_true
			File.exists?(path_dossier_scores).should be_true
			File.directory?(path_dossier_scores).should be_true
			code = File.read(path_score)
			code.should =~ /@title([ \t]+)= "#{score_title}"/
			code.should =~ /def orchestre/
			code.should =~ /def score/
		end
	end
	
end