Given /^a mapping exists for '(.*)' to '(.*)' with tag '(.*)'$/ do |source, target, mapping_tag|
  @direction = {source => target}
  @tag = mapping_tag
  
  case @direction
  when {"xml", "hash"}
  str = <<-EOT
    define :#{@tag} do
      direction "xml" => "hash"

      map "foo/bar" => "bar/foo"
      map "foo/baz" => "bar/boo"
      map "foo/cuk/coo" => "foo/bar/coo"
      map "foo/cuk/doo" => "doo"
    end
EOT
  Ptolemy::Mapper.load_str(str)
  when {"hash" => "xml"}
  str = <<-EOT
    define :#{@tag} do
      direction "hash" => "xml"

      map "foo/bar" => "bar/foo"
      map "foo/baz" => "bar/boo"
      map "foo/cuk/coo" => "bar/cuk/coo"
      map "foo/cuk/doo" => "bar/cuk/doo"
    end
EOT
  Ptolemy::Mapper.load_str(str)
  when {"hash" => "hash"}
  str = <<-EOT
    define :#{@tag} do
      direction "hash" => "hash"

      map "foo" => "zoo"
      map "bar" => "yoo"
      map "baz" => "too"
      map "boo" => "soo/roo"
    end
EOT
  Ptolemy::Mapper.load_str(str)
  end
end

Given /^a mapping exists with '(.*)' condition$/ do |condition|
  case condition
  when /unless/
  str = <<-EOT
    define :ignore do
      direction "xml" => "hash"

      map "foo/bar" => "bar/foo"
      map("foo/baz" => "bar/boo").unless(:empty)
    end
EOT
  Ptolemy::Mapper.load_str(str)
 when /when/
  str = <<-EOT
    define :when do
      direction "xml" => "hash"

      map("foo/bar" => "bar/foo").when do |value|
        value =~ /hubba/
      end 
      map("foo/baz" => "bar/boo").when do |value|
        value =~ /bubba/
      end 
    end
EOT
  Ptolemy::Mapper.load_str(str)
  end
end

Given /^a mapping exists with concatenation$/ do
  str = <<-EOT
  define :concatenation do
    direction "xml" => "hash"

    map("event/decision_request/target_factors/institutions" => "event/new_update_status_code").customize do |node|
      node.concatenate_children("|")
    end
  end
EOT
  Ptolemy::Mapper.load_str(str)
end

Given /^a customized mapping exists for '(.*)' to '(.*)' with tag '(.*)'$/ do |source, target, tag|
  @mapping_tag = tag
  @direction = "#{source.to_sym} => #{target.to_sym}"

  case @direction
  when {"xml" => "hash"}
    str = <<-EOT
    define :#{@mapping_tag} do
      direction #{@direction}
      
      map("event/progress/statuses" => "event/new_update_status_code").customize do |node|
        res = []
        node.elements.map { |nd| res << {"name" => nd.child_content("code"), "text" => nd.child_content("message")} }
        res
      end
    end 
EOT
  Ptolemy::Mapper.load_str(str)
  when {"hash" => "xml"}
    str = <<-EOT
    define :#{@mapping_tag} do
      direction #{@direction}
      
      map("event/rankings" => "event/response").customize do |val|
        node = new_node("rankings") do |rankings|

          val.each do |rnk|
            rankings << new_node("ranking") do |ranking|

              ranking << new_node("rank", rnk["ranking"]["rank"])
              ranking << new_node("value", rnk["ranking"]["value"])

              ranking << new_node("rules") do |rules|
                rnk["ranking"]["rules"].each do |rl| 
                  rule = new_node("rule") << rl["rule"]
                  rules << rule
                end 
              end 

              ranking << new_node("potential_event") do |potential_event|
                rnk["ranking"]["potential_event"].each do |e| 
                  institution = new_node("institutions") << e["institutions"]
                  potential_event << institution
                end 
              end 

            end 

          end 
        end 
      end
    end 
