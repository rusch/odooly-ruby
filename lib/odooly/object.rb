class Odooly

  class Object


    def initialize(odooly:, name:)
      @odooly = odooly
      @object_name = name
    end

    def search(domain, offset: nil, limit: nil)
      raise ArgumentError, 'domain must be an Array' unless domain.is_a? Array
      search_args = [ expand_string_filters(domain) ]
      if offset != nil or limit != nil
        search_args += [ offset.to_i, limit.to_i ]
      end
      response_data = execute_kw(method: 'search', args: search_args)
      RecordList.new(odooly: @odooly, name: @object_name, ids: response_data)
    end

    def search_read(domain, offset: nil, limit: nil)
      raise ArgumentError, 'domain must be an Array' unless domain.is_a? Array
      search_args = [ expand_string_filters(domain) ]
      if offset != nil or limit != nil
        search_args += [ offset.to_i, limit.to_i ]
      end
      execute_kw(method: 'search_read', args: search_args)
    end

    def read(ids, fields: nil)
      if !ids.is_a?(Integer) && (!ids.is_a?(Array) || ids.empty? || ids.find { |_| !_.is_a?(Integer)} != nil)
        raise ArgumentError, 'argument must be an Integer or an Array of Integer'
      end
      field = nil
      if fields.is_a?(String)
        field = fields
        fields = [ fields ]
      end
      if fields != nil && !fields.is_a?(Array) && fields.find { |_| !_.is_a?(String)} != nil
        raise ArgumentError, 'fields must be nil or an Array of String'
      end
      read_args = [ ids ]
      read_args += [ fields ] if fields

      result = execute_kw(method: 'read', args: read_args)
      field ? (ids.is_a?(Array) ? result.collect { |_| _[field] } : result[field]) : result
    end

    def write(ids, write_fields)
      if ids.is_a?(Integer)
        ids = [ ids ]
      elsif (!ids.is_a?(Array) || ids.empty? || ids.find { |_| !_.is_a?(Integer)} != nil)
        raise ArgumentError, 'argument must be an Integer or an Array of Integer'
      end
      unless write_fields.is_a?(Hash)
        raise ArgumentError, 'write_fields must be a Hash'
      end

      execute_kw(method: 'write', args: [ids, write_fields])
    end

    def browse(ids)
      if ids.is_a?(Integer)
        return Record.new(odooly: @odooly, name: @object_name, id: ids)
      end
      if ids.is_a?(Array) && !ids.empty? && !ids.find { |_| !_.is_a?(Integer)}
        return RecordList.new(odooly: @odooly, name: @object_name, ids: ids)
      end
      raise ArgumentError, 'argument must be an Integer or an Array of Integer'
    end

    def get(domain)
      raise ArgumentError, 'domain must be an Array' unless domain.is_a? Array
      execute_kw(method: 'read', args: [domain])
    end

    def fields(names = nil)
      if names.is_a?(String)
        names = [ names ]
      elsif names != nil && (!names.is_a?(Array) || names.empty? || names.find { |_| !_.is_a?(String)} != nil)
        raise ArgumentError, 'argument must be nil or a String or an Array of String'
      end
      execute_kw(method: 'fields_get', args: names ? [ names ] : [])
    end

    def field(name)
      if name.is_a? Symbol
        name = name.to_s
      elsif !name.is_a? String
        raise ArgumentError, 'name must be String or Symbol'
      end
      @odooly.fields(@object_name)[name]
    end

    def field_selection(name)
      field_data = field(name)
      raise Error, "No such field (#{name.inspect}" unless field_data
      raise Error, 'Not a selection' unless field_data['type'] == 'selection'
      Hash[field_data['selection']]
    end

    def method_missing(method_name, *args)
      args = [ args ] unless args.is_a? Array
      execute_kw(method: method_name.to_s, args: args)
    end

    def inspect
      '<%s %s>' % [ self.class.to_s, @object_name ]
    end

    private

    def execute_kw(method:, args: [])
      method_args = [@odooly.database, @odooly.uid, @odooly.password, @object_name, method.to_s]
      def _to_xml(xml, domain)
        case domain
        when Integer
          xml.value { xml.int domain }
        when String
          (Integer(domain) rescue false) ? _to_xml(xml, domain.to_i) : xml.value { xml.string domain }
        when Array
          xml.value { xml.array { xml.data { domain.each { |_| _to_xml(xml, _) } } } }
        when Hash
          xml.value { xml.struct { domain.each { |k,v| xml.member { xml.name k; _to_xml(xml, v) } } } }
        when TrueClass
          xml.value { xml.boolean '1' }
        when FalseClass, NilClass
          xml.value { xml.boolean '0' }
        else
          raise ArgumentError, "Invalid content: #{domain.inspect}"
        end
      end

      def _to_ruby(xml)
        $xml = xml
        value = case xml.child.name
                when 'array'
                  (xml.child > 'data' > 'value').collect do |node|
                    _to_ruby(node)
                  end
                when 'struct'
                  (xml.child > 'member').inject({}) do |hash, member_node|
                    key = (member_node > 'name').text
                    hash[key] = _to_ruby((member_node > 'value')[0])
                    hash
                  end
                when 'string'
                  xml.child.text
                when 'int'
                  xml.child.text.to_i
                when 'double'
                  xml.child.text.to_f
                when 'boolean'
                  xml.child.text == '1'
                else
                  raise RuntimeError, "Unknown #{xml.child.name}"
                end
      end

      xml = Nokogiri::XML::Builder.new do |xml|
        xml.methodCall {
          xml.methodName 'execute_kw'
          if method_args
            xml.method_args {
              method_args.each do |arg|
                xml.value {
                  case arg
                  when Integer
                    xml.int arg
                  else
                    xml.string arg
                  end
                }
              end
            }
          end
          _to_xml(xml, args)
        }
      end.to_xml

      method_response_xml = @odooly.request_xml(path: '/xmlrpc/object', data: xml)

      param_xml = method_response_xml.xpath('//params/param')
      rb_data = _to_ruby((param_xml > 'value')[0])
      return rb_data
    end

    def expand_string_filters(search_domain)
      search_domain.collect do |condition|
        if condition.is_a?(Array)
          condition
        else
          el = condition.strip.split(/\s*(!?=)\s*/, 2)
          (el.length == 3 && el[0] != '') ? el : condition
        end
      end
    end
  end

end
