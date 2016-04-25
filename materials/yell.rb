module Puppet::Parser::Functions
  newfunction(:yell, :type => :rvalue, :doc => <<-EOS
    Takes one argument, a string, and returns an all capitalized
    copy of the string.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "yell(): Wrong # of args" +
      "given (#{args.size} for 1)") if args.size != 1

    args[0].upcase
  end
end
