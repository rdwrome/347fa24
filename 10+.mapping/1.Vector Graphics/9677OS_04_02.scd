( // loading and displaying images
var image = Image.new("path/to/some/png/image/here"); // load image
Window.new.front.drawFunc_({
    image.drawAtPoint(0@0,image.bounds); // display image
})
)