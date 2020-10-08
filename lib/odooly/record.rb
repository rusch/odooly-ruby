class Odooly
  require 'datetime'

  class Record

    attr_reader :id

    def initialize(odooly:, name:, id:)
      raise ArgumentError, 'integer expected'  unless id.is_a?(Integer)
      @odooly = odooly
      @name = name
      @id = id

      @fields = odooly.fields(name)
    end

    def read(names=nil)
      values = @odooly[@name].read(@id, fields: names)
      if names.is_a?(String)
        field = @fields[names]
        return field ? transform(value: values, field: field) : values
      end

      values.collect do |name, value|
        field = @fields[name]
        values[name] = transform(value: value, field: field) if field
      end
      return values
    end

    def method_missing(name, *args)
      field = @fields[name.to_s]
      raise NotImplemented, "RPC function call for records not implemented. (function: #{name})" unless field
      value = read(name.to_s)
    end

    def inspect
      "<%s '%s,%i'>" % [ self.class.to_s, @name, id ]
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