EOT

  Ptolemy::Mapper.load_str(str)
  end 
end

Given /^a mapping exists with a customized block$/ do
  str = <<-EOT
  define :customized do
    direction "xml" => "hash"
    
    map("event/progress/statuses" => "event/new_update_status_code").customize do |node|
      res = []
      node.elements.map { |nd| res << {"name" => nd.child_content("code"), "text" => nd.child_content("message")} }
      res
    end
  end 
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a mapping exists with custom \.to method$/ do
  str = <<-EOT
  define :custom_to do
    direction "xml" => "hash"

    from("foo/bar").to do |value|
      if(value == "baz")
        "value/was/baz"
      else 
        "value/was/not/baz"
      end 
    end
  end 
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a mapping exists with include$/ do
  str = <<-EOT
  define :another_map do
    direction "hash" => "hash"

    map "foo" => "zoo"
    map "bar" => "yoo"
  end

  define :include_another_map do
    direction "hash" => "hash"

    include :another_map
    map "baz" => "too"
    map "boo" => "soo/roo"
  end
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a contact mapping exists with nested include$/ do
  str = <<-EOT
  define :a_sample_person do
    direction "hash" => "hash"

    map "name/first" => "first_name"
    map "name/last" => "last_name"
  end

  define :a_sample_contact do
    direction "hash" => "hash"

    include :a_sample_person, :inside_of => "contact"
    map "contact/phone/home" => "contact/home_phone"
  end
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a mapping exists with prepopulate method$/ do
  str = <<-EOT
  define :api do
    direction "hash" => "xml"

    prepopulate("event/api_version").with("2.0.1")
    map "name/first" => "event/first_name"
    map "name/last" => "event/last_name"
  end
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a '(\w+)' mapping exists within namespace '(\w+)'$/ do |definition, namespace|
  @namespace = namespace

  str = <<-EOT
    namespace :#{@namespace} do

      define :#{definition} do
        direction "hash" => "xml"

        map "name/first" => "event/first_name"
        map "name/last" => "event/last_name"
      end

    end 
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a nested mapping '(\w+)' exists within namespace '(\w+)'$/ do |nested_namespace, namespace|
  @namespace = namespace

  str = <<-EOT
    namespace :#{@namespace} do
      namespace :#{nested_namespace} do
        define :contact do
          direction "hash" => "xml"
  
          map "name/first" => "event/first_name"
          map "name/last" => "event/last_name"
        end
      end
    end 
EOT

  Ptolemy::Mapper.load_str(str)
end


#
##
###
When /^the mapping is translated$/ do
  case @direction
  when {"xml" => "hash"}
    xml = <<-EOL
<foo>
 <bar>a</bar>
 <baz>b</baz>
 <cuk>
  <coo>c</coo>
  <doo>d</doo>
 </cuk>
</foo>
EOL
    @translation = Ptolemy::Mapper.translate(@tag.to_sym, xml)
  when {"hash" => "xml"}
    source = {:foo => {:bar => "a", :baz => "b", :cuk => {:coo => "c", :doo => "d"}}}
    @translation = Ptolemy::Mapper.translate(@tag.to_sym, source)
  when {"hash" => "hash"}
    source = {:foo => "a", :bar => "b", :baz => "c", :boo => "d"}
    @translation = Ptolemy::Mapper.translate(@tag.to_sym, source)
  end
end

When /^the '(.*)' mapping is translated$/ do |condition|
  case condition
  when /unless/
    xml = '<foo><bar>a</bar><baz></baz></foo>'
    @translation = Ptolemy::Mapper.translate(:ignore, xml)
  when /when/
    xml = '<foo><bar>cuk</bar><baz>hubbabubba</baz></foo>'
    @translation = Ptolemy::Mapper.translate(:when, xml)
  end
end

