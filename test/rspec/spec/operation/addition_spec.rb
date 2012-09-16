# 
# Pour tous les tests d'addition sur les :
# 	- String
# 	- Note
# 	- Motif
# 	- Accord
require 'spec_helper'
require 'noteclass'
require 'string'
require 'note'
require 'linote'
require 'motif'
require 'chord'

# -------------------------------------------------------------------
# 	Méthode générale NoteClass#+
# -------------------------------------------------------------------
describe "NoteClass#+" do
  it "doit exister" do
    NoteClass::new.should respond_to :+
  end
end
# -------------------------------------------------------------------
# 	String
# -------------------------------------------------------------------
describe "Addition à String" do

  describe "String + String" do
    it "doit retourner un Motif contenant les notes" do
      res = "a" + "b"
			res.class.should == Motif
			res.notes.should == "a b"
			res = "a" + "bb" + "dois" + "la#"
			res.class.should == Motif
			res.notes.should == "a bes cis, ais'"
			res = "a'" + "bb"
			res.class.should == Motif
			res.notes.should == "a bes,"
			res.octave.should == 4
    end
		it "avec un string entièrement en silence doit fonctionner" do
		  res = "c e g c" + "r1 r r r" + "e g"
		  # res = "c e g c" + "r1 r r r" + "e g#"
			res.class.should == Motif
			# res.notes.should == "c e g c r1 r r r e, gis"
			res.notes.should == "c e g c r1 r r r e, g"
		end
  end
	describe "String + Note" do
		it "doit retourner un motif contenant les notes" do
		  no = Note::new( "c" )
			res = "a" + no
			res.class.should == Motif
			res.to_s.should == "\\relative c { a c, }"
		end
	end
	describe "String + Motif" do
	  it "doit retourner un motif (simple) contenant les notes" do
	    mo = Motif::new("d")
			res = "c" + mo
			res.class.should == Motif
			res.to_s.should == "\\relative c { c d }"
	  end
		it "doit retourner un motif (semi-complexe) contenant les notes" do
		  mo = Motif::new(:notes => "d e4 f,", :duree => 8, :octave => 1)
			res = "c c," + mo
			res.class.should == Motif
			res.to_s.should == "\\relative c { c c, d,8 e4 f, }"
		end
		it "doit retourner un motif (complexe) contenant les notes" do
		  # @todo: implémenter le motif complexe (note : le faire partout)
			# (un motif complexe comprend toutes les marques possibles pour 
			# les notes, c'est-à-dire, ici, le jeu et le doigté, ainsi que
			# la dynamique)
		end
	end
	describe "String + Chord" do
		it "doit retourner un motif (simple) contenant les notes" do
		  acc = Chord.new ["c", "e", "g"]
		  res = "c" + acc
			res.class.should == Motif
			res.to_s.should == "\\relative c { c <c e g> }"
			res = "c e g c" + acc[6]
			res.to_s.should == "\\relative c { c e g c <c'' e g> }"
			res = "<c e g> c8" + acc["4", 3]
			res.to_s.should == "\\relative c { <c e g> c8 <c e g>4 }"
		end
	end
end

