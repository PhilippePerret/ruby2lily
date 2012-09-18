# 
# Tests de la classe principale Liby
# 
require 'spec_helper'
require 'liby'

describe Liby do
	# @note: seule la classe est utilisée (singleton)
		
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
	  ORCHESTRE = Orchestre::new unless defined? ORCHESTRE
		path_score = File.join('test', 'score', 'partition_test.rb')
		@path_partition_test = 
			File.expand_path(File.join(BASE_RUBY2LILY, path_score))
	end
	before(:each) do
	  cv_set(Liby, :options => nil)
		iv_set(SCORE, :from_mesure 						=> nil)
		iv_set(SCORE, :to_mesure 							=> nil)
		iv_set(SCORE, :displayed_instruments 	=> nil)
	end
	
	after(:all) do
	  cv_set(Liby, :options => nil)
		iv_set(SCORE, :from_mesure 						=> nil)
		iv_set(SCORE, :to_mesure 							=> nil)
		iv_set(SCORE, :displayed_instruments 	=> nil)	  
	end
	# -------------------------------------------------------------------
	# 	Constantes
	# -------------------------------------------------------------------
	describe "Constantes" do
	  it "ERRORS doit exister" do
	    defined?(Liby::ERRORS).should be_true
	  end
		it "USAGE doit exister" do
		  defined?(Liby::USAGE).should be_true
		end
		# it "COMMAND_LIST doit exister" do
		#   defined?(Liby::COMMAND_LIST).should be_true
		# end
		it "OPTION_LIST doit exister" do
		  defined?(Liby::OPTION_LIST).should be_true
		end
		it "OPTION_COMMAND_LIST doit exister" do
		  defined?(Liby::OPTION_COMMAND_LIST).should be_true
		end
	end
	
	# Tests des "options-commande" (i.e. les options qui sont transformées
	# en commandes dans l'analyse de la ligne de commande)
	describe "Option-commande" do
		def test_option_cmd opt
			Liby::OPTION_COMMAND_LIST.should have_key opt
		end
	  it "-v/--version doit être définie comme option-commande" do
	    test_option_cmd 'version'
	  end
		it "-h/--help doit être définie comme option-commande" do
		  test_option_cmd 'help'
		end
	end
	
	# Tests des options
	describe "Option" do
	  def test_option opt, valeur = nil
	  	Liby::OPTION_LIST.should have_key opt.to_s
			unless valeur.nil?
				Liby::OPTION_LIST[opt].should == valeur
			end
	  end
		def get_option opt
			Liby::OPTION_LIST[opt]
		end
		it "-v doit être définie et retourner 'version'" do
		  test_option 'v', 'version'
		end
		it "--version doit être définie" do
		  test_option 'version'
		end
		it "--version ne doit pas être une option lilypond" do
		  get_option('version')[:lily].should === false
		end
		it "-h doit être définie et retourner 'help'" do
		  test_option 'h', 'help'
		end
		it "--help doit être définie" do
		  test_option 'help'
		end
		it "--help ne doit pas être une option lilypond" do
		  get_option('help')[:lily].should === false
		end
		it "-f doit être définie et retourner 'format'" do
		  test_option 'f', 'format'
		end
		it "--format doit être définie" do
		  test_option 'format'
		end
		it "--format doit être une option lilypond" do
		  get_option('format')[:lily].should === true
		end
		it "-m doit être définie et retourner 'mesures'" do
		  test_option 'm', 'mesures'
		end
		it "--mesures doit être définie" do
		  test_option 'mesures'
		end
	end
	
	# La partie ligne de commande est testée dans :
	# 	liby/command_line_spec.rb
	
	# -------------------------------------------------------------------
	# 	Lilypondage ou commande
	# 
	# 	@note: la plupart des méthodes sont testées par :
	# 	spec/ruby2lily/liby/command_spec.rb
	# -------------------------------------------------------------------
	describe "Lilypondage ou commande" do
		def define_a_commande
		  ARGV.clear
			ARGV << "new"
			ARGV << "blank"
		end
		def define_a_lilypondage
			init_argv_with [@path_partition_test]
		end
		before(:each) do
			define_a_commande
		end
		it "doit répondre à :command?" do
		  Liby.should respond_to :command?
		end
	  it ":command? doit rendre true si c'est une commande" do
			Liby.analyze_command_line
			Liby.command?.should be_true
			define_a_lilypondage
			Liby.analyze_command_line
			Liby.command?.should be_false
	  end
		it "doit répondre à :run_command" do
		  Liby.should respond_to :run_command
			# @NOTE: Toutes les commandes sont testées par :
			# spec/ruby2lily/liby/command_spec.rb
		end
	end
	# -------------------------------------------------------------------
	# 	Méthodes path
	# -------------------------------------------------------------------
	describe "Méthodes path" do
	  it "Liby doit répondre à :find_path_score" do
	    Liby.should respond_to :find_path_score
	  end
		it ":find_path_score doit retourner la bonne valeur" do
			
			# Deux fichiers, un dans le dossier lilypond, l'autre à la racine 
			# du dossier de l'utilisateur
			path 	= File.join('test', 'score', 'partition_test.rb') 
			plily = File.expand_path(File.join(BASE_RUBY2LILY, path))
			puser = File.expand_path(File.join('~', 'partition_test.rb'))
			File.unlink puser if File.exists? puser
			
		  Liby::find_path_score('bad_path').should be_nil
			Liby::find_path_score(path).should == plily

			File.open(puser, 'wb'){ |f| f.write "# un faux code" }
			Liby::find_path_score('partition_test.rb').should == puser
			File.unlink puser
			
		end
		
		def same_path_with_extension path, ext
			folder	= File.dirname(path)
			ext = ".#{ext}" unless ext == ""
			fichier	= File.basename(path, File.extname(path)) << ext
			File.join(folder, fichier)
		end
		
		it "doit répondre à :path_folder_scores" do
		  Liby.should respond_to :path_folder_scores
		end
		it ":path_folder_scores doit retourner nil si le dossier 'scores' n'existe pas" do
			path_score = File.join(BASE_RUBY2LILY, 'test', 'score', 'essais.rb')
			cv_set(Liby, :path_ruby_score => path_score)
		  Liby::path_folder_scores.should be_nil
		end
		it ":path_folder_scores doit retourner le path s'il existe" do
			dossier 				= File.join(BASE_RUBY2LILY, 'test', 'score', 'with_dossier_scores')
			path_score 			= File.join(dossier, 'essai.rb')
			path_dir_scores = File.join(dossier, 'scores')
			cv_set(Liby, :path_ruby_score => path_score)
			Liby::path_folder_scores.should == path_dir_scores
		end
	  it "doit répondre à path_ruby_score" do
	    Liby.should respond_to :path_ruby_score
	  end
		it ":path_ruby_score doit renvoyer la bonne valeur" do
			init_all_paths_liby
		  Liby.path_ruby_score.should be_nil
			p = File.expand_path('./partition_ruby.rb')
			cv_set(Liby, :path_ruby_score => p)
			Liby.path_ruby_score.should == p
		end
		
		# :path_of_extension
		it "doit répondre à :path_of_extension (private)" do
		  # Liby.private_class_methods.should include "path_of_extension"
			# en attendant d'être en 1.9
			begin
				Liby.send("path_of_extension", "pdf")
			rescue Exception => e
				true.should be_false
			end
		end
		it ":path_of_extension doit retourner la bonne valeur (SANS option modificatrice de path)" do
			path_ini = File.join('path', 'to', 'monscore.rb')
			cv_set(Liby, :path_ruby_score => path_ini)
		  res = Liby.send("path_of_extension", 'rb')
			res.should == path_ini
		end
		it ":path_of_extension doit retourner la bonne valeur (AVEC option modificatrice de path)" do
		  cv_set(Liby, :path_ruby_score => File.join('path', 'to', 'mon_score.rb'))
			cv_set(Liby, :options => {'mesures' => "ffff"})
			iv_set(SCORE, :from_mesure => 2)
			res = Liby.send("path_of_extension", "ly")
			res.should == File.join('path', 'to', 'extraits', 'mon_score-m2-.ly')
		end
		
		# :path_per_options
		it "doit répondre à :path_per_options (private)" do
		  # Liby.private_class_methods.should include "path_per_options"
			# en attendant d'être en 1.9
			begin
				Liby.send("path_per_options")
			rescue Exception => e
				true.should be_false
			end
		end
		it ":path_per_options avec options mesures doit retourner la bonne valeur" do
			folder_ini = File.join('path', 'to')
			path_ini = File.join(folder_ini, 'mon_score')
		  cv_set(Liby, :path_ruby_score => "#{path_ini}.rb")
			res = Liby.send('path_per_options')
			res.should == path_ini
			cv_set(Liby, 	:options => {'mesures' => "ffff"})
			iv_set(SCORE, :from_mesure => 2)
			res = Liby.send('path_per_options')
			res.should == File.join(folder_ini, 'extraits', "mon_score-m2-")
			iv_set(SCORE, :from_mesure => nil)
			iv_set(SCORE, :to_mesure => 4)
			res = Liby.send('path_per_options')
			res.should == File.join(folder_ini, 'extraits', "mon_score-m-4")
			iv_set(SCORE, :from_mesure => 2)
			iv_set(SCORE, :to_mesure => 6)
			res = Liby.send('path_per_options')
			res.should == File.join(folder_ini, 'extraits', "mon_score-m2-6")
		end
		it ":path_per_options avec options instruments doit retourner le bon path" do
			path_ini = File.join('path', 'to', 'mon_score')
		  cv_set(Liby, 	:path_ruby_score => "#{path_ini}.rb")
			Liby.send('path_per_options').should == path_ini
			cv_set(Liby, 	:options => {'instruments' => "ffff"})
			path = File.join('path', 'to', 'extraits', 'mon_score-inst')
			Liby.send('path_per_options').should == path
			
		end
		# :path_lily_file
		it "doit répondre à :path_lily_file" do
		  Liby.should respond_to :path_lily_file
		end
		it ":path_lily_file doit retourner la bonne valeur" do
			init_all_paths_liby
		  Liby.path_lily_file.should be_nil
			p = File.expand_path('./partition_ruby.rb')
			cv_set(Liby, :path_ruby_score => p)
			Liby.path_lily_file.should == same_path_with_extension(p, 'ly')
		end
		it "doit répondre à :path_pdf_file" do
		  Liby.should respond_to :path_pdf_file
		end
		it ":path_pdf_file doit retourner le bon résultat" do
			init_all_paths_liby
		  Liby.path_pdf_file.should be_nil
			p = File.expand_path('./partition_ruby.rb')
			cv_set(Liby, :path_ruby_score => p)
			Liby.path_pdf_file.should == same_path_with_extension(p, 'pdf')
		end
		it "doit répondre à :path_affixe_file" do
		  Liby.should respond_to :path_affixe_file
		end
		it ":path_affixe_file doit renvoyer la bonne valeur" do
			init_all_paths_liby
		  Liby.path_affixe_file.should be_nil
			p = File.expand_path('./partition_ruby.rb')
			cv_set(Liby, :path_ruby_score => p)
			Liby.path_affixe_file.should == same_path_with_extension(p, "")
		end
		it "doit répondre à :path_folder_model" do
		  Liby.should respond_to :path_folder_model
		end
		it ":path_folder_model doit retourner la bonne valeur" do
		  Liby.path_folder_model.should == File.join(BASE_RUBY2LILY, 'data', 'model')
		end
	end
	
	# -------------------------------------------------------------------
	# 	Méthode de contrôle de type (class)
	# -------------------------------------------------------------------
	describe "contrôle de type/class" do
	  it "doit répondre à :raise_unless_motif" do
	    Liby.should respond_to :raise_unless_motif
	  end
		it ":raise_unless_motif doit passer si c'est un motif" do
			mot = Motif::new "a c e"
		  expect{Liby::raise_unless_motif("méthode", mot)}.not_to raise_error
		end
		it ":raise_unless_motif doit passer si plusieurs motifs" do
		  mot1 = Motif::new "a c e"
			mot2 = Motif::new "b d fis"
			expect{Liby::raise_unless_motif("méthode", mot1, mot2)}.not_to raise_error
		end
		it ":raise_unless_motif doit lever une erreur si pas motif" do
			err = detemp(Liby::ERRORS[:bad_type_for_args], 
				:good => "Motif", :bad => "String", :method => "méthode")
		  expect{Liby::raise_unless_motif("méthode", "str")}.to \
				raise_error(SystemExit, err)
		end
		it ":raise_unless_motif doit lever une erreur même si 1er est motif" do
			mot = Motif::new "a c e"
			err = detemp(Liby::ERRORS[:bad_type_for_args], 
				:good => "Motif", :bad => "String", :method => "méthode")
		  expect{Liby::raise_unless_motif("méthode", mot, "str")}.to \
				raise_error(SystemExit, err)
		end
		it ":doit répondre à :raise_unless_linote" do
		  Liby.should respond_to :raise_unless_linote
		end
		it ":raise_unless_linote doit lever une erreur si pas LINote" do
			ln1 = LINote::new "a"
			ln2 = LINote::new "b"
		  expect{Liby::raise_unless_linote("méthode", ln1, ln2)}.not_to raise_error
			err = detemp(Liby::ERRORS[:bad_type_for_args], 
				:good => "LINote", :bad => "String", :method => "méthode")
			expect{Liby::raise_unless_linote("méthode", "a", "b")}.to \
				raise_error(SystemExit, err)
			mot1 = Motif::new "a b c"
			mot2 = Motif::new "c d e"
			err = detemp(Liby::ERRORS[:bad_type_for_args], 
					:good => "LINote", :bad => "Motif", :method => "méthode")
			expect{Liby::raise_unless_linote("méthode", mot1, mot2)}.to \
				raise_error(SystemExit, err)
		end
	end
	# -------------------------------------------------------------------
	# 	Méthodes utilitaires
	# -------------------------------------------------------------------
	describe "Utilitaires" do
	  it "doit répondre à :score_name_to_title" do
	    Liby.should respond_to :score_name_to_title
	  end
		[
			["score", "Score"],
			["mon_score", "Mon Score"],
			["eT_uN_auTre", "Et Un Autre"]
		].each do |d|
			score_name, title = d
			it ":score_name_to_title doit renvoyer « #{title} » pour « #{score_name} »" do
				Liby::score_name_to_title(score_name).should == title
		  end
		end
	end
	# -------------------------------------------------------------------
	# 	Conversion du score ruby vers le score lilypond
	# -------------------------------------------------------------------
	describe "conversion score rb -> score ly" do
		before(:each) do
		  init_all_paths_liby
		end
		after(:each) do
		  File.unlink @path_pdf unless @path_pdf.nil? || !File.exists?(@path_pdf)
		end
		
		it "Liby doit répondre à :load_scores_files" do
		  Liby.should respond_to :load_scores_files
		end
		it "Liby::load_scores_files doit charger les fichiers scores (if any)" do
		  # Le test est fait dans ruby2lily_spec.rb
		end
	  it "Liby doit répondre à :score_ruby_to_score_lilypond" do
	    Liby.should respond_to :score_ruby_to_score_lilypond
	  end
		it ":score_ruby_to_score_lilypond ne doit rien faire si c'est une commande" do
		  cv_set(Liby, :command => 'generate')
			Liby::score_ruby_to_score_lilypond.should be_nil
		end

		it "Liby doit répondre à :generate_pdf" do
		  Liby.should respond_to :generate_pdf
		end
		it ":generate_pdf doit produire le pdf" do
		  affixe_score = File.join(BASE_RUBY2LILY, 'test', 'score', 'simple')
			cv_set(Liby, :path_ruby_score => "#{affixe_score}.rb" )
			cv_set(Liby, :path_lily_file 	=> "#{affixe_score}.ly")
			@path_pdf = Liby::path_pdf_file
			File.unlink @path_pdf if File.exists? @path_pdf
			File.exists?(@path_pdf).should be_false
			Liby::generate_pdf
			File.exists?(@path_pdf).should be_true
		end
		it "Liby doit répondre à :end_conversion" do
		  Liby.should respond_to :end_conversion
		end
	end
	
end