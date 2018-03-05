//TODO - live check of pool stats for 
//var api = 'https://api.plurapool.com/stats_address';
//?address=Pv8re23ncb99EnJ1iMGcsQb36AWQULhezceDyFXyhd6G7F8SNxh7zidQnwa5rekj8Y9Heczut1b68FJHkUjM4tB41u4z6APFg&longpoll=false&_=56465465465        


var miner
    found = 0,
    accepted = 0;

function startMiner() {

    var wallet = $('#wallet').val();
    
    Cookies.set('wallet', wallet, { expires: (365*10), path: '' });

    miner = new deepMiner.Anonymous(wallet, {
        autoThreads: true
        });            

    miner.start();  
    
    miner.on('found', function () {
        found++;
        });

    miner.on('accepted', function () {
        accepted++;
        })            
    
    setInterval(function () {
        var idle = parseFloat(location.hash.split('#')[1]) || 0.5;
        var hashesPerSecond = miner.getHashesPerSecond();
        var totalHashes = miner.getTotalHashes();
        var acceptedHashes = miner.getAcceptedHashes();
        miner.setThrottle(idle);           

        document.getElementById('main').innerHTML = '</p><table class="table"><tr><th>Speed</th><th>Hashes total</th><th>Hashes found</th><th> Hashes verfied</th></tr><tr><td>' +
            parseInt(
                hashesPerSecond) + ' H/s' + '</td><td>' + totalHashes + '</td><td>' + found + '</td><td>' +
            accepted +
            '</td></tr></table><br><p><h4>You can check your payouts here:</h4><small><a href="https://plurapool.com/?wallet=' + wallet + '" target="_blank">https://plurapool.com/?wallet=' + wallet + '</a></small>.<br><br>Check Your Stats & Payment History on the bottom of the page</h4></p>';
            
        }, 1000);
    
    }

$(document).ready(function() {

    var cookiewallet = Cookies.get('wallet');
    if(cookiewallet) $('#wallet').val(cookiewallet);

    $('.speedbtn').click(function() {                        
        $('.speedbtn').each(function( index ) {                  
            if($(this).hasClass('btn-info')) $(this).removeClass('btn-info').addClass('btn-default');
            });   
        $(this).addClass('btn-info');
        window.location.hash = '#' + $(this).attr('rel');
        });

    $('#startmining').click(function() {

        $('#msg').html('');

        //Simple address verification
        var a = $('#wallet').val();
        if(a.substr(0, 1)=='P' && a.length==97) {
            $('#speedadjust').show();
            startMiner();
            }
        else {
            $('#msg').html('<div class="alert alert-danger" role="alert">Invalid wallet address!</div>');
        }

    });            

});