When /^the mapping with concatenation is translated$/ do
#  xml = '<foo><bar>a</bar><baz>b</baz><cuk><coo>c</coo><coo>d</coo><coo>e</coo></cuk></foo>' 
  xml = <<-EOL
<event>
 <decision_request>
 <target_factors>
  <institutions>
   <institution>FOO</institution>
   <institution>BAR</institution>
   <institution>BAZ</institution>
  </institutions>
 </target_factors>
 </decision_request>
</event>
EOL
  @translation = Ptolemy::Mapper.translate(:concatenation, xml)
end

When /^the customized mapping is translated$/ do
#  xml = '<foo><bar>baz</bar><cuk>coo</cuk></foo>'
#  xml = '<statuses><status><code>Abandoned</code><message>bad phone</message></status><status><code>Rejected</code><message>bad word</message></status></statuses>'
  case @direction
  when {"xml" => "hash"}
    xml = <<-EOL
<event>
 <progress>
  <statuses>
   <status>
    <code>Abandoned</code>
    <message>bad phone</message>
   </status>
   <status>
    <code>Rejected</code>
    <message>bad word</message>
   </status>
  </statuses>
 </progress>
</event>
EOL
    @translation = Ptolemy::Mapper.translate(@mapping_tag.to_sym, xml)
  when {"hash" => "xml"}
    hash = 
    { "event" => 
      {"rankings"=>
        [
         {"ranking"=>{
             "rules"=> [
                        {"rule"=>"pace_adjusted_revenue"}
                       ], 
             "rank"=>1, 
             "value"=>0.0, 
             "potential_event"=>[{"institutions"=>"AcmeU"}]
           }
         },
         {"ranking"=> {"rules"=>
             [
              {"rule"=>"clipped"}
             ], 
             "rank"=>2, 
             "value"=>0.0, 
             "potential_event"=>[{"institutions"=>"BraUn"}]
           }
         }
        ],
        "decision_point"=>"LMP_Insti"
      }
    }      
    @translation = Ptolemy::Mapper.translate(@mapping_tag.to_sym, hash)
  end 
end

When /^the mapping with custom \.to method is translated$/ do
  xml = "<foo><bar>baz</bar></foo>"
  @translation = Ptolemy::Mapper.translate(:custom_to, xml)
end

When /^the mapping with include is translated$/ do
  hash = {:foo => "Dave", :bar => "Brady", :baz => "Liz", :boo => "Brady"}
  @translation = Ptolemy::Mapper.translate(:include_another_map, hash)
end

When /^the mapping with nested include is translated$/ do
  hash = {:contact => {:name => {:first => "Dave", :last => "Brady"}, :phone => {:home => "1231231234"}}}
  @translation = Ptolemy::Mapper.translate(:a_sample_contact, hash)
end

When /^the mapping with prepopulate method is translated$/ do
  hash = {:name => {:first => "Dave", :last => "Brady"}}
  @translation = Ptolemy::Mapper.translate(:api, hash)
end

When /^the mapping is reversed$/ do
  xml = <<-EOL
<bar>
 <foo>a</foo>
 <boo>b</boo>
 <cuk>
  <coo>c</coo>
  <doo>d</doo>
 </cuk>
</bar>
EOL
  @translation = Ptolemy::Mapper.reverse(@tag.to_sym, xml)
end

When /^the mapping with namespace '(\w+)' is translated$/ do |namespace|
  hash = {:name => {:first => "Chris", :last => "Wyckoff"}}
  @translation = Ptolemy::Mapper.translate_namespace(namespace.to_sym, hash)
end

When /^the '(\w+)' mapping with nested namespace '(\w+)' is translated$/ do |namespace, nested_namespace|
  hash = {:name => {:first => "Chris", :last => "Wyckoff"}}
  @translation = Ptolemy::Mapper.translate_namespace(namespace.to_sym, hash)
end



