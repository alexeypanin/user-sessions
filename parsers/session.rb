module Parsers
  class Session < Base
    def parse
      {
        'user_id'    => fields[1],
        'session_id' => fields[2],
        'browser'    => fields[3].upcase!,
        'time'       => fields[4],
        'date'       => parse_date(fields[5])
      }
    end

    def parse_date(string)
      date = string.split('-').map! { |d| d.to_i }
      Date.civil(date[0], date[1], date[2])
    end
  end
end
