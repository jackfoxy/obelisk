// glue-hoon-list.fsx
open System
open System.IO

//fsi.CommandLineArgs

let args = Environment.GetCommandLineArgs()  

let inFile = 
    File.ReadAllLines(Path.Combine([|args.[2]|]))

let rec loop (acc : string) n =
  match n with
  | 0 -> loop (acc + inFile.[0].Trim().Replace(" ]", "]")) 1 
  | n when n = inFile.Length -> acc
  | _ -> 
    if inFile.[n].Trim() = "]" then
        loop (acc + inFile.[n].Trim()) (n + 1)
    else
        loop (acc + " " + inFile.[n].Trim().Replace(" ]", "]")) (n + 1) 

File.WriteAllText((args.[2] + "2"), (loop "" 0))
