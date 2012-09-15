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
			path 	= File.join('test', 'score', 'partition_test.rb')
		  @path_score_ruby = Liby.send('find_path_score', path)
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
		def repond_a method
			@sh.should respond_to method
		end
		
		# :entete
		it "doit répondre à :entete" do repond_a :entete end
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
		
		# :version
	  it "doit répondre à :version" do repond_a :version end
		it ":version doit renvoyer le bon code" do
			@sh.version.should == 
				"\\version \"#{@sh.lilypond_current_version}\""
		end
		
		# :code_title
		it "doit répondre à :code_title" do repond_a :code_title end
		it ":code_title doit renvoyer un code valide" do
			SCORE.set(:title => "Mon titre")
		  @sh.code_title.should =~ /title = "Mon titre"/
		end
		
		# :code_composer
		it "doit répondre à :code_composer" do repond_a :code_composer end
		it ":code_composer doit retourner un code valide" do
		  @sh.code_composer.should be_nil
			SCORE.set(:composer => "J.S. Bach")
			@sh.code_composer.should == "composer = \"J.S. Bach\""
		end
		
		# :code_opus
		it "doit répondre à :code_opus" do repond_a :code_opus end
		it ":code_opus doit renvoyer un code valide" do
		  @sh.code_opus.should be_nil
			SCORE.set(:opus => "6")
			@sh.code_opus.should == "opus = \"Op. 6\""
		end
		
		# :code_meter
		it "doit répondre à :code_meter" do repond_a :code_meter end
		it ":code_meter doit renvoyer le bon code" do
			iv_set(SCORE, :meter => nil)
			@sh.code_meter.should be_nil
		  SCORE.set( :meter => "basse" )
			@sh.code_meter.should == "meter = \"basse\""
		end
		
		# :code_arranger
		it "doit répondre à :code_arranger" do repond_a :code_arranger end
		it ":code_arranger doit renvoyer le bon code" do
			desc = "Arrangement traditionnel"
			iv_set(SCORE, :arranger => nil)
			@sh.code_arranger.should be_nil
		  SCORE.set( :arranger => desc )
			@sh.code_arranger.should == "arranger = \"#{desc}\""
		end
		
		
		# :code_description
		it "doit répondre à :code_description" do repond_a :code_description end
		it ":code_description doit renvoyer le bon code" do
			desc = "Ceci est la description de la partition"
			iv_set(SCORE, :description => nil)
			@sh.code_description.should be_nil
		  SCORE.set( :description => desc )
			@sh.code_description.should == "description = \"#{desc}\""
		end
		
		# :header
		it "doit répondre à :header" do repond_a :header end
		it ":header doit renvoyer un code valide" do
			data = {
				:title 				=> "Un titre pour voir",
				:composer 		=> "Jean-Sébastien Bach",
				:arranger			=> "A. Cortot",
				:meter				=> "Violon",
				:opus					=> nil,
				:description	=> nil
			}
			SCORE.set data
		  header = @sh.header
			header.should =~ /\\header \{/
			header.should =~ /title = \"#{data[:title]}\"/
			header.should =~ /composer = \"#{data[:composer]}\"/
			header.should =~ /arranger = \"#{data[:arranger]}\"/
			header.should =~ /meter = \"#{data[:meter]}\"/
			header.should_not =~ /opus/
			header.should_not =~ /description =/
		end
		it ":header ne doit pas contenir le titre si préférence contraire" do
			Score::PREFERENCES[:no_title] = true
		  header = @sh.header
			header.should_not =~ /title = \"/
		end
		
		# :score
		it "doit répondre à :score" do repond_a :score end
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