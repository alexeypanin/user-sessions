module Parsers
  class Session < Base
    def parse
      {
        'user_id' =>    fields[1],
        'session_id' => fields[2],
        'browser' =>    fields[3],
        'time' =>       fields[4],
        'date' =>       fields[5]
      }
    end
  end
end
