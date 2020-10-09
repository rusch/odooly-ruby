class Odooly

  class RecordList < Array

    def initialize(odooly:, name:, ids:)
      @odooly = odooly
      @name = name
      @fields = odooly.fields(name)
      ids.collect { |_| self << Record.new(odooly: odooly, name: name, id: _) }
    end

    def inspect
      if length > 10
        "<%s '%s,length=%i'>" % [ self.class.to_s, @name, length ]
      else
        "<%s '%s,%s'>" % [ self.class.to_s, @name, collect(&:id).inspect ]
      end
    end

    def read(names=nil)
      values_list = @odooly[@name].read(collect(&:id), fields: names)

      if names.is_a?(String)
        field = @fields[names]
        return field ? values_list.collect { |_| transform(value: _, field: field) } : values_list
      end

      values_list.collect do |values|
        values.each do |name, value|
          field = @fields[name]
          values[name] = transform(value: value, field: field) if field
        end
      end
    end

    def method_missing(name, *args)
      @fields[name.to_s] ? read(name.to_s) : @odooly[@name].send(name, collect(&:id), *args)
    end

    private

    def transform(value:, field:)
      case field['type']
      when 'many2one'
      value ? Record.new(odooly: @odooly, name: field['relation'], id: value[0]) : value
      when 'one2many', 'many2many'
        RecordList.new(odooly: @odooly, name: field['relation'], ids: value)
      when 'date'
        value ? Date.parse(value) : value
      when 'datetime'
        value ? DateTime.parse(value) : value
      else
        value
      end
    end

  end

end
