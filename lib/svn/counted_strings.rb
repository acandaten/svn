require 'rubygems'
require 'ffi'

module Svn #:nodoc:

  # a struct for interacting with svn_string_t values
  class CountedString < FFI::Struct

    layout(
        # because the data may not be NULL-terminated, treat it as a pointer
        # and always read the string contents with FFI::Pointer#read_string
        :data, :pointer,
        :length, :size_t
      )

    # returns a new ruby String with the CountedString's contents.
    def to_s
      return nil if null?
      self[:data].read_string( self[:length] )
    end

    def inspect
      to_s.inspect
    end

    def self.from_string( content)
      return content if content.is_a? CountedString
      cstr = CountedString.new
      cstr[:data] = FFI::MemoryPointer.from_string( content )
      cstr[:length] = content.size
      cstr
    end

  end

  # the svn_string_t pointer type, which is the one used externally
  # class CountedString < CountedStringStruct.by_ref
  # end

  # CountedString.define_singleton_method(:from_string) do |content|
  #   return content if content.is_a? CountedStringStruct
  #   cstr = CountedStringStruct.new
  #   cstr[:data] = FFI::MemoryPointer.from_string( content )
  #   cstr[:length] = content.size
  #   cstr
  # end

  # def CountedString.from_string( content )
  #   return content if content.is_a? CountedStringStruct
  #   cstr = CountedStringStruct.new
  #   cstr[:data] = FFI::MemoryPointer.from_string( content )
  #   cstr[:length] = content.size
  #   cstr
  # end

end
