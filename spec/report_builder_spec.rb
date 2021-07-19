Dir[File.join(__dir__, 'parsers', '*.rb')].sort.each { |file| require file }

require '../report_builder'
require '../data_parser'

DATA_FILE = './spec/files/test_data.txt'
RESULT_FILE = './files/result.json'

describe ReportBuilder do
  describe '#parser' do
    let(:user) do
      user = Parsers::User.new('user,0,Leida,Cira,0').parse
      user.sessions << Parsers::Session.new('session,0,0,Safari 29,87,2016-10-23').parse
      user.sessions << Parsers::Session.new('session,0,0,Chrome 35,85,2016-9-21').parse
      user
    end

    # ставлю большое число строк в lines_count чтобы данные не уходили в файл
    let(:builder) { ReportBuilder.new(lines_count: 1000) }

    it 'should calculate stats for each user' do
      builder.calc_user_stats(user)

      stats = builder.report[:usersStats][0]['Leida Cira']

      expect(stats['sessionsCount']).to eq(2)
      expect(stats['totalTime']).to eq('172 min.')
      expect(stats['longestSession']).to eq('87 min.')
      expect(stats['browsers']).to eq('CHROME 35, SAFARI 29')
      expect(stats['dates']).to eq(%w[2016-10-23 2016-09-21])
      expect(stats['usedIE']).to be_falsey
      expect(stats['alwaysUsedChrome']).to be_falsey
    end

    it 'should calculate group stats' do
      builder.send(:update_group_stats, user)
      builder.finish_report

      stats = builder.report

      expect(stats[:totalUsers]).to eq(1)
      expect(stats[:totalSessions]).to eq(2)
      expect(stats[:uniqueBrowsersCount]).to eq(2)
      expect(stats[:allBrowsers]).to eq 'SAFARI 29,CHROME 35'
    end
  end
end
