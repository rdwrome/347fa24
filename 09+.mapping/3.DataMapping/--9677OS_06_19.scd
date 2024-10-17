// probing a dataset
~data = CSVFileReader.read("arrhythmia.data".absolutePath,true,true); // read data
~data.class; // dataset it is an instance of Array
~data.collect(_.species).as(IdentitySet); // containing other Arrays
~data.size; // 452 of them actually
~data.flatten.collect(_.species).as(IdentitySet); // each of which contains Strings

// filter irrelevant data
~data = ~data.flatten.collect(_.asInteger); // convert to mono-dimensional array of Integers
~data = ~data.select(_!=0); // remove zeros
~data = ~data.as(IdentitySet).asArray; // convert to IdentitySet and back to Array to filter out duplicates