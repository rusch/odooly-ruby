class Odooly
  class Exception < RuntimeError
  end

  Error = Class.new(Exception)
  NotFound = Class.new(Exception)
end
