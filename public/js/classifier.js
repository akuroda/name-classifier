jQuery(document).ready(
    function() {

         $('input[type=text]').keypress( function (e) {
             if ( (e.which && e.which == 13) || (e.keyCode &&e.keyCode == 13 )) {
                 $('#s2').click();
                 return false;
             }
         } );

         $("#s2").click(function() {
             if (!$("#name").val() || !$("#name").val().match(/,/)) {
                 $('#input-group').addClass('has-error').addClass('has-feedback');

                 return false;
             } else {
                 $('#input-group').removeClass('has-error').removeClass('has-feedback');

             }


            $.ajax({
                type: 'GET',
                url: '/json?name='+ $(':text[name="name"]').val(),
                dataType: 'json',
                success: function(json) {
                    $(".tbl_s_body").empty();
                    $(".tbl_c_body").empty();
                    $('<tr>'+
                      '<td class="bg-info">M</td>'+
                      '<td>' + json.sex['M'] + '</td>' +
                      '<td class="bg-danger">F</td>'+  
                      '<td>' + json.sex['F'] + '</td>' +
                      '</tr>').appendTo('table.tbl_s tbody');
                    
                    for(var i in json.country){
                        $('<tr>'+
                       '<td>' + i + '</td>' +
                          '<td>' + json.country[i] + '</td>' +
                          '</tr>').appendTo('table.tbl_c tbody');
                        
                    }
                }
            });
        });
    }
)
