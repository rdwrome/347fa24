( // extract and evaluate code from text file
var file, path, text; // used to read the text from file
var cues; // of initial position of and '( //'
var chunks; // array with chunks of text containing potential code
var code;  // an array with the parsed code

path = PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_08_chapterInPlainText.txt"; // the path to the file
file = File(path,"r"); // open for reading operations 
text = file.readAllString; // read all text to a string
file.close; // close files

cues = text.findAll("( //"); // find the positions of all occurences of '( //'
cues = cues.select{ arg index; (text[index - 1] != $') && (text[index - 1] != $") }; // remove all invalid parenthes (ones preceeded by ' or ")

(cues.size-1).do{ arg index; 
	chunks = chunks.add(text[(cues[index] .. cues[index+1])].toString); // copy all text between subsequent cues and put it on chunks array
}; 
chunks = chunks.add(text[(cues.last .. text.size)].toString);  // also add last chunk

chunks.do{ arg item, index; // for every chunk of text
	var counter = 0, position = 0, done = false;
	item.do{arg char,i; // for every character in chunk
		if (done.not) { // if not done, increment counter for every '(' and decrement it for every ')'
			case 
			{char == $( } { counter = counter + 1 }
			{char == $) } { counter = counter - 1 }; 
			if (counter == 0) {position = i; done = true;}; // if counter equals 0, then the code ends at position i and the done flag is set to true 
		}
	};
	code = code.add(item[(0 .. position)].toString); // copy the parsed code to the code array
};

(code.size + " blocks of code have been succesfully extracted from text file").postln;
"Fourth code block will be now evaluated".postln;
code[5].interpret; // evaluate the sixth example
)
