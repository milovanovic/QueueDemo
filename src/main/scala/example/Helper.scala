package example

import java.io.{BufferedWriter, File, FileWriter}

object Helper {
  /** writeFile function is used to write string generated by the ChiselStage.emitCHIRRTL to the txt file.
   *
   * Full path of the generated file is: "./" + dir "/" + firName + ".fir"
   *
   * @param pathname folder where to store generated file
   * @param firName  how to name the file
   * @param fir      String generated from the ChiselStage.emitCHIRRTL
   */
  def writeFile(pathname: String, firName: String, fir: String): Unit = {
    // Write output data to text file
    val directory = new File("./" + pathname);
    if (!directory.exists()) {
      directory.mkdir()
    }
    val file = new File(pathname + "/" + firName + ".fir")
    val w = new BufferedWriter(new FileWriter(file))
    w.write(fir)
    w.close()
  }
}