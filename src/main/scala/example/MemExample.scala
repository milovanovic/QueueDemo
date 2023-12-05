package example

import chisel3._
import chisel3.util.Queue
import circt.stage.ChiselStage

// IO pins for memories
class MemIO[T <: Data](proto: T) extends Bundle {
    val i_addr = Input(UInt(10.W))
    val i_data = Input(proto.cloneType)
    val i_en   = Input(Bool())
    val o_addr = Input(UInt(10.W))
    val o_data = Output(proto.cloneType)
}

/**
 * SyncReadMem example
 * @param proto Type of memory
 * @tparam T Data type, for this example is expected SInt or UInt
 */
class SyncMem[T <: Data](proto: T) extends Module {
    val io = IO(new MemIO(proto))
    val mem = SyncReadMem(1 << io.i_addr.getWidth, proto.cloneType)
    when (io.i_en) {mem(io.i_addr) := io.i_data}
    io.o_data := mem(io.o_addr)
}

/**
 * Simple Mem example
 * @param proto Type of memory
 * @tparam T Data type, for this example is expected SInt or UInt
 */
class SimpleMem[T <: Data](proto: T) extends Module {
    val io = IO(new MemIO(proto))
    val mem = Mem(1 << io.i_addr.getWidth, proto.cloneType)
    when (io.i_en) {mem(io.i_addr) := io.i_data}
    io.o_data := mem(io.o_addr)
}

// Queue 
object QueueUIntApp extends App {
    private val design = ChiselStage.emitCHIRRTL(new Queue(UInt(16.W), 1024, pipe = true))
    Helper.writeFile(pathname = "test_and_run", firName = "GenMem", fir = design)
}
object QueueSIntApp extends App {
    private val design = ChiselStage.emitCHIRRTL(new Queue(SInt(16.W), 1024, pipe = true))
    Helper.writeFile(pathname = "test_and_run", firName = "GenMem", fir = design)
}
// SyncReadMem
object SyncReadMemUIntApp extends App {
    private val design = ChiselStage.emitCHIRRTL(new SyncMem(UInt(16.W)))
    Helper.writeFile(pathname = "test_and_run", firName = "GenMem", fir = design)
}
object SyncReadMemSIntApp extends App {
    private val design = ChiselStage.emitCHIRRTL(new SyncMem(SInt(16.W)))
    Helper.writeFile(pathname = "test_and_run", firName = "GenMem", fir = design)
}
// Mem
object MemUIntApp extends App {
    private val design = ChiselStage.emitCHIRRTL(new SimpleMem(UInt(16.W)))
    Helper.writeFile(pathname = "test_and_run", firName = "GenMem", fir = design)
}
object MemSIntApp extends App {
    private val design = ChiselStage.emitCHIRRTL(new SimpleMem(SInt(16.W)))
    Helper.writeFile(pathname = "test_and_run", firName = "GenMem", fir = design)
}