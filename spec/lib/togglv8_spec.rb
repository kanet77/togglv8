require 'fileutils'

describe 'TogglV8::API' do
  before :each do
    sleep(Testing::DELAY_SEC)
  end

  it 'initializes with api_token' do
    toggl = TogglV8::API.new(Testing::API_TOKEN)
    me = toggl.me
    expect(me).to_not be nil
    expect(me['api_token']).to eq Testing::API_TOKEN
    expect(me['email']).to eq Testing::USERNAME
  end

  it 'initializes with username and password' do
    toggl = TogglV8::API.new(Testing::USERNAME, Testing::PASSWORD)
    me = toggl.me
    expect(me).to_not be nil
    expect(me['api_token']).to eq Testing::API_TOKEN
    expect(me['email']).to eq Testing::USERNAME
  end

  it 'does not initialize with bogus api_token' do
    toggl = TogglV8::API.new('4880nqor1orr9n241sn08070q33oq49s')
    expect { toggl.me } .to raise_error(RuntimeError)
  end

  context '.toggl file' do
    before :each do
      @home = File.join(Dir.pwd, "tmp")
      Dir.mkdir(@home)

      @original_home = Dir.home
      ENV['HOME'] = @home
    end

    after :each do
      FileUtils.rm_rf(@home)
      ENV['HOME'] = @original_home
    end

    it 'initializes with .toggl file' do
      toggl_file = File.join(@home, '.toggl')
      File.open(toggl_file, 'w') { |file| file.write(Testing::API_TOKEN) }

      toggl = TogglV8::API.new
      me = toggl.me
      expect(me).to_not be nil
      expect(me['api_token']).to eq Testing::API_TOKEN
      expect(me['email']).to eq Testing::USERNAME
    end

    it 'raises error if .toggl file is missing' do
      expect{ toggl = TogglV8::API.new }.to raise_error(RuntimeError)
    end

  end
end