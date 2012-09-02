# par exemple dans > score/premier_score.rb

@title    = "Mon premier score lily2ruby"
@composer = "Phil"
@time     = "6/8"
@key      = "G"

def orchestre
  <<-EOO
    
    name    instrument
  -------------------------------------------------------------------
    JANE    Voice
    PETE    Piano
    HELEN   Cello
  -------------------------------------------------------------------
  EOO
end

def score
  JANE << ("c4" * 3 + "e g" + "c" * 3) * 3
  PETE.main_droite << (riff_do + riff_fa + riff_sol) * 2
  PETE.main_gauche << (riffb_do + riffb_fa + riffb_sol) * 2
  HELEN << "c2. e g" * 2
end

# Définition des riffs
def riff_do
  @riff_do ||= define_riff_do
end
def riff_fa
  @riff_fa ||= riff_do.moins(7)
end
def riff_sol
  puts "riff_fa : #{riff_fa.inspect}"
  riff_fa.plus(2)
end
def define_riff_do
  acc_do = Chord::new "g c e"
  Motif::new acc_do[8] + acc_do[4] * 2 + acc_do[8]
end
def riffb_do
  @riffb_do ||= Motif::new( "c8 c2 c8" )
end
def riffb_fa
  @riffb_fa ||= riffb_do.moins(7)
end
def riffb_sol
  riffb_fa.plus(2)
end