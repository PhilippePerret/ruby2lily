# 
# Sous-classe Liby::Command
# 
# qui gère les commandes
# 
require 'liby'

class Liby::Command
  
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @command = nil    # Le nom string de la commande
  
  # Instancie une commande
  def initialize command
    @command = command
  end
  
  # Lancement de la commande
  def run
    
  end
end