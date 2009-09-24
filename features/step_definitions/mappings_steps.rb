Given /^a mapping exists for '(.*)' to '(.*)' with tag '(.*)'$/ do |source, target, mapping_tag|
  @direction = {:from => source.to_sym, :to => target.to_sym}
  @tag = mapping_tag
  
  case @direction
  when {:from => :xml, :to => :hash}
  str = <<-EOT
    define :#{@tag} do
      direction :from => :xml, :to => :hash

      map :from => "foo/bar", :to => "bar/foo"
      map :from => "foo/baz", :to => "bar/boo"
      map :from => "foo/cuk/coo", :to => "foo/bar/coo"
      map :from => "foo/cuk/doo", :to => "doo"
    end
EOT
  Ptolemy::Mapper.load_str(str)
  when {:from => :hash, :to => :xml}
  str = <<-EOT
    define :#{@tag} do
      direction :from => :hash, :to => :xml

      map :from => "foo/bar", :to => "bar/foo"
      map :from => "foo/baz", :to => "bar/boo"
      map :from => "foo/cuk/coo", :to => "bar/cuk/coo"
      map :from => "foo/cuk/doo", :to => "bar/cuk/doo"
    end
EOT
  Ptolemy::Mapper.load_str(str)
  when {:from => :hash, :to => :hash}
  str = <<-EOT
    define :#{@tag} do
      direction :from => :hash, :to => :hash

      map :from => "foo", :to => "zoo"
      map :from => "bar", :to => "yoo"
      map :from => "baz", :to => "too"
      map :from => "boo", :to => "soo/roo"
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
      direction :from => :xml, :to => :hash

      map :from => "foo/bar", :to => "bar/foo"
      map(:from => "foo/baz", :to => "bar/boo").unless(:empty)
    end
EOT
  Ptolemy::Mapper.load_str(str)
 when /when/
  str = <<-EOT
    define :when do
      direction :from => :xml, :to => :hash

      map(:from => "foo/bar", :to => "bar/foo").when do |value|
        value =~ /hubba/
      end 
      map(:from => "foo/baz", :to => "bar/boo").when do |value|
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
    direction :from => :xml, :to => :hash

    map(:from => "event/decision_request/target_factors/institutions", :to => "event/new_update_status_code").customize do |node|
      node.concatenate_children("|")
    end
  end
EOT
  Ptolemy::Mapper.load_str(str)
end

Given /^a customized mapping exists for '(.*)' to '(.*)' with tag '(.*)'$/ do |source, target, tag|
  @mapping_tag = tag
  @direction = ":from => #{source.to_sym}, :to => #{target.to_sym}"

  case @direction
  when {:from => :xml, :to => :hash}
    str = <<-EOT
    define :#{@mapping_tag} do
      direction #{@direction}
      
      map(:from => "event/progress/statuses", :to => "event/new_update_status_code").customize do |node|
        res = []
        node.elements.map { |nd| res << {"name" => nd.child_content("code"), "text" => nd.child_content("message")} }
        res
      end
    end 
EOT
  Ptolemy::Mapper.load_str(str)
  when {:from => :hash, :to => :xml}
    str = <<-EOT
    define :#{@mapping_tag} do
      direction #{@direction}
      
      map(:from => "event/rankings", :to => "event/response").customize do |val|
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
    direction :from => :xml, :to => :hash
    
    map(:from => "event/progress/statuses", :to => "event/new_update_status_code").customize do |node|
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
    direction :from => :xml, :to => :hash

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
    direction :from => :hash, :to => :hash

    map :from => "foo", :to => "zoo"
    map :from => "bar", :to => "yoo"
  end

  define :include_another_map do
    direction :from => :hash, :to => :hash

    include :another_map
    map :from => "baz", :to => "too"
    map :from => "boo", :to => "soo/roo"
  end
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a contact mapping exists with nested include$/ do
  str = <<-EOT
  define :a_sample_person do
    direction :from => :hash, :to => :hash

    map :from => "name/first", :to => "first_name"
    map :from => "name/last", :to => "last_name"
  end

  define :a_sample_contact do
    direction :from => :hash, :to => :hash

    include :a_sample_person, :inside_of => "contact"
    map :from => "contact/phone/home", :to => "contact/home_phone"
  end
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a mapping exists with prepopulate method$/ do
  str = <<-EOT
  define :api do
    direction :from => :hash, :to => :xml

    prepopulate("event/api_version").with("2.0.1")
    map :from => "name/first", :to => "event/first_name"
    map :from => "name/last", :to => "event/last_name"
  end
EOT

  Ptolemy::Mapper.load_str(str)
end

Given /^a '(\w+)' mapping exists within namespace '(\w+)'$/ do |definition, namespace|
  @namespace = namespace

  str = <<-EOT
    namespace :#{@namespace} do

      define :#{definition} do
        direction :from => :hash, :to => :xml

        map :from => "name/first", :to => "event/first_name"
        map :from => "name/last", :to => "event/last_name"
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
  when {:from => :xml, :to => :hash}
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
  when {:from => :hash, :to => :xml}
    source = {:foo => {:bar => "a", :baz => "b", :cuk => {:coo => "c", :doo => "d"}}}
    @translation = Ptolemy::Mapper.translate(@tag.to_sym, source)
  when {:from => :hash, :to => :hash}
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
  when {:from => :xml, :to => :hash}
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
  when {:from => :hash, :to => :xml}
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

When /^the mapping with namespace 'sales' is translated$/ do
  hash = {:name => {:first => "Chris", :last => "Wyckoff"}}
  @translation = Ptolemy::Mapper.translate_namespace(:sales, :contact, hash)
end



#
##
###
Then /^the xml should be correctly mapped$/ do
  case @direction
  when {:from => :xml, :to => :hash}
    @translation.should == {"doo"=>"d", "foo"=>{"bar"=>{"coo"=>"c"}}, "bar"=>{"boo"=>"b", "foo"=>"a"}}
  when {:from => :hash, :to => :xml}
    @translation.to_s.gsub(/\s/, '').should == '<?xmlversion="1.0"encoding="UTF-8"?><bar><foo>a</foo><boo>b</boo><cuk><coo>c</coo><doo>d</doo></cuk></bar>'    
  when {:from => :hash, :to => :hash}
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
  when {:from => :xml, :to => :hash}
    translation = {"event"=>{"new_update_status_code"=>[{"name"=>"Abandoned", "text"=>"bad phone"}, {"name"=>"Rejected", "text"=>"bad word"}]}}
    @translation.should == translation
  when {:from => :hash, :to => :xml}
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
