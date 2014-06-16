module Rocx
  module Elements
    class Ruby < Container
      attr_reader :base

      value_property :alignment, as: :phonetic_guide_alignment
      value_property :base_font_size, as: :phonetic_guide_base_font_size
      value_property :font_size, as: :phonetic_guide_font_size
      value_property :font_size_raise, as: :phonetic_guide_font_size_raise
      value_property :language, as: :phonetic_guide_language

      def base=(other)
        raise ArgumentError unless other.is_a?(Rocx::Elements::Run)
        @base = other
      end

      def to_xml(xml)
        xml[namespace].public_send(tag, xml_attributes) {
          property_xml(xml)
          base_text_xml(xml)
        }
      end

    private

      def base_text_xml(xml)
        xml["w"].rubyBase {
          base.to_xml(xml) if base
        }
      end

    end
  end
end
