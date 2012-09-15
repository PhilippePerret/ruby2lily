# 
# Class NoteClass
# 
# Classe mère dont héritent toutes les classes note : Note, Motif,
# Chord...
# 
class NoteClass
  
  unless defined? NoteClass::DUREES # tests
    # Valeurs de durées possibles
    DUREES = {
      "1" => { :nomh_fr => "ronde", :nomh_en => "whole" },
      "1." => { :nomh_fr => "ronde pointée", :nomh_en => "dotted whole" },
      "1.." => { :nomh_fr => "ronde double pointée", :nomh_en => "dobble dotted whole" },
      "1..." => { :nomh_fr => "ronde triple pointée", :nomh_en => "triple dotted whole" },
      "2" => { :nomh_fr => "blanche", :nomh_en => "half" },
      "2." => { :nomh_fr => "blanche pointée", :nomh_en => "dotted half" },
      "2.." => { :nomh_fr => "blanche double pointée", :nomh_en => "dobble dotted half" },
      "2..." => { :nomh_fr => "blanche triple pointée", :nomh_en => "triple dotted half" },
      "4" => { :nomh_fr => "noire", :nomh_en => "quarter" },
      "4." => { :nomh_fr => "noire pointée", :nomh_en => "dotted quarter" },
      "4.." => { :nomh_fr => "noire double pointée", :nomh_en => "dobble dotted quarter" },
      "4..." => { :nomh_fr => "noire triple pointée", :nomh_en => "dobble triple quarter" },
      "8" => { :nomh_fr => "croche", :nomh_en => "quaver" },
      "8." => { :nomh_fr => "croche pointée", :nomh_en => "dotted quaver" },
      "8.." => { :nomh_fr => "croche double pointée", :nomh_en => "dobble dotted quaver" },
      "8..." => { :nomh_fr => "croche triple pointée", :nomh_en => "triple dotted quaver" },
      "16" => { :nomh_fr => "double-croche", :nomh_en => "semiquaver" },
      "16." => { :nomh_fr => "dbl-croche pointée", :nomh_en => "dotted semiquaver" },
      "16.." => { :nomh_fr => "dbl-croche double pointée", :nomh_en => "dobble dotted semiquaver" },
      "16..." => { :nomh_fr => "dbl-croche triple pointée", :nomh_en => "triple dotted semiquaver" },
      "32" => { :nomh_fr => "triple-croche", :nomh_en => "demisemiquaver" },
      "32." => { :nomh_fr => "tpl-croche pointée", :nomh_en => "dotted demisemiquaver" },
      "32.." => { :nomh_fr => "tpl-croche double pointée", :nomh_en => "dobble dotted demisemiquaver" },
      "32..." => { :nomh_fr => "tpl-croche triple pointée", :nomh_en => "triple dotted demisemiquaver" },
      "64" => { :nomh_fr => "quadruple-croche", :nomh_en => nil },
      "64." => { :nomh_fr => "quadruple-croche  pointée", :nomh_en => nil },
      "64.." => { :nomh_fr => "quadruple-croche double pointée", :nomh_en => nil },
      "64..." => { :nomh_fr => "quadruple-croche triple pointée", :nomh_en => nil },
      "128" => { :nomh_fr => "quintuple-croche", :nomh_en => nil },
      "128." => { :nomh_fr => "quintuple-croche pointée", :nomh_en => nil },
      "128.." => { :nomh_fr => "quintuple-croche double pointée", :nomh_en => nil },
      "128..." => { :nomh_fr => "quintuple-croche triple pointée", :nomh_en => nil },
      "256" => { :nomh_fr => "sextuple-croche", :nomh_en => nil },
      "256." => { :nomh_fr => "sextuple-croche pointée", :nomh_en => nil },
      "256.." => { :nomh_fr => "sextuple-croche double pointée", :nomh_en => nil },
      "256..." => { :nomh_fr => "sextuple-croche triple pointée", :nomh_en => nil },
      "512" => { :nomh_fr => "hectuple-croche", :nomh_en => nil },
      "512." => { :nomh_fr => "hectuple-croche pointée", :nomh_en => nil },
      "512.." => { :nomh_fr => "hectuple-croche double pointée", :nomh_en => nil },
      "512..." => { :nomh_fr => "hectuple-croche triple pointée", :nomh_en => nil }
    }
  end
  
  # =>  Return true si +duree+ est une durée valide
  #     False dans le cas contraire
  def self.duree_valide? duree
    duree = duree[0..-2] if duree.end_with? "~"
    return true if duree.blank?
    return DUREES.has_key? duree
  end
  
  # =>  Return un hash à partir de +params+ envoyé dans [...] d'une
  #     classe de note (Note, Motif, Chord...)
  # 
  # Cette méthode est utilisée par toutes les méthodes `[]' des Notes,
  # Chord, Motif, etc. qui permettent de définir une nouvelle instance
  # à l'aide de :
  #     <class chose>[....]
  # Comme il peut y avoir plusieurs chose entre les crochets, on utilise
  # cette méthode pour analyser le contenu et retourner un hash de 
  # propriétés qu'il faudra affecter à la nouvelle instance.
  # 
  # @param  params
  #         Peut être :
  #           Une liste contenant [octave, duree]
  #           Une liste contenant ["duree"] (noter le string)
  #           Une liste contenant [octave]
  #           Une liste contenant [<hash>]
  #           où <hash> peut contenir les informations sur la durée et
  #           l'octave.
  def self.params_crochet_to_hash params
    
    return {} if params.nil?
    
    fatal_error(:bad_params_in_crochet) unless params.class == Array
    
    param1 = params[0]
    param2 = params[1]    # Note: les deux valeurs peuvent être nil
    
    hash    = nil
    octave  = nil
    duree   = nil
  
    begin
      case params.length
      when 1
        case param1.class.to_s
        when "Hash" # Envoi des paramètres par un hash
          hash  = param1
          hash[:duration] = hash.delete(:duree) if hash.has_key? :duree
        when "String" # => Durée
          duree   = param1    unless param1.nil?
        when "Fixnum" # => Octave
          octave  = param1    unless param1.nil?
        else
          raise 'bad_class_in_parameters_crochets'
        end
      when 2 # 2 paramètres (octave, durée ou "durée", octave)
        octave, duree = case param1.class.to_s
                        when "String"
                          unless param2.class == Fixnum
                            raise 'bad_class_in_parameters_crochets'
                          end
                          [param2, param1]
                        when "Fixnum"
                          unless [Fixnum, String].include?(param2.class)
                            raise 'bad_class_in_parameters_crochets'
                          end
                          [param1, param2]
                        when "NilClass"
                          [param1, param2]
                        else 
                          raise 'bad_class_in_parameters_crochets'
                        end
      else
        raise 'too_much_parameters_to_crochets'
      end
    
    rescue Exception => e
      fatal_error(e.message)
    end
    
    if hash.nil?
      hash = {}
      hash = hash.merge(:duration => duree)   unless duree.nil?
      hash = hash.merge(:octave   => octave)  unless octave.nil?
    end
    
    
    # Dernière vérification sur la validité de la durée
    if hash.has_key?(:duration)
      hash[:duration] = hash[:duration].to_s
      unless NoteClass::duree_valide? hash[:duration]
        fatal_error(:bad_value_duree, :bad => hash[:duration])
      end
    end
    
    return hash
  end
  
  # -------------------------------------------------------------------
  #   Instance (Note, Motif, Chord...)
  # -------------------------------------------------------------------
  
  require 'module/operations.rb' # normalement, toujours chargé
  include OperationsSurNotes

  # Méthode définissant les propriétés d'un objet de type NoteClass
  # (donc Motif, Chord, etc.)
  # 
  # @principe:  Si la classe d'objet possède une méthode d'instance
  #             portant le nom `set_<property>`, alors cette méthode est
  #             invoquée, avec la valeur, pour définir la valeur de la
  #             propriété considérée. Dans le cas contraire, on donne
  #             simplement la valeur à la propriété.
  # 
  # @param  params      Un hash de paires property-value à affecter à
  #                     l'objet. Ou nil (rien à faire)
  # 
  # @return void
  # 
  # @note:  Lève une erreur fatale si +params+ n'est pas nil ou un hash.
  # @note:  Transforme toujours la propriété :duree en :duration et met
  #         toujours la valeur en string.
  # 
  def set_params params
    # puts "\n--> set_params(#{params.inspect})"
    return if params.nil?
    # +params+ doit être de type Hash exclusivement
    fatal_error(:bad_type_for_args, :method => "NoteClass#set_params",
      :good => "Hash", :bad => params.class.to_s) \
      unless params.class == Hash
    
    # Définition des notes/note
    # --------------------------
    # Elles doivent être définies avant d'autres paramètres
    # @note: noter que la tournure actuelle empêche de passer par une
    # méthode qui serait conventionnelle (set_note/set_notes)
    if params.has_key? :notes
      @notes  = params.delete(:notes)
    elsif params.has_key? :note
      @note   = params.delete(:note)
    end
    
    # Vérification et définition de la durée
    # --------------------------------------
    if params.has_key? :duree
      params = params.merge :duration => params.delete(:duree)
    end
    unless params[:duration].nil?
      params[:duration] = params[:duration].to_s
      unless NoteClass::duree_valide?(params[:duration])
        fatal_error(:bad_value_duree, :bad => params[:duration])
      end
    end
    
    # Vérification et définition de l'octave
    # ---------------------------------------
    if params.has_key?( :octave ) && params[:octave] != nil
      params[:octave] = params[:octave].to_i
      if params[:octave] < -2 || params[:octave] > 8
        fatal_error(:bad_value_octave, 
          :class => self.class.to_s, :bad => params[:octave].to_s)
      end
    end
    
    # Affectation des valeurs (directe ou par méthode propre)
    # ------------------------
    params.each do |prop, value|
      if self.respond_to?("set_#{prop}")
        self.send("set_#{prop}", value)
      else
        self.instance_variable_set("@#{prop}", value)
      end
    end
  end
  
end