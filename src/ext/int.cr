struct Int
  def to_time_span : Time::Span
    Time::Span.new(seconds: self)
  end
end
