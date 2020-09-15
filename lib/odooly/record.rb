class Odooly

  class Record

    attr_reader :id

    def initialize(odooly:, name:, id:)
      raise ArgumentError, 'integer expected'  unless id.is_a?(Integer)
      @odooly = odooly
      @name = name
      @id = id
    end

    def read(names: nil)
      @odooly[@name].read(@id, fields: names)
    end

    def method_missing(name, *args)
      @odooly[@name].read(@id, fields: name.to_s)
    end

    def inspect
      "<%s '%s,%i'>" % [ self.class.to_s, @name, id ]
    end

  end
end
