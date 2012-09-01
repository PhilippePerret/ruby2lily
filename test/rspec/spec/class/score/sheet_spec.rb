# 
# Tests de la cLass Score::Sheet
# 
require 'spec_helper'
require 'score/sheet'

describe Score::Sheet do
	before(:all) do
	  @sh = Score::Sheet
	  SCORE 		= Score::new unless defined? SCORE
		ORCHESTRE = Orchestre::new unless defined? ORCHESTRE
		@orch_str = <<-EOO
				name		instrument	clef		ton
				CHANT		Voice				-				-
				PIANO		Piano				-				-
		EOO
		ORCHESTRE.compose @orch_str
	end
	
	# -------------------------------------------------------------------
	# 	Méthode principale de construction du score
	# -------------------------------------------------------------------
	describe "Construction du score" do
		before(:all) do
			SCORE = Score::new unless defined? SCORE
		  @path_score_ruby = Liby.send('find_path_score', 'partition_test')
			cv_set(Liby, :path_ruby_score => @path_score_ruby)
			@path_score_lily = Liby::path_lily_file
		end
		before(:each) do
			File.unlink @path_score_lily if File.exists? @path_score_lily
		end
		it "doit répondre à :build" do
		  @sh.should respond_to :build
		end
		it ":build doit créer le fichier" do
		  File.exists?(@path_score_lily).should be_false
			@sh.build
			File.exists?(@path_score_lily).should be_true
		end
		it ":build doit écrire un commentaire de départ pour info" do
		  @sh.build
			code = File.read(@path_score_lily)
			code.should start_with "%{\n"
			# Les autres informations d'entête sont testées ci-dessous
		end
		it ":build doit écrire le numéro de version Lilypond" do
		  @sh.build
			code = File.read(@path_score_lily)
			code.should =~ /\\version "/
		end
		it ":build doit écrire l'entête :header" do
		  @sh.build
			code = File.read(@path_score_lily)
			code.should =~ /\\header \{/
		end
		it ":build doit écrire la partition" do
		  @sh.build
			code = File.read(@path_score_lily)
			code.should =~ /% Score\n([^\{]*)\{/
		end
	end
	# -------------------------------------------------------------------
	# 	Méthodes renvoyant les informations du score
	# 	version, compositeur, etc.
	# -------------------------------------------------------------------
	describe "Méthodes pour le code du score Lilypond" do
		it "doit répondre à :entete" do
		  @sh.should respond_to :entete
		end
		it ":entete doit renvoyer le bon code" do
			cv_set(Liby, :path_ruby_score => "path/to/score_ruby.rb")
		  code = @sh.entete
			code.should start_with "%{"
			code.should end_with "%}"
			code.should =~ /ruby2lily/			# Nom de l'application
			code.should =~ /PhilippePerret/	# My name
			code.should =~ /https:\/\//			# Url vers le repository
			code.should =~ /Ruby score:/ # doit contenir le path original ruby
			code.should =~ /#{Liby::path_ruby_score}/
		end
	  it "doit répondre à :version" do
	    @sh.should respond_to :version
	  end
		it ":version doit renvoyer le bon code" do
			@sh.version.should == 
				"\\version \"#{@sh.lilypond_current_version}\""
		end
		it "doit répondre à :code_title" do
		  @sh.should respond_to :code_title
		end
		it ":code_title doit renvoyer un code valide" do
			SCORE.set(:title => "Mon titre")
		  @sh.code_title.should =~ /title = "Mon titre"/
		end
		it "doit répondre à :code_composer" do
		  @sh.should respond_to :code_composer
		end
		it ":code_composer doit retourner un code valide" do
		  @sh.code_composer.should be_nil
			SCORE.set(:composer => "J.S. Bach")
			@sh.code_composer.should == "composer = \"J.S. Bach\""
		end
		it "doit répondre à :code_opus" do
		  @sh.should respond_to :code_opus
		end
		it ":code_opus doit renvoyer un code valide" do
		  @sh.code_opus.should be_nil
			SCORE.set(:opus => "6")
			@sh.code_opus.should == "opus = \"Op. 6\""
		end
		it "doit répondre à :header" do
		  @sh.should respond_to :header
		end
		it ":header doit renvoyer un code valide" do
			data = {
				:title 				=> "Un titre pour voir",
				:composer 		=> "Jean-Sébastien Bach",
				:opus					=> nil
			}
			SCORE.set data
		  header = @sh.header
			header.should =~ /\\header \{/
			header.should =~ /title = \"#{data[:title]}\"/
			header.should =~ /composer = \"#{data[:composer]}\"/
			header.should_not =~ /opus/
		end
		it ":header ne doit pas contenir le titre si préférence contraire" do
			Score::PREFERENCES[:no_title] = true
		  header = @sh.header
			header.should_not =~ /title = \"/
		end
		it "doit répondre à :score" do
		  @sh.should respond_to :score
		end
		it ":score doit renvoyer un code valide" do
		  code = @sh.score
			code.should start_with "% Score\n"
			code.should end_with "}"
			# Les tests plus approfondis sont fait ailleurs
		end
	end
	
	# -------------------------------------------------------------------
	# 	Méthodes de description du score
	# -------------------------------------------------------------------
	describe "Score description" do
	  it "doit répondre à :lilypond_version" do
	    @sh.should respond_to :lilypond_current_version
	  end
		it ":lilypond_version doit retourner un numéro de version" do
		  version = @sh.lilypond_current_version
			version.gsub(/[0-9\.]/, '').should == ""
			# version.split('.').count.should == 3
		end
	end
	
end