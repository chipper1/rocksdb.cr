class RocksDB::DB
  include Value(LibRocksDB::RocksdbT)
  include Commands

  alias RawValue = Options | ReadOptions | WriteOptions

  @options       : Options
  @read_options  : ReadOptions
  @write_options : WriteOptions

  getter! raw
  getter! read_options
  getter! write_options

  def initialize(@path : String, options : Options? = nil, read_options : ReadOptions? = nil, write_options : WriteOptions? = nil)
    @raw_values = [] of RawValue

    @options       = options       || raw_value(Options.new.create!)
    @read_options  = read_options  || raw_value(ReadOptions.new)
    @write_options = write_options || raw_value(WriteOptions.new)

    @len = Pointer(UInt64).malloc(1_u64)
    @err = Pointer(Pointer(UInt8)).malloc(1_u64)
    @raw = rocksdb_open(@options.raw, @path)

    @opened = true
  end

  protected def free
    @raw_values.each(&.close)
    @raw_values.clear
    rocksdb_close(raw)
  end

  protected def raw_value(value)
    @raw_values << value
    value
  end

  @[AlwaysInline]
  private def db
    if opened?
      raw
    else
      raise Error.new("RocksDB(#{@path}) is closed.")
    end
  end
end
