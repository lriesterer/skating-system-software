tclsh tcltrim full english
compress script.tt 3s_script_full_en.c
copy 3s_script_full_en.c ..\skating

tclsh tcltrim full french
compress script.tt 3s_script_full_fr.c
copy 3s_script_full_fr.c ..\skating


tclsh generate_lang_files
