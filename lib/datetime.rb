require 'date'

Date.class_eval do

  def to_odoo
    strftime('%F')
  end

end

DateTime.class_eval do

  def to_odoo
    strftime('%F %T.%6N')
  end

end
