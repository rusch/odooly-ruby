require 'json'
require 'yaml'
require 'net/http'
require 'nokogiri'
require 'odooly/version'
require 'odooly/object'
require 'odooly/record'
require 'odooly/record_list'
require 'odooly/exception'
class Odooly

  attr_reader :uid
  attr_reader :database
  attr_reader :username

  def initialize(scheme: 'https', host:, port: 8069, username:, password:, database:)
    raise ArgumentError, 'Invalid scheme' unless ['http', 'https'].include?(scheme)
    raise ArgumentError, 'invalid port' unless port.is_a?(Integer) and port.between?(1, 65535)
    @url = URI("%s://%s:%s/jsonrpc" % [scheme, host, port])
    @username = username
    @password = password
    @database = database
    authenticate()
    @model_names = [ 'ir.model' ]
    @model_names = self['ir.model'].search([]).model
  end

  def server_version
    xml_data = Nokogiri::XML::Builder.new do |xml|
      xml.methodCall {
        xml.methodName 'server_version'
        xml.params nil
      }
    end.to_xml

    response_xml = request_xml(path: '/xmlrpc/db', data: xml_data)
    return response_xml.xpath('/methodResponse/params/param/value/string').text
  end

  def request_xml(path:, data:)
    url = @url.dup
    url.path = path
    header = {
      'Content-Type' => 'text/xml; charset=utf-8',
      'Accept' => '*/*',
    }
    if @session_id
      header['Cookie'] = 'sessionid=%s' % @session_id
    end
    http_response = Net::HTTP.post(url, data, header)
    xml =  Nokogiri::XML.parse(http_response.body)
    response_node = xml > 'methodResponse'
    if response_node.empty?
      # $TODO: Throw better exception
      raise RuntimeError, "No methodResponse in answer"
    end

    fault_node = response_node > 'fault'
    unless fault_node.empty?
      fault_data = fault_node.xpath('//member').inject({}) do |h, node|
        name = (node > 'name').text
        h[name] = (node > 'value').text unless name == ''
        h
      end
      if fault_data['faultCode'].to_s.index('Record not found')
        raise Odooly::NotFound, fault_data['faultCode']
      end
      raise Odooly::Error, fault_data['faultCode'] #, fault_data
    end

    return response_node
  end

  def request_json(path:, data:)
    url = @url.dup
    url.path = path
    header = {
      'Content-Type' => 'application/json',
      'Accept' => '*/*',
    }
    if @session_id
      header['Cookie'] = 'sessionid=%s;' % @session_id
    end
    response = Net::HTTP.post(url, data, header)
    return JSON.parse(response.body)
  end

  def json_rpc(method:, params:)
    data = {
      "jsonrpc" => "2.0",
      "method" => method,
      "params" => params,
    }

    request(path: '/jsonrpc/object')
    response = Net::HTTP.post(@url, data.to_yaml, header)
  end

  def execute(model:, method:, args: [])
    args = [ args ] unless args.is_a? Array
    method_args = [ @database, 14, @username, model, method]
    xml = Nokogiri::XML::Builder.new do |xml|
      xml.methodCall {
        xml.methodName 'execute_kw'
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
        xml.param {
          xml.value {
            xml.array {
              args.each do |arg|
                xml.data {
                  xml.value {
                    xml.string arg
                  }
                }
              end
            }
          }
        }
      }
    end.to_xml

    header = {
      'Content-Type' => 'text/xml; charset=utf-8',
      'Accept' => '*/*',
    }
    url = @url.dup
    url.path = '/xmlrpc/object'
    @response = Net::HTTP.post(url, xml, header)
  end

  def authenticate
    data = {
      "method" => "call",
      "params" => {
        "db" => "behave",
        "login" => "thom",
        "password" => "thom",
        "base_location" => nil
      }
    }.to_json
    response = request_json(path: '/web/session/authenticate', data: data)
    result = response['result'] || {}
    @uid = result['uid']
    @session_id = result['session_id']
    @context = result['context']
  end

  def invoke(model, method, *args)
    args = [DB, uid, PASS, model, method] + list(args)
    return server.call(service="object", method="execute", args=args)
  end


  def [](name)
    unless @model_names.include?(name)
      similar_names = @model_names.grep(Regexp.new(name))
      if similar_names.empty?
        raise(ArgumentError, 'Model not found: %s' % name.inspect)
      end
      raise(ArgumentError, "Model not found.  These models exist:\n" +
                           similar_names.collect { |_| " * #{_}\n" }.join)
    end
    Object.new(odooly: self, name: name)
  end

  def inspect
    "<%s %s@%s>" % [ self.class.to_s, @username, @database ]
  end

end
