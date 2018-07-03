class URI
  # TODO remove after https://github.com/crystal-lang/crystal/pull/6311 will be merged and released
  def absolute?
    @scheme && (((host = @host) && !host.empty?) || ((path = @path) && !path.empty?)) ? true : false
  end

  def relative?
    !absolute?
  end
end
