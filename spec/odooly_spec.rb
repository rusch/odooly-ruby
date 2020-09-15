require File.dirname(__FILE__) + '/../lib/odooly'

OOOR_URL = ENV['ODOOLY_URL'] || 'http://localhost:8069/xmlrpc'
OOOR_DB_PASSWORD = ENV['ODOOLY_DB_PASSWORD'] || 'admin'
OOOR_USERNAME = ENV['ODOOLY_USERNAME'] || 'admin'
OOOR_PASSWORD = ENV['ODOOLY_PASSWORD'] || 'admin'
OOOR_DATABASE = ENV['ODOOLY_DATABASE'] || 'ooor_test'

#RSpec executable specification; see http://rspec.info/ for more information.
#Run the file with the rspec command  from the rspec gem
describe Ooor do
  before(:all) do
    @ooor = Ooor.new(url: OOOR_URL, username: OOOR_USERNAME, password: OOOR_PASSWORD)
  end