# -------------------------------------------------------------------
# 	Note
# -------------------------------------------------------------------
describe "Addition à Note" do
	
  describe "Note + String" do
		it "doit renvoyer un motif conforme" do
		  n = Note::new "c"
			res = (n + "a'")
			res.class.should == Motif
			res.to_s.should == "\\relative c { c a'' }"
		end
		it "autres tests Notes + String" do
			no = Note::new "c##"
			res = no + "<c d e> r g"
		  res.class.should == Motif
			res.to_s.should == "\\relative c { cisis <c d e> r g }"
		end
  end
	describe "Note + Note" do
	  it "doit renvoyer un motif" do
	    no1 = Note::new "c"
			no2 = Note::new "d"
			res = no1 + no2
			res.class.should == Motif
			res.notes.should == "c d"
			res.octave.should == 3
			res.duration.should be_nil
	  end
		it "+ Note doit produire un nouveau motif" do
		  nut = ut
			nre = re
			nmi = mi
			res = (nut + nre + nmi)
			res.class.should == Motif
			res.to_s.should == "\\relative c { c d e }"
		end
		it "avec différents octaves doit produire le bon résultat" do
		  nut = ut :octave => 1
			nre = re :octave => 2
			mo = nut + nre
			mo.class.should == Motif
			mo.to_s.should == "\\relative c,, { c d' }"
		end
		
	end
	describe "Note + Motif" do
		it "doit renvoyer un motif conforme" do
		  n = Note::new "c"
			m = Motif::new "e d"
			res = (n + m)
			res.class.should 				== Motif
			res.notes.class.should 	== String
			res.to_s.should == "\\relative c { c e d }"
		end
	end
	describe "Note + Chord" do
	  it "doit retourner un motif conforme" do
	    
			# Note simple
			no = Note::new "c"
			acc = Chord::new ["c e g"]
			(no + acc).to_s.should == "\\relative c { c <c e g> }"

			# Note altérée
			no = Note::new "c##"
			res = no + acc
			res.class.should == Motif
			res.to_s.should == "\\relative c { cisis <c e g> }"
			
			# Note altérée avec delta d'octave
			no = Note::new "c##,"
			(no + acc).to_s.should == "\\relative c, { cisis <c' e g> }"
			
	  end
	end
end

# -------------------------------------------------------------------
# 	Motif
# -------------------------------------------------------------------
def define_motifs
  @motif_simple 	= Motif::new("c e g")
	@motif_octave_2 = Motif::new(:notes => "c e g", :octave => 2)
	# Motif avec une octave différente à la fin qu'au début
	@mo_octave_diff = Motif::new(:notes => "a c e a")
	# Motif simple avec accord
	@mo_accord			= Motif::new(:notes => "<a c e>")
	# Motif avec accord et silence
	@mo_chord_et_rest = Motif::new(:notes => "r <b d fis> r g")
	# Motif avec liaison de jeu
	@mo_slur = Motif::new(:notes => "a( b c d) e( f g) r", :octave => -1)
	# Motif avec liaison de jeu en propriété (@todo)
	@mo_slured = Motif::new(:notes => "a b c d e", :slured => true)
	# Motif complexe
	@mo_complex = Motif::new(
		# :notes 	=> "r\\( <ais c e> geses8( b[ e4])\\) r2",
		:notes => "r\\( <ais c e> geses8( b[ e4])\\) r2",
		:octave => 2, :duration => "4"
		)
