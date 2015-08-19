require 'fileutils'

describe 'Toggl::V8' do
  it 'initializes with api_token' do
    toggl = Toggl::V8.new(Testing::API_TOKEN)
    me = toggl.me
    expect(me).to_not be nil
    expect(me['api_token']).to eq Testing::API_TOKEN
    expect(me['email']).to eq Testing::USERNAME
  end

  it 'initializes with username and password' do
    toggl = Toggl::V8.new(Testing::USERNAME, Testing::PASSWORD)
    me = toggl.me
    expect(me).to_not be nil
    expect(me['api_token']).to eq Testing::API_TOKEN
    expect(me['email']).to eq Testing::USERNAME
  end

  it 'does not initialize with bogus api_token' do
    toggl = Toggl::V8.new('4880nqor1orr9n241sn08070q33oq49s')
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

      toggl = Toggl::V8.new
      me = toggl.me
      expect(me).to_not be nil
      expect(me['api_token']).to eq Testing::API_TOKEN
      expect(me['email']).to eq Testing::USERNAME
    end

    it 'raises error if .toggl file is missing' do
      expect{ toggl = Toggl::V8.new }.to raise_error(RuntimeError)
    end

  end
end