{%- extends 'full.tpl' -%}


{%- block header -%}
{{ super() }}

 <link rel="stylesheet" href="http://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">

<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>

<style>  /* defined here in case the main.css below cannot be loaded */
.lev1 {margin-left: 80px}
.lev2 {margin-left: 100px}
.lev3 {margin-left: 120px}
.lev4 {margin-left: 140px}
.lev5 {margin-left: 160px}
.lev6 {margin-left: 180px}
</style>


<link rel="stylesheet" type="text/css" href="../../css/jt.css">
<link rel="stylesheet" type="text/css" href="../../css/toc2.css">

<script src="https://rawgit.com/ipython-contrib/jupyter_contrib_nbextensions/master/src/jupyter_contrib_nbextensions/nbextensions/toc2/toc2.js"></script>

 <script src="../../js/docs.js"></script>

<script>
    MathJax.Hub.Config({
        "HTML-CSS": {
            preferredFont: "TeX",
            availableFonts: ["STIX","TeX"],
            styles: {
                scale: 110,
                ".MathJax_Display": {
                    "font-size": "110%",
                }
            }
        }
    });
</script>

<script>
$( document ).ready(function(){

            var cfg={'threshold':{{ nb.get('metadata', {}).get('toc', {}).get('threshold', '3') }},     // depth of toc (number of levels)
             // 'number_sections': {{ 'true' if nb.get('metadata', {}).get('toc', {}).get('number_sections', False) else 'false' }},  
             'number_sections': false,  // sections numbering
             'toc_cell': false,          // useless here
             'toc_window_display': true, // display the toc window
             "toc_section_display": "block", // display toc contents in the window
             // 'sideBar':{{ 'true' if nb.get('metadata', {}).get('toc', {}).get('sideBar', False) else 'false' }},      
             'sideBar':true,       // sidebar or floating window
             'navigate_menu':false       // navigation menu (only in liveNotebook -- do not change)
            }

            var st={};                  // some variables used in the script
            st.rendering_toc_cell = false;
            st.config_loaded = false;
            st.extension_initialized=false;
            st.nbcontainer_marginleft = $('#notebook-container').css('margin-left')
            st.nbcontainer_marginright = $('#notebook-container').css('margin-right')
            st.nbcontainer_width = $('#notebook-container').css('width')
            st.oldTocHeight = undefined
            st.cell_toc = undefined;
            st.toc_index=0;

            // fire the main function with these parameters


            table_of_contents(cfg,st);


            var file=tutorialsDict[$("h1:first").attr("id")];
            var path="http://gaow.github.io/dsc-wiki"
            $("#toc-level0 a").css("color","#126dce");
            $('a[href="#'+$("h1:first").attr("id")+'"]').hide()
            
            var tuts=tutorials;
            var pos=tutorials.indexOf(file);
        
            for (var a=pos;a>=0;a--){
                  var name=tuts[a]
                  $('<li><a href="'+path+'/doc/tutorials/'+name+'.html">'+name.replace(/_/g," ")+'</a></li>').insertBefore("#toc-level0 li:eq(0)");
            }
            $('a[href="'+path+'/doc/tutorials/'+file+'.html'+'"]').css("color","#126dce");

            $('<li id="indexHome"><a href="'+path+'/tutorials.html"><b>Home<b></a></li>').insertBefore("#toc-level0 li:eq(0)");
            for (var a=pos+1;a<tuts.length;a++){
                  var name=tuts[a]
                  $(".toc #toc-level0").append('<li><a href="'+path+'/doc/tutorials/'+name+'.html">'+name.replace(/_/g," ")+'</a></li>');
            }
            $("#toc-header").hide();


    });
</script>


{%- endblock header -%}
