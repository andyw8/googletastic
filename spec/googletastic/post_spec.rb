require File.expand_path("./spec/spec_helper")

describe Googletastic do
  
=begin
  before(:all) do
    @email = "flexinstyle@gmail.com"
    @password = "flexyflexy"
    @blog_id = 178484585982103126
    @path = "http://www.blogger.com/feeds/#{@blog_id}/posts/full"
  end
  
  it "should get a list of blog posts from viatropos.blogspot.com" do
    client = GData::Client::Blogger.new
    client.clientlogin(@email, @password)
    #puts client.get(@path).to_xml()
    #puts Thing::Google::Document.view(nil, nil).to_xml
  end
  
  it "should post a post to blogger" do
    client = GData::Client::Blogger.new
    client.clientlogin(@email, @password)
    post = <<-eof
    <entry xmlns='http://www.w3.org/2005/Atom'>
      <title type='text'>Marriage!</title>
      <content type='xhtml'>
        <div xmlns="http://www.w3.org/1999/xhtml">
          <p>Mr. Darcy has <em>proposed marriage</em> to me!</p>
          <p>He is the last man on earth I would ever desire to marry.</p>
          <p>Whatever shall I do?</p>
        </div>
      </content>
      <category scheme="http://www.blogger.com/atom/ns#" term="marriage" />
      <category scheme="http://www.blogger.com/atom/ns#" term="Mr. Darcy" />
    </entry>
    eof
    #post = client.post(@path, post)
    #post = client.get(@path).to_xml.xpath("//atom:entry", {'atom' => ATOM_NS}).first
    #puts post.to_xml
  end
=end  
  after(:each) do

  end
  
end