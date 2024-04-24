struct Float
  def to_time_span : Time::Span
    seconds = self.to_i
    nanoseconds = ((self - seconds) * 1_000_000_000).to_i

    Time::Span.new(seconds: seconds, nanoseconds: nanoseconds)
  end
end
