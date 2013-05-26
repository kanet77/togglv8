module Greetings
  def say_hello
    puts "Hello!"
  end
end

class Human
  include Greetings
end

Human.new.say_hello # => "Hello!"
# Human.say_hello     # NoMethodError

class Robot
  extend Greetings
end

# Robot.new.say_hello # NoMethodError
Robot.say_hello     # => "Hello!"