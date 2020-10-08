class Odooly
  class Exception < RuntimeError
  end

  Error = Class.new(Exception)
  DatabaseError = Class.new(Exception)
  AuthenticationError = Class.new(Exception)
  AccessDenied = Class.new(Exception)
  NotFound = Class.new(Exception)
end
