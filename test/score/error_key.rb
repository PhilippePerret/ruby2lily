@title = "Partition avec une erreur de key"
@key = 'c' # should be 'C'

def orchestre
  <<-EOO
    instrument  class    staff
    PAUL        Voice       -       -
  EOO
end

def score
  PAUL.add "a b c"
  # PAUL.add_lyrics "Yes I can"
end