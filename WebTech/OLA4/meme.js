/**
 * Programer: Jeremy Saltz
    Class: CSCI 4410
    Program description: The program makes a meme page
    It opens with a place holder pic and lets the user 
    enter text on the top of the meme and on the bottom of the
    meme. The user then can insert a photo url into the url
    input and change the photo for the meme. After that the 
    user can move the picture around up, down, left, and right
    using the arrow keys. This is the javascript and jquery 
    that is used to interacted with the user events. It hadles the
    keyup so it adds as the user types. 
 */
$(document).ready(function(){
    // Keyup event handler for #top-text
    $('#top-text').keyup(function(){
        var topText = $(this).val();
        $('#top-caption').html(topText);
    });

    // Keyup event handler for #bottom-text
    $('#bottom-text').keyup(function(){
        var bottomText = $(this).val();
        $('#bottom-caption').html(bottomText);
    });

    // Keyup event handler for #image-url
    $('#image-url').keyup(function(){
        var imageUrl = $(this).val();
        $('#img1').attr('src', imageUrl);
    });

    // Keyup event handler for document - Moving the image
    $(document).keyup(function(event){
        if (event.which == 37) {
            // Move left
            $("#meme3").animate({left: '-=100px'});
        } else if (event.which == 38) {
            // Move up
            $("#meme3").animate({top: '-=100px'});
        } else if (event.which == 39) {
            // Move right
            $("#meme3").animate({left: '+=100px'});
        } else if (event.which == 40) {
            // Move down
            $("#meme3").animate({top: '+=100px'});
        }
    });
});
