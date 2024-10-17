( // accessing remotely stored data with curl
var data, path;
path = "arrhythmia.data".absolutePath; // destination path
("curl \"http://archive.ics.uci.edu/ml/machine-learning-databases/arrhythmia/arrhythmia.data\" -o" + path).systemCmd;
"ok reading !".postln;
data = CSVFileReader.read("arrhythmia.data".absolutePath,true,true);
)
