require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Ptolemy

  describe "factories" do

    before(:all) do 
      @direction = {"xml" => "hash"}
      @xml_map = mock("XmlMap")
      @hash_map = mock("HashMap")
      @path_translator = mock("PathTranslator")
      PathTranslator.stub!(:new).and_return(@path_translator)
    end

    describe MapFactory do 
      
      describe ".source" do 

        describe "when source is xml" do 
          
          it "should instantiate XmlMap" do 
            # expect
            XmlMap.should_receive(:new).with(@path_translator, {"foo/bar" => "bar/foo"}).and_return(@xml_map)

            # given
            MapFactory.source(@direction, {"foo/bar" => "bar/foo"})
          end
        end

        describe "when source is hash" do 
          
          it "should instantiate HashMap" do 
            # expect
            HashMap.should_receive(:new).with(@path_translator, {"bar/foo" => "foo/bar"}).and_return(@hash_map)

            # given
            MapFactory.source({"hash" => "xml"}, {"bar/foo" => "foo/bar"})
          end
          
        end
      end 
      
      describe ".target" do 

        describe "when target is hash" do 
          
          it "should instantiate HashMap" do 
            path_translator = mock("PathTranslator")
            xml_map = mock("XmlMap")

            # expect
            HashMap.should_receive(:new).with(@path_translator, {"foo/bar" => "bar/foo"}).and_return(@hash_map)

            # given
            MapFactory.target(@direction, {"foo/bar" => "bar/foo"})
          end
          
        end

        describe "when target is xml" do 
          
          it "should instantiate XmlMap" do 
            path_translator = mock("PathTranslator")
            hash_map = mock("HashMap")

            # expect
            XmlMap.should_receive(:new).with(@path_translator, {"foo/bar" => "bar/foo"}).and_return(@xml_map)

            # given
            MapFactory.target({"hash" => "xml"}, {"foo/bar" => "bar/foo"})
          end
          
        end
        
      end
    end
  end 

  
  describe SourceProxy do

    before(:each) do
      @source_proxy = SourceProxy.new
    end

    describe ".filter_source" do

      it "should return source argument" do
        SourceProxy.filter_source("foo").should == "foo"
      end
      
    end

    describe "#path_translator" do

      it "should return path_translator object" do
        @source_proxy.path_translator.should be_an_instance_of(PathTranslator)
      end
      
    end

    describe "#value_from" do

      it "should return source_value" do
        # when
        @source_proxy.with("foo")

        # expect
        @source_proxy.value_from.should == "foo"
      end

    end 

    describe "#with" do
      
      it "should set argument as source variable" do
        # when
        @source_proxy.with("foo")

        # expect
        @source_proxy.value_from.should == "foo"
      end
      
    end
    
  end
end
