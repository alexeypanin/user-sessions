require '../data_parser.rb'

describe DataParser do
  describe '#parser' do
    DATA_FILE = './spec/files/test_data.txt'
    RESULT_FILE = './files/result.json'

    context 'when data file is valid' do
      before(:all) do
        test_data = %Q(
          user,0,Leida,Cira,0
          session,0,0,Safari 29,87,2016-10-23
          user,1,Palmer,Katrina,65
          session,1,0,Safari 17,12,2016-10-21
          session,1,1,Firefox 32,3,2016-12-20
        ).gsub(/^\s*/, '')

        File.write(DATA_FILE, test_data)
      end

      it 'should write report to file' do
        FileUtils.rm(RESULT_FILE) if File.exists?(RESULT_FILE)
        DataParser.new(file_name: DATA_FILE).parse

        expect(File.exists?(RESULT_FILE)).to be_truthy
      end
    end

    context 'when data file is invalid' do
      before do
        test_data = %Q(
          user,0,Leida,Cira,0
          session,0,0,Safari 29,87,2016-10-23
          butterfly,1,White,Lady,0).gsub(/^\s*/, '')

        File.write(DATA_FILE, test_data)
      end

      subject { DataParser.new(file_name: DATA_FILE).parse }

      it 'should raise error if given unknown object' do
        expect { subject }.to raise_error('Parser for object butterfly not exists')
      end
    end
  end
end