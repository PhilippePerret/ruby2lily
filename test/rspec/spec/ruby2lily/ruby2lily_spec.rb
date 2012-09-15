# 
# Tests généraux de ruby2lily
# 
require 'spec_helper'
require 'liby'

PATH_RUBY2LILY = File.join(BASE_LILYPOND, 'ruby2lily.rb')

describe "L'application" do
	before(:all) do
	  @path_version = File.join(BASE_LILYPOND, 'VERSION.rb')
	  @path_help 		= File.join(BASE_LILYPOND, 'HELP.md')
	end
  it "doit contenir un fichier VERSION" do
    File.exists?(@path_version).should be_true
  end
	it "VERSION doit contenir les bonnes informations" do
	  require @path_version
		defined?(RUBY2LILY_VERSION_NUM).should be_true
		defined?(RUBY2LILY_VERSION).should be_true
	end
	it "doit contenir un fichier HELP" do
    File.exists?(@path_help).should be_true
	end
	it "le fichier HELP doit contenir un texte assez long" do
	  File.read(@path_help).length.should be > 900
	end
end

describe "ruby2lily.rb" do
  it "doit exister" do
		File.exists?(PATH_RUBY2LILY).should be_true
  end
end

describe "La commande `ruby2lily' avec des erreurs" do
	def error_sans_color err
		err.strip[7..-5]
	end
	before(:all) do

	end
  it "doit exiter avec une erreur si absence de tout paramètre" do
		cmd = PATH_RUBY2LILY
		err = Liby::ERRORS[:command_line_empty]
		res = `#{cmd}`
		error_sans_color(res).should =~ /#{Regexp.escape(err)}/
  end
	it "doit exiter avec une erreur si path incorrect" do
		bad_path = "mauvais/path.rb"
		cmd = "#{PATH_RUBY2LILY} '#{bad_path}'"
		err = Liby::error( :arg_score_ruby_unfound, :path => bad_path ).strip
		res = `#{cmd}`.strip
		error_sans_color(res).should =~ /#{Regexp.escape(err)}/
	end
end

describe "La commande `ruby2lily' sans erreur" do
	after(:each) do
	  File.unlink @path_pdf unless @path_pdf.nil? || !File.exists?(@path_pdf)
	end
	
	# =>	Appel ruby2lily en ligne de commande
	# 		et place le résultat (donc tout le texte généré par le programme
	# 		avec les messages) dans @res
	def as_ligne_commande
		cmd = "#{PATH_RUBY2LILY} '#{@good_score}'"
		@res = `#{cmd}`
	end
	
	# => 	Simule l'appel en ligne de commande, mais charge en fait le
	# 		module, ce qui permet d'avoir toutes les valeurs définies
	# 
	# @param	argv		Les arguments, soit sous forme de Array soit sous
	# 								forme de String, comme dans la ligne de commande
	def simule_ligne_commande argv = nil
		# On simule l'appel du module avec un argument
		ARGV.clear
		if argv.nil?
			ARGV << @good_score
		else
			argv = argv.split(' ') if argv.class == String
			argv.each { |c| ARGV << c }
		end
		load File.join(BASE_LILYPOND, 'ruby2lily.rb')
	end

	before(:all) do
	  @good_score = File.join('test', 'score', 'partition_test.rb')
		@path_pdf		= File.join('test', 'score', 'partition_test.pdf')
	end
	
	describe "Appel en ligne de commande" do
	  before(:all) do
	    as_ligne_commande
	  end
		it "doit renvoyer un message de succès" do
			@res.should =~ /Fichier converti avec succès/	  
		end
	end
	describe "Simulation de l'appel en ligne de commande" do
	  before(:all) do
			simule_ligne_commande
	  end
		it "doit définir les musiciens de l'orchestre" do
			defined?(SALLY).should be_true
			Kernel::SALLY.class.should == Voice
			defined?(PIANO).should be_true
			PIANO.class.should == Piano
			defined?(BATTERIE).should be_true
			BATTERIE.class.should == Drums
			defined?(BASSE).should be_true
			BASSE.class.should == Bass
		end
	end
	
	describe "Commandes" do
	  it "doit répondre à la directive -v" do
	    # expect{`ruby2lily -v`}.not_to raise_error
			expect{simule_ligne_commande "-v"}.not_to raise_error
	  end
	end
	
	describe "Chargement des scores (du dossier 'scores')" do
		it "doit lever une erreur pour une classe existante" do
			path = File.join('test', 'score', 'with_bad_scores', 'essai.rb')
			err = detemp(Liby::ERRORS[:class_already_exists_for_score_class],
										:classe => "Piano")
	    expect{simule_ligne_commande(path)}.to raise_error(SystemExit, err)
		end
	  it "doit charger les partitions si un dossier scores existe" do
			path = File.join('test', 'score', 'with_dossier_scores', 'essai.rb')
	    expect{simule_ligne_commande path}.not_to raise_error
			defined?(JeanSolo).should be_true
			defined?(RingoStar).should be_true
	  end
	end
end