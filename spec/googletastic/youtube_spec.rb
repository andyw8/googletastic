require File.expand_path("./spec/spec_helper")
=begin
describe Thing::Google::YouTube do
  
  VIDEOS = "http://gdata.youtube.com/feeds/api/videos" unless defined?(VIDEOS)
  
  before(:each) do
    @yt = GData::Client::YouTube.new
    @keys = Thing::Google.credentials
    @yt.developer_key = @keys[:youtube_dev_key]
    @yt.clientlogin(@keys[:youtube_login], @keys[:password])
  end
  
  def metadata
    data = <<EOF
<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:yt="http://gdata.youtube.com/schemas/2007">
  <media:group>
    <media:title type="plain">Bad Wedding Toast</media:title>
    <media:description type="plain">
      I gave a bad toast at my friend's wedding.
    </media:description>
    <media:category scheme="http://gdata.youtube.com/schemas/2007/categories.cat">People</media:category>
    <media:keywords>toast, wedding</media:keywords>
  </media:group>
</entry>
EOF
  end
  
  it "should get a list of videos from youtube" do
    pending
    response = @yt.get(Thing.paramify_url(VIDEOS, {:q => "dan tocchini"}))
    response = response.to_xml.xpath("//atom:entry", {'atom' => ATOM_NS}).first.to_xml
    puts "response! " + response.inspect    
  end
  
  it "should upload video metadata to youtube" do
    url = File.join(Thing::Google::YouTube::API, Thing::Google::YouTube::GET_UPLOAD_TOKEN)
    #response = @yt.post(url, metadata).to_xml
    #puts response.to_xml
  end
  
  it "should upload the actual video to youtube" do
    url = File.join(Thing::Google::YouTube::UPLOAD, @keys[:youtube_login], "uploads")
    puts url
    mime_type = Thing::Google::YouTube::MULTIPART
    response = @yt.post_file(url, File.join(FIXTURES_DIR, "sample_upload.mp4"), mime_type).to_xml
    puts response.to_xml
  end
  
  after(:each) do
    
  end
  
end
=end    
