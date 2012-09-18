# 
# Sous-module pour test de Liby
# Analyse de la ligne de commande envoyée
# 
require 'spec_helper'
require 'liby'

describe "Liby - Ligne de commande" do
  before(:all) do
    SCORE = Score::new unless defined? SCORE
	  ORCHESTRE = Orchestre::new unless defined? ORCHESTRE
		path_score = File.join('test', 'score', 'partition_test.rb')
		@path_partition_test = 
			File.expand_path(File.join(BASE_LILYPOND, path_score))
  end
	# -------------------------------------------------------------------
	# 	Analyse des arguments (lignes de commande)
	# -------------------------------------------------------------------
	describe "Analyse des arguments" do
		before(:each) do
		  init_all_paths_liby
		end
		it "Liby doit répondre à :analyze_command_line" do
		  Liby.should respond_to :analyze_command_line
		end
		it ":analyze_command_line doit définir les valeurs" do
		  cv_set(Liby, :options => nil)
			cv_set(Liby, :parameters => nil)
			define_command_line "-fformat unparametre"
			expect{Liby.analyze_command_line}.to raise_error
				# car "unparametre n'est pas un score valide"
			cv_get(Liby, :options).should == {'format' => "format"}
			cv_get(Liby, :parameters).should == ["unparametre"]
		end
		it ":analyze_command_line doit définir @@score_ruby si premier argument OK" do
			init_argv_with @path_partition_test
			Liby.analyze_command_line
			cv_get(Liby, :path_ruby_score).should == @path_partition_test
		end
		
		# Définition des mesures à afficher
		it ":analyze_command_line doit répondre à l'option -m" do
			init_argv_with [@path_partition_test, "-m=10-20"]
			SCORE.from_mesure.should be_nil
			SCORE.to_mesure.should be_nil
			Liby.analyze_command_line
			cv_get(Liby, :path_ruby_score).should == @path_partition_test
			options = cv_get(Liby, :options)
			options.should have_key 'mesures'
			options['mesures'].should == "10-20"
		end
		it ":analyze_command_line doit répondre à l'option --mesures" do
			init_argv_with [@path_partition_test, "--mesures=15-25"]
			Liby.analyze_command_line
			cv_get(Liby, :path_ruby_score).should == @path_partition_test
			options = cv_get(Liby, :options)
			options.should have_key 'mesures'
			options['mesures'].should == "15-25"
		end
		it "la méthode :treat_option_mesures doit exister" do
		  Liby.should respond_to :treat_option_mesures
		end
		it ":analyze_command_line avec l'option --mesures doit définir les mesures" do
			init_argv_with [@path_partition_test, "--mesures=15-25"]
			Liby.analyze_command_line
			cv_get(Liby, :path_ruby_score).should == @path_partition_test
			SCORE.from_mesure.should 	== 15
			SCORE.to_mesure.should 		== 25
		end
		it ":analyze_command_line doit générer une erreur si -m ne définit pas de mesure" do
			init_argv_with [@path_partition_test, "--mesures"]
			err = Liby::ERRORS[:commandline_lack_mesures_definition]
			expect{Liby.analyze_command_line}.to raise_error(SystemExit, err)
		end
		it ":analyze_command_line doit lever une erreur si -m définit mal les mesures" do
			init_argv_with [@path_partition_test, "--mesures=bad"]
			err = Liby::ERRORS[:commandline_bad_mesures_definition]
			expect{Liby.analyze_command_line}.to raise_error(SystemExit, err)
		end
		it ":analyze_command_line doit accepter une seule valeur pour --mesures" do
			init_argv_with [@path_partition_test, "--mesures=2"]
			expect{Liby.analyze_command_line}.not_to raise_error
			SCORE.from_mesure.should === 2
			SCORE.to_mesure.should be_nil
		end
		it ":analyze_command_line doit accepter la 2nde valeur seule pour --mesures" do
			init_argv_with [@path_partition_test, "--mesures=-2"]
			expect{Liby.analyze_command_line}.not_to raise_error
			SCORE.from_mesure.should 	be_nil
			SCORE.to_mesure.should		=== 2
		end
		it ":analyze_command_line doit reconnaître une commande" do
			ARGV.clear
			ARGV << "new" << "blank"
			Liby.analyze_command_line
			Liby.command?.should be_true
			cv_get(Liby, :command).should_not == "blank"
			cv_get(Liby, :command).should == "new"
		end
		it "doit répondre à :treat_as_option" do
		  Liby.should respond_to :treat_as_option
		end
		it ":treat_as_option doit reconnaitre une vraie option" do
		  cv_set(Liby, :options => {})
			Liby::treat_as_option "-v"
			cv_get(Liby, :options).should == {} # car "option-commande"
			Liby::treat_as_option '-fpng'
			cv_get(Liby, :options).should == 
				{ 'format' => "png" }
		end
		it ":treat_as_option doit transformer en commande une option-commande" do
		  cv_set(Liby, :options => {}, :command => nil)
			Liby::treat_as_option '-v'
			cv_get(Liby, :command).should == "version"
			Liby.should be_command
		  cv_set(Liby, :options => {}, :command => nil)
			Liby::treat_as_option '--version'
			cv_get(Liby, :command).should == "version"
			Liby.should be_command
		end
		
		it ":treat_as_option doit lever une erreur si une option courte est inconnue" do
			err = detemp(Liby::ERRORS[:unknown_option], :option => '?')
		  expect{Liby::treat_as_option( '-?' )}.to \
				raise_error(SystemExit, err)
		end
		
		it "doit répondre à :treat_errors_command_line" do
		  Liby.should respond_to :treat_errors_command_line
		end
		
		it "doit répondre à parameters" do
		  Liby.should respond_to :parameters
		end
		it ":parameters doit renvoyer les paramètres" do
			cv_set(Liby, :parameters => nil)
		  Liby.parameters.should be_nil
			cv_set(Liby, :parameters => ["un", "deux"])
			Liby.parameters.should == ["un", "deux"]
		end
	end
	
end