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
		it "COMMAND_LIST doit exister" do
		  defined?(Liby::COMMAND_LIST).should be_true
		end
	end
	# -------------------------------------------------------------------
	# 	Liste des erreurs
	# -------------------------------------------------------------------
	describe "Liste des erreurs" do
		before(:all) do
		  @derrs = Liby::ERRORS
		end
		[
			:arg_path_file_ruby_needed,
			:arg_score_ruby_unfound,
			:orchestre_undefined,
			:path_lily_undefined,
			:lilyfile_does_not_exists
		].each do |cle_erreur|
			it "l'erreur :#{cle_erreur} doit exister" do
				Liby::ERRORS.should have_key cle_erreur
			end
		end
	end
	
	# -------------------------------------------------------------------
	# 	Traitement des erreurs
	# -------------------------------------------------------------------
	describe "Traitement des erreurs" do
	  it "Liby doit répondre à :error" do
	    Liby.should respond_to :error
	  end
		it ":error doit renvoyer la bonne valeur" do
			bad_path = "mon/path.rb"
		  err = Liby.error(:arg_score_ruby_unfound, :path => bad_path)
			err_formated = Liby::ERRORS[:arg_score_ruby_unfound]
			err_formated = err_formated.sub(/#\{path\}/, bad_path)
			err.strip.should == err_formated.strip
		end
		it "Liby doit répondre à :fatal_error" do
		  Liby.should respond_to :fatal_error
		end
		it ":fatal_error doit exiter le programme" do
			expect{Liby::fatal_error(:arg_score_ruby_unfound)}.to raise_error SystemExit
		end
	end
	
	# -------------------------------------------------------------------
	# 	Analyse des arguments
	# -------------------------------------------------------------------
	describe "Analyse des arguments" do
		def define_command_line_with_options
			path_score = 'partition_test.rb'
			ARGV.clear
			ARGV << path_score
			ARGV << "-fpng"
			ARGV << "--option voir"
		end
		before(:each) do
		  init_all_paths_liby
		end
		it "Liby doit répondre à :analyze_command_line" do
		  Liby.should respond_to :analyze_command_line
		end
		it ":analyze_command_line doit exiter avec des mauvais arguments" do
		  ARGV.clear
			path_score = "path/to/score/ruby.rb"
			ARGV << path_score
			expect{Liby.analyze_command_line}.to raise_error
			cv_get(Liby, :path_ruby_score).should be_nil
		end
		it ":analyze_command_line doit définir @@score_ruby si premier argument OK" do
			path_score = 'partition_test.rb'
			plily = File.expand_path(File.join(BASE_LILYPOND, path_score))
			ARGV.clear
			ARGV << path_score
			Liby.analyze_command_line
			cv_get(Liby, :path_ruby_score).should == plily
		end
		it ":analyze_command_line doit reconnaître une commande" do
			ARGV.clear
			ARGV << "generate" << "blank"
			Liby.analyze_command_line
			Liby.commande?.should be_true
		end
		
		it "doit répondre à :options_from_command_line" do
		  Liby.should respond_to :options_from_command_line
		end
		it ":options_from_command_line doit relever les options" do
			define_command_line_with_options
		  cv_set(Liby, :options => nil)
			Liby::options_from_command_line
			opts = cv_get(Liby, :options)
			opts.should_not be_nil
			opts.class.should == Array
			opts.should == ["-fpng", "--option voir"]
		end
	end
	
	# -------------------------------------------------------------------
	# 	Lilypondage ou commande
	# -------------------------------------------------------------------
	describe "Lilypondage ou commande" do
		def define_a_commande
		  ARGV.clear
			ARGV << "generate"
			ARGV << "blank"
		end
		def define_a_lilypondage
			path_score = 'partition_test.rb'
			plily = File.expand_path(File.join(BASE_LILYPOND, path_score))
			ARGV.clear
			ARGV << path_score
		end
		before(:each) do
			define_a_commande
		end
		it "doit répondre à :commande?" do
		  Liby.should respond_to :commande?
		end
	  it ":commande? doit rendre true si c'est une commande" do
			Liby.analyze_command_line
			Liby.commande?.should be_true
			define_a_lilypondage
			Liby.analyze_command_line
			Liby.commande?.should be_false
	  end
	end
	# -------------------------------------------------------------------
	# 	Traitement des notes données
	# 
	# 	Principe : les notes données par ruby ne sont pas les mêmes que
	# 	par lilypond, par exemple, le '#' peut être donné par ruby, mais
	# 	transformé en 'is' pour lilypond. Toutes ces méthodes s'occupent
	# 	de ces changements
	# -------------------------------------------------------------------
	describe "Méthodes de transformation des notes et signes" do
	  it "doit répondre à :notes_ruby_to_notes_lily" do
	    Liby.should respond_to :notes_ruby_to_notes_lily
	  end
		it ":notes_ruby_to_notes_lily doit renvoyer un bon résultat" do
			paires = {
				"a#" => "ais", "bb" => "bes", "c##" => "cisis", "dbb" => "deses"
			}
			paires.each do |cruby, clily|
				Liby.notes_ruby_to_notes_lily(cruby).should == clily
			end
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
			plily = File.expand_path(File.join(BASE_LILYPOND, 'partition_test.rb'))
			puser = File.expand_path(File.join('~', 'partition_test.rb'))
			File.unlink puser if File.exists? puser
			
		  Liby::find_path_score('bad_path').should be_nil
			Liby::find_path_score('partition_test.rb').should == plily

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
	  it "Liby doit répondre à :score_ruby_to_score_lilypond" do
	    Liby.should respond_to :score_ruby_to_score_lilypond
	  end
		it ":score_ruby_to_score_lilypond ne doit rien faire si c'est une commande" do
		  cv_set(Liby, :is_commande => true)
			Liby::score_ruby_to_score_lilypond.should be_nil
		end

		it "Liby doit répondre à :generate_pdf" do
		  Liby.should respond_to :generate_pdf
		end
		it ":generate_pdf doit produire le pdf" do
		  affixe_score = File.join(BASE_LILYPOND, 'test', 'score', 'simple')
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