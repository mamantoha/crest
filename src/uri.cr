class URI
  # TODO remove after https://github.com/crystal-lang/crystal/pull/6311 will be merged and released
  def absolute?
    @scheme ? true : false
  end

  def relative?
    !absolute?
  end
end
