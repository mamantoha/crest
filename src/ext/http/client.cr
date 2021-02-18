class HTTP::Client
  def closed? : Bool
    @io ? false : true
  end
end
