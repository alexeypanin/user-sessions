require File.join(__dir__, 'user_object.rb')

module Parsers
  class User < Base
    def parse
      attrs = {
        'id' => fields[1],
        'first_name' => fields[2],
        'last_name' => fields[3],
        'age' => fields[4]
      }

      UserObject.new(attributes: attrs, sessions: [])
    end
  end
end
