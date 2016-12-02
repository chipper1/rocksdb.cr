class RocksDB::Iterator
  include Value(LibRocksDB::RocksdbIteratorT)

  @read_options : ReadOptions

  def initialize(@db : DB, read_options : ReadOptions? = nil)
    @read_options = (read_options || @db.read_options).not_nil!
    @raw = LibRocksDB.rocksdb_create_iterator(@db.raw, @read_options.raw)
    @len = Pointer(UInt64).malloc(1_u64)
    @opened = true
  end

  def first!
    LibRocksDB.rocksdb_iter_seek_to_first(raw)
  end
  
  def last!
    LibRocksDB.rocksdb_iter_seek_to_last(raw)
  end

  def next!
    LibRocksDB.rocksdb_iter_next(raw)
  end
  
  def prev!
    LibRocksDB.rocksdb_iter_prev(raw)
  end
  
#  fun rocksdb_iter_key(x0 : RocksdbIteratorT, klen : LibC::SizeT*) : LibC::Char*
  def key?
    ptr = LibRocksDB.rocksdb_iter_key(raw, @len)
    @len.value == 0 ? nil : String.new(ptr, @len.value)
  end

  def key
    key? || ""
  end
  
  protected def free
    LibRocksDB.rocksdb_iter_destroy(raw)
  end

#  fun rocksdb_iter_valid(x0 : RocksdbIteratorT) : UInt8
#  fun rocksdb_iter_seek(x0 : RocksdbIteratorT, k : LibC::Char*, klen : LibC::SizeT)
#  fun rocksdb_iter_value(x0 : RocksdbIteratorT, vlen : LibC::SizeT*) : LibC::Char*
#  fun rocksdb_iter_get_error(x0 : RocksdbIteratorT, errptr : LibC::Char**)

end
