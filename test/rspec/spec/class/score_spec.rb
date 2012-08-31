# 
# Tests de la classe Score (partition)
# 
require 'spec_helper'
require 'score'

describe Score do
  # -------------------------------------------------------------------
	# 	La classe
	# -------------------------------------------------------------------
	describe "La classe" do
		describe "Méthodes générales" do
		  it "doit répondre à :new" do
		    Score.should respond_to :new
		  end
			it ":new doit créer une nouvelle partition" do
			  Score::new.class.should == Score
			end
		end
		describe "Constantes" do
			before(:all) do
			  @defv = Score::DEFAULT_VALUES
			end
			it "doit définir ::DEFAULT_VALUES" do
			  defined?(Score::DEFAULT_VALUES).should be_true
			end
			it "DEFAULT_VALUES[:time] doit exister" do
				@defv.should have_key :time
			end
			it "DEFAULT_VALUES[:title] doit être défini" do
			  @defv.should have_key :title
			end
		end
	end
	
	# -------------------------------------------------------------------
	# L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @s = Score::new
	  end
	
		# -------------------------------------------------------------------
		# 	Méthodes de définition
		# -------------------------------------------------------------------
		describe "Méthodes de définition" do
		  it "doit répondre à :set" do
		    @s.should respond_to :set
		  end
			it ":set doit définir les données générales" do
				data = {
					:title => "Titre de la partition",
					:composer => "Le compositeur",
					:author		=> "L'auteur des paroles",
					:tune			=> G,
					:subtitle	=> nil
				}
			  @s.set data
				data.each do |k, val|
					iv_get(@s, k).should == val
				end
			end
			it ":set doit définir des valeurs par défaut" do
				iv_get(@s, :time).should be_nil
			  data = {
					:author => "me"
				}
				@s.set data
				iv_get(@s, :title).should == Score::DEFAULT_VALUES[:title]
				iv_get(@s, :time).should 	== Score::DEFAULT_VALUES[:time]
			end
		end
		# -------------------------------------------------------------------
		# Méthodes de path
		# -------------------------------------------------------------------
		describe "- Méthodes paths -" do
			def same_path_with_extension path, ext
				folder	= File.dirname(path)
				fichier	= File.basename(path, File.extname(path)) + ".#{ext}"
				File.join(folder, fichier)
			end
		  it "doit répondre à path_ruby_score" do
		    @s.should respond_to :path_ruby_score
		  end
			it ":path_ruby_score doit renvoyer la bonne valeur" do
			  @s.path_ruby_score.should be_nil
				p = File.expand_path('./partition_ruby.rb')
				iv_set(@s, :path_ruby_score => p)
				@s.path_ruby_score.should == p
			end
			it "doit répondre à :path_lily_file" do
			  @s.should respond_to :path_lily_file
			end
			it ":path_lily_file doit retourner la bonne valeur" do
			  @s.path_lily_file.should be_nil
				p = File.expand_path('./partition_ruby.rb')
				iv_set(@s, :path_ruby_score => p)
				@s.path_lily_file.should == same_path_with_extension(p, 'ly')
			end
			it "doit répondre à :path_pdf_file" do
			  @s.should respond_to :path_pdf_file
			end
			it ":path_pdf_file doit retourner le bon résultat" do
			  @s.path_pdf_file.should be_nil
				p = File.expand_path('./partition_ruby.rb')
				iv_set(@s, :path_ruby_score => p)
				@s.path_pdf_file.should == same_path_with_extension(p, 'pdf')
			end
		end
		# -------------------------------------------------------------------
		# Méthodes d'instance lilypond
		# -------------------------------------------------------------------
		describe "- Méthodes lilypond -" do
			it "doit répondre à :create_lilypond_file" do
			  @s.should respond_to :create_lilypond_file
			end
			it ":create_lilypond_file doit créer le fichier .ly" do

				# Créer un fichier score ruby virtuel
				path_test = File.join(BASE_LILYPOND, 'test', 'rspec', 'score_test.rb')
				File.unlink(path_test) if File.exists? path_test
				code = "# Partition ruby\n@orchestre = ''"
				File.open( path_test, 'wb'){ |f| f.write code }
				
				# Construction artificiel du fichier
				iv_set(@s, :path_ruby_score => path_test)
				path_file = @s.path_lily_file
				File.unlink path_file if File.exists? path_file
				File.exists?(path_file).should be_false
			  @s.create_lilypond_file
				File.exists?(path_file).should be_true
				File.unlink path_test 
				File.unlink path_file

			end
		  it "doit répondre à :to_ly" do
		    @s.should respond_to :to_ly
		  end
			it ":to_ly doit retourner un code .ly valide pour le score" do
				pending "à implémenter"
			end
			
			# @todo: Ici on pourrait faire des tests avec un dossier contenant
			# des exemples de score ruby, et leur équivalent attendu lilypond
			
		end # / méthodes lilypond
		
	end
end