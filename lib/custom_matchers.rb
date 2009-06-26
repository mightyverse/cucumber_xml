# (c) 2009 Mightyverse, Inc.  Use is subject to license terms.
module CustomMatchers

  class XmlSubsetMatcher
    def initialize(superset)
      @superset = Nokogiri::XML(superset, nil, "UTF-8", Nokogiri::XML::PARSE_RECOVER | Nokogiri::XML::PARSE_NSCLEAN)
      @error = ''
    end
    def matches?(subset)
      @subset = Nokogiri::XML(subset, nil, "UTF-8", Nokogiri::XML::PARSE_RECOVER | Nokogiri::XML::PARSE_NSCLEAN)
      compare_node(@subset, @superset)
    end
    def failure_message_for_should
      "expected #{@subset.inspect} to be a subset of #{@superset}, error: #{@error}"
    end
    def failure_message_for_should_not
      "expected #{@subset.inspect} not to be a subset of #{@superset}, error: #{@error}"
    end

    private
    def compare_node(subset_node, superset_node)
      return false if subset_node.nil? && !superset_node.nil?
      return false if superset_node.nil? && !subset_node.nil?
      return true if subset_node.comment?
      if superset_node.type != subset_node.type
        @error = "Node types mismatched, subset_node='#{subset_node.inspect}', superset_node='#{superset_node.inspect}'"
        return false
      end
      if is_text?(subset_node, superset_node)
        eql = content_eql?(subset_node, superset_node)
        @error = "Content of subset node '#{subset_node.content}' does not match that of superset node '#{superset_node}'" unless eql
        return eql
      else
        is_match = true
        if is_element?(subset_node, superset_node)
          is_match = name_eql?(subset_node, superset_node)
          @error = "Node name of subset node '#{subset_node.inspect}' does not match that of superset node '#{superset_node.inspect}'" unless is_match
        end
        is_match &&= subset_node.children.all? do |subset_child|
          matching_node = superset_node.children.detect do |superset_child|
            compare_node(subset_child, superset_child)
          end
          @error = "----------------> Subtree mismatch due to: " + @error if matching_node.nil?
          compare_node(subset_child, matching_node)
        end
        is_match
      end
    end

    def is_text?(a,b)
      a.text? && b.text?
    end
    def content_eql?(a,b) # strip whitespace from beginning & end of content prior to comparing it
      a.content.strip == b.content.strip
    end
    def is_element?(a,b)
      a.element? && b.element?
    end
    def name_eql?(a,b)
      a.node_name == b.node_name
    end
  end


  def be_xml_subset_of(expected)
    XmlSubsetMatcher.new(expected)
  end
end
