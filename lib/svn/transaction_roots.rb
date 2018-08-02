require 'ffi'

module Svn #:nodoc:

  class TransactionRoot < Root

    class << self
      def release( ptr )
        # C.close_root( ptr )
      end
    end

    attr_reader :revision

    def initialize( ptr, revision )
      super( ptr )
      @revision = revision
      out = FFI::MemoryPointer.new( :pointer )
      Error.check_and_raise(
        C.txn_root(out, self, revision.pool)
      )
      @transaction_root = out
    end

    module C
      extend FFI::Library
      ffi_lib ['libsvn_fs-1', 'libsvn_fs-1.so.1']

      typedef :pointer, :out_pointer
      typedef Pool, :pool
      typedef CError.by_ref, :error
      typedef Root, :root
      typedef TransactionRoot, :txn
      typedef Stream, :stream
      typedef :long, :revnum
      typedef :string, :path
      typedef :string, :name
      typedef :string, :value
      typedef Repo::FileSystem, :fs
      typedef CountedString, :counted_string

      attach_function :change_node_prop,
          :svn_fs_change_node_prop,
          [ :root, :path, :name, :counted_string, :pool ],
          :error

      attach_function :txn_root,
          :svn_fs_txn_root,
          [ :out_pointer, :txn, :pool ],
          :error

      attach_function :abort,
          :svn_fs_abort_txn,
          [ :txn, :pool ],
          :error

      attach_function :commit,
          :svn_fs_commit_txn,
          [ :pointer, :pointer, :txn, :pool ],
          :error

      attach_function :txn_prop,
          :svn_fs_txn_prop,
          [ :out_pointer , :txn, :name, :pool ],
          :error

      attach_function :change_txn_prop,
          :svn_fs_change_txn_prop ,
          [ :txn, :name, :counted_string, :pool ],
          :error

      attach_function :apply_text,
          :svn_fs_apply_text ,
          [ :stream, :root, :path, :pointer, :pool ],
          :error

      attach_function :make_file,
          :svn_fs_make_file ,
          [ :root, :path, :pool ],
          :error

      attach_function :make_dir,
          :svn_fs_make_dir ,
          [ :root, :path, :pool ],
          :error
      # attach_function :txn_root,
      #     :svn_fs_txn_root,
      #     [ :out_pointer, :txn, :pool ],
      #     :error
    end

    # use the C module for all bound methods
    bind_to C
    # add_pool = Proc.new { |out, this, *args| ([ out, this ] + args) << revision.pool }

    # bind :change_prop_for, :to => :change_node_prop,
    #     :validate => Error.return_check,
    #     &add_pool

    def change_prop_for(path, name, value)
      c =  CountedString.from_string(value)
      Error.check_and_raise(
        C.change_node_prop(@transaction_root.read_pointer, path, name, CountedString.from_string(value), revision.pool)
      )
    end

    # def txn_prop(propname)
    #   # c = FFI::MemoryPointer.new( :pointer )
    #   c =  CountedString.from_string("")
    #   puts "c before: " + c.inspect
    #   Error.check_and_raise(
    #     C.txn_prop(c, self, propname, revision.pool)
    #   )
    #   puts "c after: " + c.inspect
    #   c.to_s
    # end
    bind( :txn_prop,
        :returning => CountedString,
        :before_return => :to_s,
        :validate => Error.return_check
      ) { |out, this, name| [ out, this, name, revision.pool ] }

    def make_file(path)
      case revision.check_path(path)
        when 1 then return
        when 2 then raise "Cannot make file '%f' as it is a directory" % path
        when 3 then raise "Known object '%s'" % path
      end
      make_dir(File.dirname(path))
      Error.check_and_raise(
        C.make_file(@transaction_root.read_pointer, path, revision.pool)
      )
    end

    def make_dir(path)
      case revision.check_path(path)
        when 2 then return
        when 1 then raise "Cannot make dir '%f' as it is a file" % path
        when 3 then raise "Known object '%s'" % path
      end
      make_dir(File.dirname(path))

      Error.check_and_raise(
        C.make_dir(@transaction_root.read_pointer, path, revision.pool)
      )
    end

    def change_txn_prop(propname, value)
      Error.check_and_raise(
        C.change_txn_prop(self, propname, CountedString.from_string(value), revision.pool)
      )
    end

    def change_file_content(path, content)
      nullpointer = FFI::Pointer.new(0)
      # in_stream ||= StringIO.new
      # in_stream.write(content)
      # in_stream.rewind
      newpool = revision.pool.create_child_pool
      stream_ptr = FFI::MemoryPointer.new( :pointer )
      Error.check_and_raise(
        C.apply_text(stream_ptr, @transaction_root.read_pointer, path, nullpointer, newpool)
      )
      in_svn_stream = Svn::Stream.new(stream_ptr.read_pointer)
      in_svn_stream.write(content)
      in_svn_stream.close()
      # Svn::Stream.release(newpool)
      # 
    end

    def commit()
      out = FFI::MemoryPointer.new( :pointer )
      rev_no = FFI::MemoryPointer.new( :int, 1 )
      # begin
        Error.check_and_raise(
          C.commit(out, rev_no, self, revision.pool)
        )
        rev_no.read_array_of_int(1)[0]
      # rescue 
      #   abort
      #   raise
      # end
    end

    def abort()
      Error.check_and_raise(
        C.abort(self, revision.pool)
      )
    end

    def author; txn_prop("svn:author"); end
    def author=(val); change_txn_prop( "svn:author", val); end

    def log; txn_prop("svn:log"); end
    def log=(val); change_txn_prop( "svn:log", val); end

    def to_s
      "TransactionRoot: " + @revision.inspect
    end
  end

end
