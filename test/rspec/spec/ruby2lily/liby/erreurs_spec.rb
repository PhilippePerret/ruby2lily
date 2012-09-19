# 
# Tests de la classe principale Liby (partie "erreurs")
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
	# 	Liste des erreurs
	# -------------------------------------------------------------------
	describe "Liste des erreurs" do
		before(:all) do
		  @derrs = Liby::ERRORS
		end
		[
			:string_required,
			:command_line_empty,
			:unknown_option,
			:arg_path_file_ruby_needed,
			:arg_score_ruby_unfound,
			:orchestre_undefined,
			:path_lily_undefined,
			:lilyfile_does_not_exists,
			:class_already_exists_for_score_class,
			:bad_value_for_triolet,
			:bad_nombre_notes_for_triolet,
			:invalid_motif,
			:invalid_duree_notes,
			:cant_add_this,
			:cant_add_any_to_motif,
			:unable_to_find_first_note_motif,
			:unable_to_find_last_note_motif,
			:too_much_parameters_to_crochets,
			:bad_class_in_parameters_crochets,
			:bad_params_in_crochet,
			:bad_value_duree,
			:bad_type_for_args,
			:bad_args_for_join_linote,
			:motif_cant_be_surslured,
			:bad_args_for_chord,
			:type_ajout_unknown,
			:param_method_linote_should_be_linote,
			:bad_params_in_add_notes_instrument
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
		it ":analyze_command_line doit exiter avec des mauvais arguments" do
			badpath = "path/to/score/ruby.rb"
			define_command_line badpath
			err = detemp(Liby::ERRORS[:arg_score_ruby_unfound], :path => badpath)
			expect{Liby.analyze_command_line}.to raise_error(SystemExit, err)
			cv_get(Liby, :path_ruby_score).should be_nil
		end
		it ":treat_errors_command_line doit lever une erreur si mauvaise commande" do
		  # Aucun paramètres
			cv_set(Liby, :parameters => [])
			cv_set(Liby, :options => [])
			cv_set(Liby, :command => nil)
			expect{Liby::treat_errors_command_line}.to \
				raise_error( SystemExit, Liby::ERRORS[:command_line_empty])
		end
	end

end