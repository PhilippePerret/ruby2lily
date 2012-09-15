# 
# Tests de la sous-classe Liby::LIScore
# 
# Note: cette sous-classe n'est pas à confondre avec la classe Score
# qui gère la partition en tant que chose abstraite. Ici, il s'agit
# vraiment de la partition, du fichier, qui sera produit pour Lilypond
#
require 'spec_helper'
require 'liby/liscore'

describe Liby::LIScore do
	
	# Avant toute chose
	before(:all) do
	  @lis = Liby::LIScore
		path = File.join('test', 'score', 'partition_test')
	  @path_score_ruby = Liby.send('find_path_score', path)
		cv_set(Liby, :path_ruby_score => @path_score_ruby)
		@path_score_lily = Liby::path_lily_file
		File.unlink @path_score_lily if File.exists? @path_score_lily
	end
	
	# Avant chaque cas
	before(:each) do
		init_all_paths_liby
		cv_set(Liby, :path_ruby_score => @path_score_ruby)
	end
	
  describe "- Méthodes générales -" do
	
		# :delete
		it "doit répondre à :delete" do
		  @lis.should respond_to :delete
		end
		it ":delete doit détruire le score lilypond s'il existe" do
		  @lis.create
			@lis.close
			File.exists?(@path_score_lily).should be_true
			@lis.delete
			File.exists?(@path_score_lily).should be_false
		end
		# :create
		it "doit répondre à :create" do
	    @lis.should respond_to :create
		end
		it ":create doit créer un fichier si toutes les données sont fournies" do
		  @lis.create.should === true
			@lis.close
		end
		it ":create doit lever une erreur s'il manque des informations" do
			init_all_paths_liby
		  expect{@lis.create}.to raise_error
		end
		
		# :close
		it "doit répondre à :close" do
		  @lis.should respond_to :close
		end
		it ":close doit fermer le fichier et mettre la variable à nil" do
			cv_get(Liby::LIScore, :reffile).should be_nil
			@lis.create
			cv_get(Liby::LIScore, :reffile).should_not be_nil
		  @lis.close
			cv_get(Liby::LIScore, :reffile).should be_nil
		end
		
		# :add
		it "doit répondre à :add et :write" do
		  @lis.should respond_to :add
			@lis.should respond_to :write
		end
		it ":add doit ajouter du code dans le fichier" do
			code_added = "Nouveau code"
		  @lis.write(code_added).should === true
			@lis.close
			code_file = File.read @path_score_lily
			code_file.should =~ /#{code_added}/
		end
  end
end