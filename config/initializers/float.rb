class Float
  def precision(p)
    # Make sure the precision level is actually an integer and > 0
    raise ArgumentError, "#{p} is an invalid precision level. Valid ranges are integers > 0." unless p.class == Fixnum or p < 0
    # Special case for 0 precision so it returns a Fixnum and thus doesn't have a trailing .0
    return self.round if p == 0
    # Standard case
    return (self * 10**p).round.to_f / 10**p
  end

end
