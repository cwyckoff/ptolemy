require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Ptolemy

  PTOLEMY_STR = <<-EOT
   define "baz" do
    direction :from => :hash, :to => :xml

    map :from => "name/first", :to => "event/first_name"
    map :from => "name/last", :to => "event/last_name"
  end
EOT

  describe "Mapper" do

    before(:each) do
      Mapper.reset
    end

    describe ".define" do

      before(:each) do
        @definition_mapper = mock("DefinitionMapper", :name => "test")
        DefinitionMapper.stub!(:new).and_return(@definition_mapper)
      end
      
      it "should register definition" do
        # when
        Mapper.define(:foo) { }

        # expect
        Mapper.definitions.should == {:foo => @definition_mapper}
      end 

      it "should delegate to DefinitionMapper" do
        # expect
        DefinitionMapper.should_receive(:new)

        # when
        Mapper.define(:foo) { }
      end

      it "should instance eval any block passed to it on the DefinitionMapper object" do
        # expect
        @definition_mapper.should_receive(:instance_eval)
        
        # when
        Mapper.define(:foo) { }
      end
      
      describe "when a mapping key already exists" do 
        
        it "should raise an error" do 
          # given
          Mapper.define(:bar) { }
          
          # expect
          running { Mapper.define(:bar) {} }.should raise_error(MapperError, "A mapping for the key bar currently exists.")
        end
      end
      
    end

    describe "#directory" do

      it "should register directory of mapping files" do
        # given
        Mapper.map_directory = "/foo/bar"

        # expect
        Mapper.map_directory.should == "/foo/bar"
      end

    end 

    describe "#load_maps" do

      it "should read file contents as a string" do
        # given
        Dir.stub!(:glob).and_return(["boo.rb"])

        # expect
        File.should_receive(:read).with("boo.rb").and_return("")

        # when
        Mapper.load_maps
      end

      describe "if directory is empty" do

        it "should raise a LoadError" do
          # given
          Mapper.map_directory = "/foo/bar"
          Dir.stub!(:glob).and_return([])

          # expect
          running { Mapper.load_maps }.should raise_error(LoadError, "No maps defined for map directory /foo/bar.  Save mapping files to a directory and let Ptolemy know about it (e.g., Ptolemy::Mapper.map_directory = '/foo/bar')")
        end
        
      end
    end

    describe ".namespace" do

      before(:each) do
        @namespace_mapper = mock("NamespaceMapper", :name => "test")
        NamespaceMapper.stub!(:new).and_return(@namespace_mapper)
      end
      
      it "should register namespace" do
        # when
        Mapper.namespace(:foo) { }

        # expect
        Mapper.namespaces.should == {:foo => @namespace_mapper}
      end 
      
      it "should instance eval any block passed to it on the NamespaceMapper object" do
        # expect
        @namespace_mapper.should_receive(:instance_eval)
        
        # when
        Mapper.namespace(:foo) { }
      end
      
      it "should delegate to NamespaceMapper" do
        # expect
        NamespaceMapper.should_receive(:new)

        # when
        Mapper.namespace(:foo) { }
      end
      
      describe "when a mapping key already exists" do 
        
        it "should raise an error" do 
          pending
          # given
          Mapper.namespace(:bar) { }
          
          # expect
          running { Mapper.namespace(:bar) {} }.should raise_error(MapperError, "A mapping for the key bar currently exists.  Are you sure you want to merge the mapping you are about to do with the existing mapping?")
        end
      end
      
    end

    describe ".reset" do 

      before(:each) do
        Mapper.define(:foo) { }
        Mapper.namespace(:foo) { }
      end
      
      it "should reset definition mappings" do 
        # when
        Mapper.reset
        
        # expect
        Mapper.definitions.should == {}
      end

      it "should reset namespace mappings" do 
        # when
        Mapper.reset
        
        # expect
        Mapper.namespaces.should == {}
      end
    end
    
    describe ".translate" do 

      context "when translating a namespace" do

        it "should delegate to NamespaceMapper" do
          # given
          namespace_mapper = mock("NamespaceMapper")
          Mapper.namespaces[:foo] = namespace_mapper

          # expect
          namespace_mapper.should_receive(:translate).with(:bar, @xml)

          # when
          Mapper[:foo].translate(:bar, @xml)
        end

        describe "when no key exists for target mapper" do 
          
          it "should raise an error" do 
            # given
            namespace_mapper = NamespaceMapper.new
            Mapper.namespaces[:foo] = namespace_mapper

            running { Mapper[:foo].translate(:bar, @xml) }.should raise_error(MapperError, "No target mapper exists for key bar")
          end
        end
        
      end

      context "when translating a definition" do

        before(:each) do
          @definition_mapper = mock("DefinitionMapper", :direction => nil, :map => nil)
          DefinitionMapper.stub!(:new).and_return(@definition_mapper)
          Mapper.reset
          @xml = "<foo>bar</foo>"
        end

        it "should map target elements" do 
          # given
          definition_mapper = mock("DefinitionMapper")
          Mapper.definitions[:foo] = definition_mapper

          # expect
          definition_mapper.should_receive(:translate).with(@xml).and_return({})

          # when
          Mapper.translate(:foo, @xml)
        end
        
      end
      
      describe "when no key exists for target mapper" do 
        
        it "should raise an error" do 
          running { Mapper.translate(:bar, @xml) }.should raise_error(MapperError)
        end
      end
      
    end
    
  end

  describe DefinitionMapper do

    describe "#translate" do

      it "should delegate to MapDefinition object" do
        # given
        map_definition = MapDefinition.new
        definition_mapper = DefinitionMapper.new
        definition_mapper.definition = map_definition
        xml = "<foo>bar</foo>"

        # expect
        map_definition.should_receive(:translate).with(xml)

        # when
        definition_mapper.translate(xml)
      end
      
    end

  end 
  
  describe NamespaceMapper do

    describe "#translate" do

      it "should delegate to MapDefinition object" do
        # given
        map_definition = mock("MapDefinition")
        namespace_mapper = NamespaceMapper.new
        namespace_mapper.stub!(:definitions).and_return({:bar => map_definition})
        xml = "<foo>bar</foo>"

        # expect
        map_definition.should_receive(:translate).with(xml)

        # when
        namespace_mapper.translate(:bar, xml)
      end

    end

  end 
end