#
##
###
Then /^the target should be correctly mapped$/ do
  case @direction
  when {"xml" => "hash"}
    @translation.should == {"doo"=>"d", "foo"=>{"bar"=>{"coo"=>"c"}}, "bar"=>{"boo"=>"b", "foo"=>"a"}}
  when {"hash" => "xml"}
    @translation.to_s.gsub(/\s/, '').should == '<?xmlversion="1.0"encoding="UTF-8"?><bar><foo>a</foo><boo>b</boo><cuk><coo>c</coo><doo>d</doo></cuk></bar>'    
  when {"hash" => "hash"}
    @translation.should == {"zoo" => "a", "yoo" => "b", "too" => "c", "soo" => {"roo" => "d"}}
  end
end

Then /^the target should be correctly processed for condition '(.*)'$/ do |condition|
  case condition
  when /unless/
    @translation.should == {"bar" => {"foo" => "a"}}
  when /when/
    @translation.should == {"bar" => {"boo" => "hubbabubba"}}
  end 
end

Then /^the target should be properly concatenated$/ do
  @translation.should == {"event"=>{"new_update_status_code"=>"FOO|BAR|BAZ"}}
#  @translation.should == {"foo"=>{"bar"=>"c|d|e"}}
end

Then /^the customized target should be correctly processed$/ do
  case @direction
  when {"xml" => "hash"}
    translation = {"event"=>{"new_update_status_code"=>[{"name"=>"Abandoned", "text"=>"bad phone"}, {"name"=>"Rejected", "text"=>"bad word"}]}}
    @translation.should == translation
  when {"hash" => "xml"}
 translation = <<-EOL
<?xml version="1.0" encoding="UTF-8"?>
<event>
  <response>
    <rankings>
      <ranking>
        <rank>1</rank>
        <value>0.0</value>
        <rules>
          <rule>pace_adjusted_revenue</rule>
        </rules>
        <potential_event>
          <institutions>AcmeU</institutions>
        </potential_event>
      </ranking>
      <ranking>
        <rank>2</rank>
        <value>0.0</value>
        <rules>
          <rule>clipped</rule>
        </rules>
        <potential_event>
          <institutions>BraUn</institutions>
        </potential_event>
      </ranking>
    </rankings>
  </response>
</event>
EOL
    @translation.to_s.should == translation
  end 

#  @translation.should == {"new_update_status_code"=>[{"name"=>"Abandoned", "text"=>"bad phone"}, {"name"=>"Rejected", "text"=>"bad word"}]}
#  @translation.should == {"boo" => [{"bum" => "baz", "dum" => "coo"}]}
end

Then /^the target should be correctly processed for custom \.to conditions$/ do
#  xml = "<foo><bar>baz</bar></foo>"
  @translation.should == { "value" => { "was" => { "baz" => "baz"}}}
end

Then /^the target should have mappings included from different map$/ do
  @translation.should == {"zoo" => "Dave", "yoo" => "Brady", "too" => "Liz", "soo" => { "roo" => "Brady"}}
end

Then /^the target should have nested mappings included from different map$/ do
  @translation.should == {"contact" => { "first_name" => "Dave", "last_name" => "Brady", "home_phone" => "1231231234"}}
end

Then /^the target should be correctly processed prepopulate conditions$/ do
  xml = <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<event>
  <api_version>2.0.1</api_version>
  <first_name>Dave</first_name>
  <last_name>Brady</last_name>
</event>
EOT

  @translation.to_s.should == xml
end

Then /^the target should be correctly processed$/ do
  xml = <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<event>
  <first_name>Chris</first_name>
  <last_name>Wyckoff</last_name>
</event>
EOT

  @translation.to_s.should == xml
end

Then /^the target should be correctly reversed$/ do
  hash = {"foo" => {"bar" => "a", "baz" => "b", "cuk" => {"coo" => "c", "doo" => "d"}}}
  @translation.should == hash
end