end
describe "Addition et Motif" do
	before(:all) do
	end
  describe "Motif + String" do
		define_motifs if @mo_slured.nil?
	  [
			[@motif_simple, "c", "c { c e g c, }"],
			[@motif_octave_2, "c", "c, { c e g c }"],
			[@mo_octave_diff, "c", "c { a c e a c,, }"],
			[@mo_accord, "a''", "c { <a c e> a'' }"],
			[@mo_chord_et_rest, "r r c,", "c { r <b d fis> r g r r c,, }"],
			[@mo_chord_et_rest, "r c,", "c { r <b d fis> r g r c,, }"],
			[@mo_chord_et_rest, "c,", "c { r <b d fis> r g c,, }"],
			[@mo_slur, "a'( b c)", "c,,,, { a( b c d) e( f g) r a''''( b c) }"],
			[@mo_slured, "<a c e>", "c { a( b c d e) <a, c e> }"],
			[@mo_complex, "cisis( ges ges4)", "c, { r4\\( <ais c e> geses8( b[ e4])\\) r2 cisis( ges ges4) }"]
		].each do |d|
			motif, str, res = d
			it "Motif « #{motif.notes} » (octave #{motif.octave}) + String « #{str} »" do
			 	new_mo = motif + str
				new_mo.class.should == Motif
				new_mo.object_id.should_not == motif.object_id
				new_mo.to_s.should == "\\relative #{res}"
			end
		end
  end
	describe "Motif + Note" do
		define_motifs if @mo_slured.nil?
		[
			[@motif_simple, "c", nil, "c { c e g c, }"],
			[@motif_simple, "c", 2, "c { c e g c,, }"],
			[@motif_simple, "c", 4, "c { c e g c }"],
			[@motif_simple, "c", 0, "c { c e g c,,,, }"],
			[@motif_octave_2, "c", nil, "c, { c e g c }"],
			[@motif_octave_2, "c", 4, "c, { c e g c' }"],
			[@mo_octave_diff, "c", nil, "c { a c e a c,, }"],
			[@mo_octave_diff, "c", 6, "c { a c e a c' }"],
			[@mo_accord, "c", nil, "c { <a c e> c, }"],
			[@mo_accord, "a", nil, "c { <a c e> a }"],
			[@mo_accord, "b", nil, "c { <a c e> b }"],
			[@mo_chord_et_rest, "c", nil, "c { r <b d fis> r g c, }"],
			[@mo_chord_et_rest, "b", nil, "c { r <b d fis> r g b }"],
			[@mo_chord_et_rest, "c", 5, "c { r <b d fis> r g c' }"],
			[@mo_slur, "c", nil, "c,,,, { a( b c d) e( f g) r c'' }"],
			[@mo_slur, "b", nil, "c,,,, { a( b c d) e( f g) r b''' }"],
			[@mo_slur, "d", 0, "c,,,, { a( b c d) e( f g) r d }"],
			[@mo_slured, "c", nil, "c { a( b c d e) c, }"],
			[@mo_slured, "b", nil, "c { a( b c d e) b }"],
			[@mo_slured, "d", 5, "c { a( b c d e) d' }"],
			[@mo_complex, "c", nil, "c, { r4\\( <ais c e> geses8( b[ e4])\\) r2 c }"],
			[@mo_complex, "ces", 4, "c, { r4\\( <ais c e> geses8( b[ e4])\\) r2 ces' }"]
		].each do |d|
			motif, note, octave, expected = d
			it "Motif « #{motif.notes} » (octave #{motif.octave}) + Note « #{note}-#{octave} »" do
				note = Note::new note, :octave => octave
				res = motif + note
				res.class.should == Motif
				res.to_s.should == "\\relative #{expected}"
			end
		end
	end
	describe "Motif + Motif" do
		define_motifs if @mo_slured.nil?
		[
			[@motif_simple, @motif_simple, "c { c e g c, e g }"],
			[@motif_simple, @motif_octave_2, "c { c e g c,, e g }"],
			[@motif_octave_2, @motif_simple, "c, { c e g c e g }"],
			[@motif_octave_2, @mo_accord, "c, { c e g <a' c e> }"],
			[@mo_accord, @motif_octave_2, "c { <a c e> c,, e g }"],
			[@motif_octave_2, @mo_chord_et_rest, "c, { c e g r <b' d fis> r g }"],
			[@mo_chord_et_rest, @motif_octave_2, "c { r <b d fis> r g c,, e g }"],
			[@mo_chord_et_rest, @mo_accord, "c { r <b d fis> r g <a c e> }"],
			[@mo_chord_et_rest, @mo_complex, 
				"c { r <b d fis> r g " \
				<< "r4\\( <ais, c e> geses8( b[ e4])\\) r2 }"],
			[@mo_complex, @mo_chord_et_rest,
				"c, { r4\\( <ais c e> geses8( b[ e4])\\) r2 " \
				<< "r <b' d fis> r g }"
				]
		].each do |d|
			mot1, mot2, expected = d
			it "Motif « #{mot1.notes} »-oct:#{mot1.octave} + Motif « #{mot2.notes} »-oct:#{mot2.octave}" do
				res = mot1 + mot2
				res.class.should == Motif
				res.to_s.should == "\\relative #{expected}"
			end
		end
	end
	describe "Motif + Chord" do
	  define_motifs if @mo_slured.nil?
		[
			[@motif_simple, "c e g", nil, "c { c e g <c, e g> }"],
			[@motif_simple, "c e g", 4, "c { c e g <c e g> }"],
			[@mo_chord_et_rest, "a c e", nil, "c { r <b d fis> r g <a c e> }"],
			[@mo_chord_et_rest, "a c e", 2, "c { r <b d fis> r g <a, c e> }"],
			[@mo_complex, "c e g c", nil, "c, { r4\\( <ais c e> geses8( b[ e4])\\) r2 <c e g c> }"],
			[@mo_complex, "c e g c", 6, "c, { r4\\( <ais c e> geses8( b[ e4])\\) r2 <c''' e g c> }"]
		].each do |d|
			motif, accord, chord_octave, expected = d
			it "Motif « #{motif.notes} »-oct:#{motif.octave} + accord <#{accord}>-oct:#{chord_octave}" do
			  res = motif + Chord::new( accord, :octave => chord_octave)
				res.class.should == Motif
				res.to_s.should == "\\relative #{expected}"
			end
		end
	end
