module Parsers
  class Session < Base
    def parse
      {
        'user_id'    => fields[1],
        'session_id' => fields[2],
        'browser'    => fields[3].upcase!,
        'time'       => fields[4],
        'date'       => Date.parse(fields[5])
      }
    end
  end
end
