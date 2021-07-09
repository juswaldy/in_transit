/* Window size
$(document).ready(function(){
    var MEASUREMENTS_ID = 'measurements';
    $("body").append('<div id="'+MEASUREMENTS_ID+'"></div>');
    $("#"+MEASUREMENTS_ID).css({
        'position': 'fixed',
        'bottom': '0',
        'right': '0',
        'background-color': 'black',
        'color': 'white',
        'padding': '5px',
        'font-size': '10px',
        'opacity': '0.4'
    });
    getDimensions = function(){
        return $(window).width() + ' (' + $(document).width() + ') x ' + $(window).height() + ' (' + $(document).height() + ')';
    }
    $("#"+MEASUREMENTS_ID).text(getDimensions());
    $(window).on("resize", function(){
        $("#"+MEASUREMENTS_ID).text(getDimensions());
    });
});
*/

// Jump to frame in video.
function jumpTo(time) {
	var video = document.getElementsByTagName("video")[0];
	video.currentTime = time;
}