end

# -------------------------------------------------------------------
# 	Chord
# -------------------------------------------------------------------
describe "Addition et Chord" do
	describe "Généralités" do
	  it "doit répondre à :+" do
	    Chord::new("a c e").should respond_to :+
	  end
	end
  describe "Chord + String doit réussir" do
    it "doit réussir avec un accord simple et un string simple" do
      acc = Chord::new "a c e"
			str = "b"
			res = acc + str
			res.class.should == Motif
			res.to_s.should == "\\relative c { <a c e> b }"
    end
		it "doit réussir avec un accord dont on change l'octave et la durée" do
		  lam = Chord::new "a c e"
			str = "c'" # donc à l'octave 4
			res = lam[2,"8"] + str # donc à l'octave 2
			res.class.should == Motif
			res.to_s.should == "\\relative c, { <a c e>8 c' }"
			
			res = lam[blanche, -2] + str
			res.class.should == Motif
			res.to_s.should == "\\relative c,,,,, { <a c e>2 c''''' }"
		end
  end
	describe "Chord + Note" do
		[
			["c e g", nil, nil, "c", nil, nil, "c { <c e g> c }"],
			["c e g", nil, 4, "c", nil, 8, "c { <c e g>4 c8 }"],
			["c e g", nil, nil, "c", 4, nil, "c { <c e g> c' }"],
			["c e g", nil, "8.", "c", 4, nil, "c { <c e g>8. c' }"],
			["c e g c", nil, nil, "c", 4, nil, "c { <c e g c> c' }"],
			["c e g c", nil, nil, "c", 4, 16, "c { <c e g c> c'16 }"]
		].each do |d|
			accord, oct_acc, dur_acc, note, oct_note, dur_note, expected = d
		  it "Chord « #{accord} »-oct:#{oct_acc} + Note #{note}-oct:#{oct_note}" do
		    acc 	= Chord::new :notes => accord, :octave => oct_acc, :duration => dur_acc
				note 	= Note::new note, :octave => oct_note, :duration => dur_note
				res = acc + note
				res.class.should == Motif
				res.to_s.should == "\\relative #{expected}"
		  end
		end
	end
	describe "Chord + Motif" do
	  it "un motif doit pouvoir être ajouté à un accord" do
	    # @note: on fait simple entendu que ça revient à tester 
			# l'adition d'un motif et d'un motif si Chord est correctement
			# transformé en motif
			acc = Chord::new "a c e", :octave => 2, :duration => 8
			mot = Motif::new "a c e", :octave => 4, :slured => true
			res = acc + mot
			res.class.should == Motif
			res.to_s.should == "\\relative c, { <a c e>8 a''( c e) }"
			# Le contraire
			res = mot + acc
			res.class.should == Motif
			res.to_s.should == "\\relative c' { a( c e) <a,,, c e>8 }"
	  end
	end
	describe "Chord + Chord" do
	  it "un accord doit pouvoir être ajouté à un accord" do
	    # @note : on fait simple entendu que ça revient à tester
			# l'addition de deux motifs qui contiendrait des accords
			acc1 = Chord::new %w(c e g), :octave => 1, :duration => 4
			acc2 = Chord::new "a c e", :octave => 4, :duration => 16
			res = acc1 + acc2
			res.class.should == Motif
			res.to_s.should == "\\relative c,, { <c e g>4 <a'''' c e>16 }"
			# Le contraire
			res = acc2 + acc1
			res.class.should == Motif
			res.to_s.should == "\\relative c' { <a c e>16 <c,,,, e g>4 }"
	  end
	end
	describe "Chord + Autre" do
	  it "doit lever une erreur fatale" do
	    expect{@chord + 12}.to raise_error
	  end
	end
end
