function import_functions(){
	DIR="functions"
        for FUNCTION in $(dirname "$0")/$DIR/*; do
          if [ -d $FUNCTION ]; then
	    continue
           elif [ -f $FUNCTION ]; then
	    . $FUNCTION
          fi
        done
}

import_functions
system_checks
pause 'Press any key to continue...'


banner(){
	echo "     Setting $OS"
	echo "  ============================="
}
banner1(){
	echo "            SUB-MENU"
	echo "  ============================="
}
fun101(){
	echo "function 101 executed."
}
