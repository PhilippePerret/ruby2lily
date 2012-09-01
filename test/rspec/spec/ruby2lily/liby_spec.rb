# 
# Tests de la classe principale Liby
# 
require 'spec_helper'
require 'liby'

describe Liby do
	# @note: seule la classe est utilisée (singleton)
	
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
	end
	# -------------------------------------------------------------------
	# 	Liste des erreurs
	# -------------------------------------------------------------------
	describe "Liste des erreurs" do
		before(:all) do
		  @derrs = Liby::ERRORS
		end
	  it "L'erreur :arg_path_file_ruby_needed doit exister" do
	    @derrs.should have_key :arg_path_file_ruby_needed
	  end
		it "L'erreur :arg_score_ruby_unfound doit exister" do
	  	@derrs.should have_key :arg_score_ruby_unfound
		end
		it "L'erreur :orchestre_undefined doit exister" do
		  @derrs.should have_key :orchestre_undefined
		end
		it "L'erreur :path_lily_undefined doit exister" do
		  @derrs.should have_key :path_lily_undefined
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
			fichier	= File.basename(path, File.extname(path)) + ".#{ext}"
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
	
	end
	# -------------------------------------------------------------------
	# 	Analyse des arguments
	# -------------------------------------------------------------------
	describe "Analyse des arguments" do
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
	end
	
	# -------------------------------------------------------------------
	# 	Conversion du score ruby vers le score lilypond
	# -------------------------------------------------------------------
	describe "conversion score rb -> score ly" do
	  it "Liby doit répondre à :score_ruby_to_score_lilypond" do
	    Liby.should respond_to :score_ruby_to_score_lilypond
	  end

		it "Liby doit répondre à :end_conversion" do
		  Liby.should respond_to :end_conversion
		end
	end
	
end