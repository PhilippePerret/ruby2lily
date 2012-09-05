# 
# Méthodes pour les notes
# 

# === Notes ===
def ut params = nil
  Note::create_note "c", params
end
def re params = nil
  Note::create_note "d", params
end
def mi params = nil
  Note::create_note "e", params
end
def fa params = nil
  Note::create_note "f", params
end
def sol params = nil
  Note::create_note "g", params
end
def la params = nil
  Note::create_note "a", params
end
def si params = nil
  Note::create_note "b", params
end

# === Durées === #
def pointer(duree, pointee = false)
  "#{duree}" << (pointee === true ? '.' : '')
end
def ronde params = nil
  pointer("1", params)
end
alias :whole :ronde
def blanche params = nil
  pointer("2", params)
end
alias :half :blanche
def noire params = nil
  pointer("4", params)
end
alias :quarter :noire
def croche params = nil
  pointer("8", params)
end
alias :quaver :croche
def dbcroche params = nil
  pointer("16", params)
end
alias :semiquaver :dbcroche
def tpcroche params = nil
  pointer("32", params)
end
alias :demisemiquaver :tpcroche
def qdcroche params = nil
  pointer("64", params)
end
def cqcroche params = nil
  pointer("128", params)
end