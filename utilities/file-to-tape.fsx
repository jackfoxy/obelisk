// file-to-tape.fsx
open System
open System.IO

let args = Environment.GetCommandLineArgs()
let inFile = 
    File.ReadAllLines(Path.Combine([|args.[2]|]))

let outString (inString : string)  = 
    "\" " + inString + " \"."

let output =
  inFile
  |> Array.map outString

File.WriteAllLines(Path.Combine(args.[2] + "2"), output)
