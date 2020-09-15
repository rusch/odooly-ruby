class Odooly

  class RecordList < Array

    def initialize(odooly:, name:, ids:)
      @odooly = odooly
      @name = name
      ids.collect { |_| self << Record.new(odooly: odooly, name: name, id: _) }
    end

    def inspect
      if length > 10
        "<%s '%s,length=%i'>" % [ self.class.to_s, @name, length ]
      else
        "<%s '%s,%s'>" % [ self.class.to_s, @name, collect(&:id).inspect ]
      end
    end

    def read(names)
      @odooly[@name].read(collect(&:id), fields: names)
    end

    def method_missing(name, *args)
      @odooly[@name].read(collect(&:id), fields: name.to_s)
    end

  end

end
