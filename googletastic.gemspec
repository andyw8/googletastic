# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{googletastic}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lance Pollard"]
  s.date = %q{2010-03-22}
  s.description = %q{Googletastic: A New Way of Googling}
  s.email = %q{lancejpollard@gmail.com}
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["README.textile", "Rakefile", "lib/googletastic", "lib/googletastic/access_rule.rb", "lib/googletastic/album.rb", "lib/googletastic/analytics.rb", "lib/googletastic/app_engine.rb", "lib/googletastic/apps.rb", "lib/googletastic/attendee.rb", "lib/googletastic/base.rb", "lib/googletastic/calendar.rb", "lib/googletastic/comment.rb", "lib/googletastic/document.rb", "lib/googletastic/event.rb", "lib/googletastic/ext", "lib/googletastic/ext/file.rb", "lib/googletastic/ext/pretty_print.xsl", "lib/googletastic/ext/xml.rb", "lib/googletastic/ext.rb", "lib/googletastic/form.rb", "lib/googletastic/group.rb", "lib/googletastic/helpers", "lib/googletastic/helpers/document.rb", "lib/googletastic/helpers/event.rb", "lib/googletastic/helpers/form.rb", "lib/googletastic/helpers.rb", "lib/googletastic/image.rb", "lib/googletastic/mixins", "lib/googletastic/mixins/actions.rb", "lib/googletastic/mixins/attributes.rb", "lib/googletastic/mixins/finders.rb", "lib/googletastic/mixins/namespaces.rb", "lib/googletastic/mixins/parsing.rb", "lib/googletastic/mixins/requesting.rb", "lib/googletastic/mixins.rb", "lib/googletastic/person.rb", "lib/googletastic/row.rb", "lib/googletastic/spreadsheet.rb", "lib/googletastic/sync", "lib/googletastic/sync/document.rb", "lib/googletastic/sync/form.rb", "lib/googletastic/sync.rb", "lib/googletastic/table.rb", "lib/googletastic/thumbnail.rb", "lib/googletastic/worksheet.rb", "lib/googletastic/youtube.rb", "lib/googletastic.rb", "spec/benchmarks", "spec/benchmarks/document_benchmark.rb", "spec/config.yml", "spec/fixtures", "spec/fixtures/data", "spec/fixtures/data/basic.txt", "spec/fixtures/data/calendar.list.xml", "spec/fixtures/data/doc_as_html.html", "spec/fixtures/data/doc_as_html_html.html", "spec/fixtures/data/doclist.xml", "spec/fixtures/data/document.single.xml", "spec/fixtures/data/Doing business in the eMarketPlace.doc", "spec/fixtures/data/end.xml", "spec/fixtures/data/event.list.xml", "spec/fixtures/data/form.html", "spec/fixtures/data/group.list.xml", "spec/fixtures/data/person.list.xml", "spec/fixtures/data/photo.list.xml", "spec/fixtures/data/sample_upload.mp4", "spec/fixtures/data/spreadsheet.list.xml", "spec/fixtures/models", "spec/fixtures/models/document.rb", "spec/fixtures/models/event.rb", "spec/fixtures/models/form.rb", "spec/fixtures/models/test_model.rb", "spec/fixtures/results", "spec/fixtures/results/test.txt", "spec/googletastic", "spec/googletastic/access_rule_spec.rb", "spec/googletastic/album_spec.rb", "spec/googletastic/app_engine_spec.rb", "spec/googletastic/base_spec.rb", "spec/googletastic/calendar_spec.rb", "spec/googletastic/document_spec.rb", "spec/googletastic/event_spec.rb", "spec/googletastic/form_spec.rb", "spec/googletastic/group_spec.rb", "spec/googletastic/image_spec.rb", "spec/googletastic/person_spec.rb", "spec/googletastic/post_spec.rb", "spec/googletastic/spreadsheet_spec.rb", "spec/googletastic/youtube_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/viatropos/googletastic}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{googletastic}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{More than Syncing Rails Apps with the Google Data API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_runtime_dependency(%q<activerecord>, [">= 2.3.5"])
      s.add_runtime_dependency(%q<gdata>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_dependency(%q<activerecord>, [">= 2.3.5"])
      s.add_dependency(%q<gdata>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 2.3.5"])
    s.add_dependency(%q<activerecord>, [">= 2.3.5"])
    s.add_dependency(%q<gdata>, [">= 0"])
  end
end
