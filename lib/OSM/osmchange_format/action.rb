module OSM
  class Action
    # OSM Action type
    attr_reader :type
    
    # The list of objects
    attr_reader :objects
    
    def initialize(type)
      case type
      when :create
        @type = :create
      when :modify
        @type = :modify
      when :delete
        @type = :delete
      else
        raise TypeError.new("Action type must be :create, :modify or delete")
      end
      @objects = []
    end
    
    def push(object)
      if object.class == Node or object.class == Way or object.class == Relation
        @objects.push object
      else
        raise TypeError.new("Object must be Node, Way or Relation")
      end
    end
    
    def objects=(objects)
      objects.each do |obj|
        self.push(obj)
      end
    end
    
  end
  
end